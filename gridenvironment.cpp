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
    for (int x=0; x< (int) SRunPara::RunPara.xmax; x++){
        for (int y=0; y< (int) SRunPara::RunPara.ymax; y++){
            index_pa=x*(int) SRunPara::RunPara.xmax+y;
            //cout<<"currently at patch ID: "<<v_tmp_pa[index_pa]<<endl;
            // set patch ID in each cell object
            shared_ptr<CCell> cell = make_shared<CCell>(index_pa,x,y,v_tmp_pa[index_pa]);
            //if patch ID exists in Patch_defList map
            if(GridEnvironment::Patch_defList.count(v_tmp_pa[index_pa])>0){
                // set patch_def for each cell
                shared_ptr<Patch_def> patch_def=GridEnvironment::Patch_defList.find(v_tmp_pa[index_pa])->second;
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
                CoreGrid.CellList.push_back(cell);
                if (cell->PID_def.Type=="bare") cell->LU_id=0;
                if (cell->PID_def.Type=="arable") cell->LU_id=1;
                if (cell->PID_def.Type=="forest") cell->LU_id=2;
                if (cell->PID_def.Type=="grassland") cell->LU_id=3;
                if (cell->PID_def.Type=="urban") cell->LU_id=4;
                if (cell->PID_def.Type=="water") cell->LU_id=5;
                if (cell->PID_def.Type=="notdefined") cell->LU_id=6;
            } else {
                cout<<"Patch ID "<<v_tmp_pa[index_pa]<<" not found!"<<endl;
                exit(3);
            };
        };
    };// end loop over all gridcells

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
             for (int i=std::max(0,CoreGrid.CellList[location]->x-SRunPara::RunPara.TZ_width);
                  i<std::min(SRunPara::RunPara.xmax,CoreGrid.CellList[location]->x+SRunPara::RunPara.TZ_width);
                  i++){
                 for (int j=std::max(0,CoreGrid.CellList[location]->y-SRunPara::RunPara.TZ_width);
                      j<std::min(SRunPara::RunPara.ymax,CoreGrid.CellList[location]->y+SRunPara::RunPara.TZ_width);
                      j++){
                      if(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id==2 || CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id==3 ) border_cell++;
                      }
                }
             }
        if (border_cell>0) {
            nb_bordercells++;
            CoreGrid.CellList[location]->TZ_pot=true;
        }
    }
    // get nb of TZ cells do generate
    int nb_TZ_cells=nb_bordercells*SRunPara::RunPara.TZ_percentage;
    // get from patch id definition file the patch IDs which should be prioritized
    // select randomly a patch ID, which should get TZ
    // go through the map of patch definitions to get prioritized IDs
    // map includes all arable patches including their patch size
    // sorted by patch area
    map<double, int, std::greater<int> > PID_size;

    for (auto it = GridEnvironment::Patch_defList.begin(); it!=GridEnvironment::Patch_defList.end(); it++){
        shared_ptr<Patch_def> tmp = it->second;
        if (tmp->Type=="arable"){
            PID_size.insert(std::make_pair(tmp->Area,tmp->PID));
        }
    }

    // go through the map
    if (SRunPara::RunPara.size_order=="descending"){
        // go in order
        for (auto it = PID_size.begin(); it!=PID_size.end(); it++){
            // while there are still cells left
            while (nb_TZ_cells>0){
                // select a random cell
                int x=floor(combinedLCG()*SRunPara::RunPara.xmax);
                int y=floor(combinedLCG()*SRunPara::RunPara.ymax);
                shared_ptr <CCell> cell = CoreGrid.CellList[x*SRunPara::RunPara.xmax+y];
                // if cell is border cell + PID==it->second
                if (cell->TZ_pot==true && cell->pa_id==it->second){
                    // set cell to TZ cell
                    cell->TZ=true;
                    nb_TZ_cells--;
                }
            }
        }
    }
    if (SRunPara::RunPara.size_order=="ascending"){
        // go in reverse order
        for (auto it = PID_size.rbegin(); it!=PID_size.rend(); it++){
            // while there are still cells left
            while (nb_TZ_cells>0){
                // select a random cell
                int x=floor(combinedLCG()*SRunPara::RunPara.xmax);
                int y=floor(combinedLCG()*SRunPara::RunPara.ymax);
                shared_ptr <CCell> cell = CoreGrid.CellList[x*SRunPara::RunPara.xmax+y];
                // if cell is border cell + PID==it->second
                if (cell->TZ_pot==true && cell->pa_id==it->second){
                    // set cell to TZ cell
                    cell->TZ=true;
                    nb_TZ_cells--;
                }
            }
        }
    }
}// end calculate distance
