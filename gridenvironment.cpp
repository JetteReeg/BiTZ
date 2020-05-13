#include "gridenvironment.h"
#include "runparameter.h"
#include "runtimeenvironment.h"
#include "lcg.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <string>
#include <cmath>

using namespace std;

GridEnvironment CoreGrid;
map< int, shared_ptr<Patch_def> > GridEnvironment::Patch_defList = map< int, shared_ptr<Patch_def> >();

GridEnvironment::GridEnvironment(): CCell()
{
}

void GridEnvironment::readLandscape(){
    //Open Landscape patch ID file
    const char* name_pa=SRunPara::NameLandscapePatchFile.c_str();
    string line_pa1;
    ifstream LandscapePatchFile(name_pa);
    //check if file exists
    if (!LandscapePatchFile.good()) { cerr<<("Error while opening landscape patch file");exit(3); }
    //dummi vector for storage
    int tmp_pa;
    vector <int> v_tmp_pa;
    // copy data (Patch ID landscape file)
    while(LandscapePatchFile.good())
    {
        LandscapePatchFile >> tmp_pa;
        v_tmp_pa.push_back(tmp_pa);
    }

    int index_pa;
    // loop over all gridcells to define patch IDs
    for (int x=0; x< SRunPara::RunPara.xmax; x++){
        for (int y=0; y< SRunPara::RunPara.ymax; y++){
            index_pa=x*SRunPara::RunPara.xmax+y;
            //cout<<"currently at patch ID: "<<v_tmp_pa[index_pa]<<endl;
            // set patch ID in each cell object
            shared_ptr<CCell> cell = make_shared<CCell>(index_pa,x,y,v_tmp_pa[index_pa]);
            //if patch ID exists in Patch_defList map
            if(GridEnvironment::Patch_defList.count(v_tmp_pa[index_pa])>0){
                // set patch_def for each cell
                shared_ptr<Patch_def> patch_def=GridEnvironment::Patch_defList.find(v_tmp_pa[index_pa])->second; // get the parameters of the specific patch
                cell->PID_def.PID=patch_def->PID;
                cell->PID_def.Area=patch_def->Area;
                cell->PID_def.Para=patch_def->Para;
                cell->PID_def.Type=patch_def->Type;
                cell->PID_def.Perim=patch_def->Perim;
                cell->PID_def.Shape=patch_def->Shape;
                cell->PID_def.Gyrate=patch_def->Gyrate;
                cell->PID_def.Area_CSD=patch_def->Area_CSD;
                cell->PID_def.Area_LSD=patch_def->Area_LSD;
                cell->PID_def.Perim_cps=patch_def->Perim_cps;
                cell->PID_def.Perim_csd=patch_def->Perim_csd;
                cell->PID_def.Perim_lsd=patch_def->Perim_lsd;
                cell->PID_def.nb_bordercells=0;
                CoreGrid.CellList.push_back(cell);
                if (cell->PID_def.Type=="bare") cell->LU_id=0;
                if (cell->PID_def.Type=="arable") cell->LU_id=1;
                if (cell->PID_def.Type=="forest") cell->LU_id=2;
                if (cell->PID_def.Type=="grassland") cell->LU_id=3;
                if (cell->PID_def.Type=="urban") cell->LU_id=4;
                if (cell->PID_def.Type=="water") cell->LU_id=5;
                if (cell->PID_def.Type=="transition") cell->LU_id=6;
            } else {
                cout<<"Patch ID "<<v_tmp_pa[index_pa]<<" not found!"<<endl;
                exit(3);
            }
        }
    }// end loop over all gridcells

}

void GridEnvironment::readPatchID_def(const string file){
    // read patch ID definitions
    //Open InitFile
    ifstream DefFile(file.c_str());
        if (!DefFile.good()) {
            cerr << ("Error while opening patch ID definition File");
            exit(3);
        }
        // read the header line and skip it
        string line;
        getline(DefFile, line);
        while (getline(DefFile, line))
        {
            // get the ID definition for each patch
            std::stringstream ss(line);
            string dummi;
            // create a structure for the traits
            shared_ptr<Patch_def> patch_def = make_shared<Patch_def>();
            // skip first column
            ss >> dummi;
            ss>> patch_def->PID >> patch_def->Type >> patch_def->Area
                    >> patch_def->Area_CSD >> patch_def->Area_LSD
                    >> patch_def->Perim >> patch_def->Perim_csd
                    >> patch_def->Perim_cps >> patch_def->Perim_lsd
                    >>  patch_def->Gyrate >> patch_def->Para
                    >> patch_def->Shape;
            // add a new patch ID to the list of patches
            patch_def->nb_bordercells=0;
            GridEnvironment::Patch_defList.insert(std::make_pair(patch_def->PID, patch_def));
        }// end read patch ID definitions

}

void GridEnvironment::calculate_TZ(){
    int nb_bordercells=0;
    // go through all cells of the grid and count nb. of border cells
    for (unsigned int location=0; location<SRunPara::RunPara.GetSumCells(); ++location){
        // if cell is arable
        int border_cell=0;

         if (CoreGrid.CellList[location]->LU_id==1){
             // go through each surrounding cell
             for (int i=std::max(0,(CoreGrid.CellList[location]->x)-1);
                  i<=std::min(SRunPara::RunPara.xmax-1,(CoreGrid.CellList[location]->x)+1);
                  i++){
                 for (int j=std::max(0,(CoreGrid.CellList[location]->y)-1);
                      j<=std::min(SRunPara::RunPara.ymax-1,(CoreGrid.CellList[location]->y)+1);
                      j++){
                      if(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id==2 || CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id==3 ) border_cell++;
                      }
                }
             }
        if (border_cell>0) {
            nb_bordercells++;
            CoreGrid.CellList[location]->TZ_pot=true;
            //find patch ID  and count number of bordercells of this patch
            GridEnvironment::Patch_defList.find(CoreGrid.CellList[location]->pa_id)->second->nb_bordercells++;
        }
    }
    // get nb of TZ cells do generate
    //cout<<"nb border cells "<<nb_bordercells<<endl;
    int nb_TZ_cells=int(floor(nb_bordercells*SRunPara::RunPara.TZ_percentage));
    //cout<<"nb TZ cells "<<nb_TZ_cells<<endl;
    // get from patch id definition file the patch IDs which should be prioritized
    // select randomly a patch ID, which should get TZ
    // go through the map of patch definitions to get prioritized IDs
    // map includes all arable patches including their patch size
    // sorted by patch area
    multimap<double, int, std::greater<int> > PID_size;

    for (auto it = GridEnvironment::Patch_defList.begin(); it!=GridEnvironment::Patch_defList.end(); it++){
        shared_ptr<Patch_def> tmp = it->second;
        if (tmp->Type=="arable"){
            PID_size.insert(std::make_pair(tmp->Area,tmp->PID));
        }
    }

    // go through the map
    if (SRunPara::RunPara.size_order=="descending"){
        bool next_patch=false;
        // go in order
            for (auto it = PID_size.begin(); it!=PID_size.end(); it++){
                // while there are still cells left
                next_patch=false;
                if (nb_TZ_cells>0){
                    while (next_patch==false){
                        // select a random cell
                        int x=int(floor(combinedLCG()*SRunPara::RunPara.xmax));
                        int y=int(floor(combinedLCG()*SRunPara::RunPara.ymax));
                        shared_ptr <CCell> cell = CoreGrid.CellList[x*SRunPara::RunPara.xmax+y];
                        // if cell is border cell + PID==it->second
                        if (cell->TZ==false && cell->TZ_pot==true && cell->pa_id==it->second){
                            // set cell to TZ cell
                            cell->TZ=true;
                            cell->LU_id=6;
                            GridEnvironment::Patch_defList.find(cell->pa_id)->second->nb_bordercells--;
                            nb_TZ_cells--;
                            // set all neighbouring cells within range of TZ_width and lu=1 to TZ
                            if(SRunPara::RunPara.TZ_width>1 && nb_TZ_cells>0){
                                for (int i=std::max(0,x-(SRunPara::RunPara.TZ_width-1));
                                     i<=std::min(SRunPara::RunPara.xmax-1,x+(SRunPara::RunPara.TZ_width-1));
                                     i++){
                                    for (int j=std::max(0,y-(SRunPara::RunPara.TZ_width-1));
                                         j<=std::min(SRunPara::RunPara.ymax-1,y+(SRunPara::RunPara.TZ_width-1));
                                         j++){
                                         if(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id==1) {
                                             if (CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->TZ==false){
                                                 CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->TZ=true;
                                                 CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id=6;
                                                 if(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->TZ_pot==true
                                                         && CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->pa_id==it->second)
                                                 {
                                                     GridEnvironment::Patch_defList.find(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->pa_id)->second->nb_bordercells--;
                                                     nb_TZ_cells--;
                                                 }

                                             }
                                            }
                                         }
                                   }
                            }
                            //cout<<"nb border in patch "<<GridEnvironment::Patch_defList.find(cell->pa_id)->second->nb_bordercells<<endl;
                            if (GridEnvironment::Patch_defList.find(cell->pa_id)->second->nb_bordercells==0 || nb_TZ_cells==0) next_patch=true;
                        }
                    }// end while
                }

            }// end for
    }// end ascending
    if (SRunPara::RunPara.size_order=="ascending"){
        bool next_patch=false;
        // go in reverse order
        for (auto it = PID_size.rbegin(); it!=PID_size.rend(); it++){
            // while there are still cells left
            next_patch=false;
            if (nb_TZ_cells>0){
                while (next_patch==false){
                    // select a random cell
                    int x=int(floor(combinedLCG()*SRunPara::RunPara.xmax));
                    int y=int(floor(combinedLCG()*SRunPara::RunPara.ymax));
                    shared_ptr <CCell> cell = CoreGrid.CellList[x*SRunPara::RunPara.xmax+y];
                    // if cell is border cell + PID==it->second
                    if (cell->TZ==false && cell->TZ_pot==true && cell->pa_id==it->second){
                        // set cell to TZ cell
                        cell->TZ=true;
                        cell->LU_id=6;
                        GridEnvironment::Patch_defList.find(cell->pa_id)->second->nb_bordercells--;
                        nb_TZ_cells--;
                        // set all neighbouring cells within range of TZ_width and lu=1 to TZ
                        if(SRunPara::RunPara.TZ_width>1 && nb_TZ_cells>0){
                            for (int i=std::max(0,x-(SRunPara::RunPara.TZ_width-1));
                                 i<=std::min(SRunPara::RunPara.xmax-1,x+(SRunPara::RunPara.TZ_width-1));
                                 i++){
                                for (int j=std::max(0,y-(SRunPara::RunPara.TZ_width-1));
                                     j<=std::min(SRunPara::RunPara.ymax-1,y+(SRunPara::RunPara.TZ_width-1));
                                     j++){
                                     if(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id==1) {
                                         if (CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->TZ==false){
                                             CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->TZ=true;
                                             CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id=6;
                                             if(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->TZ_pot==true
                                                     && CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->pa_id==it->second)
                                             {
                                                 GridEnvironment::Patch_defList.find(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->pa_id)->second->nb_bordercells--;
                                                 nb_TZ_cells--;
                                             }

                                         }
                                        }
                                     }
                               }
                        }
                        if (GridEnvironment::Patch_defList.find(cell->pa_id)->second->nb_bordercells==0 || nb_TZ_cells==0) next_patch=true;
                    }
                }// end while
            }

        }// end for
    }

    // save grid
    stringstream strd;
    strd<<"Output/TZ_"<<SRunPara::RunPara.SimNb<<"_"<<SRunPara::RunPara.MC<<".txt";
    string NameGridFile=strd.str();
    ofstream Gridfile(NameGridFile.c_str(),ios::app);
    if (!Gridfile.good()) {cerr<<("Error while opening Output File");exit(3); }
    // write header
    Gridfile.seekp(0, ios::end);
    long size=Gridfile.tellp();
    if (size==0){
        Gridfile<<"Year\t"
                  <<"LU_ID\t"
                  <<"nb_FT\t"
                  <<"diversity\t"
                 <<"totalN"
                  ;
            Gridfile<<"\n";
        }
    for (unsigned int location=0; location<SRunPara::RunPara.GetSumCells(); ++location){
        int output=0;
        if(CoreGrid.CellList[location]->TZ==true) output=1;
        if(output==0 && CoreGrid.CellList[location]->TZ_pot==true) output=2;
        Gridfile<<'\t'<<output;
        if(CoreGrid.CellList[location]->y==SRunPara::RunPara.ymax) Gridfile<<"\n";
    }
    Gridfile.close();
    //
    strd.str(std::string());
    strd<<"Output/Land_"<<SRunPara::RunPara.SimNb<<"_"<<SRunPara::RunPara.MC<<".txt";
    string NameLandFile=strd.str();
    ofstream Landfile(NameLandFile.c_str(),ios::app);
    if (!Landfile.good()) {cerr<<("Error while opening Output File");exit(3); }
    // write header
    Landfile.seekp(0, ios::end);
    long size_land=Landfile.tellp();
    if (size_land==0){
        Landfile<<"Year\t"
                  <<"LU_ID\t"
                  <<"nb_FT\t"
                  <<"diversity\t"
                 <<"totalN"
                  ;
            Landfile<<"\n";
        }
    for (unsigned int location=0; location<SRunPara::RunPara.GetSumCells(); ++location){
        int output=0;
        output=CoreGrid.CellList[location]->LU_id;
        Landfile<<'\t'<<output;
        if(CoreGrid.CellList[location]->y==SRunPara::RunPara.ymax) Landfile<<"\n";
    }
    Landfile.close();
}// end calculate distance
