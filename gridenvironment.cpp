#include "gridenvironment.h"
#include "runparameter.h"
#include <runtimeenvironment.h>
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
            CCell* cell = new CCell(index_pa,x,y,v_tmp_pa[index_pa]);
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

void GridEnvironment::calculate_distance_LU(){
    /*// go through each cell of the grid
    for (unsigned int location=0; location<SRunPara::RunPara.GetSumCells(); ++location){
        //location is the current cell
        // for each LU [lu] that is not the LU of the current cell [location]
        for (int lu=0;lu<SRunPara::RunPara.nb_LU;lu++) {
            // but only if LU [lu] is not the LU of the current cell [location]
            if (lu!=CoreGrid.CellList[location]->LU_id){
                // go again through each cell [entry in CellList[]]
                // check if LU of this cell is the current lu
                // and calculate the distance; keep the min. distance

                //maximal distance
                double dist_max = sqrt((pow(SRunPara::RunPara.xmax,2)+pow(SRunPara::RunPara.ymax,2)));
                //minimal distance
                double dist_min=dist_max, dist_curr=0.0;

               min_dist_cell tmp_storage_cell;
                tmp_storage_cell.Area=0.0;
                tmp_storage_cell.Para=0.0;
                tmp_storage_cell.dist=dist_min;
                tmp_storage_cell.Perim=0.0;
                tmp_storage_cell.Shape=0.0;

                // go through the CellList[]
                for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
                        // link to cell
                        CCell* cell = CoreGrid.CellList[i];
                        // if cell is of the current LU
                        if (lu==cell->LU_id){
                            // now calculate the distance
                            int i1,i2,j1,j2;
                            i1 = CoreGrid.CellList[location]->x; //current cell
                            i2 = cell->x; // 'neighbour' cell
                            j1 = CoreGrid.CellList[location]->y; // current cell
                            j2 = cell->y; // 'neighbour' cell
                            //current distance of the two cells
                            dist_curr = sqrt((pow(i2-i1,2)+pow(j2-j1,2)));
                            //TODO save also characteristics of the patch!
                            if (dist_curr<dist_min){
                                tmp_storage_cell.dist=dist_curr;
                                tmp_storage_cell.Area=cell->PID_def.Area;
                                tmp_storage_cell.Shape=cell->PID_def.Shape;
                                tmp_storage_cell.Perim=cell->PID_def.Perim;
                                tmp_storage_cell.Para=cell->PID_def.Para;
                                dist_min=dist_curr;
                            }
                        }// end if target land use class
                }// end inner loop over grid
                // set minimal distance in reference to the maximal distance
                //tmp_storage_cell.dist = tmp_storage_cell.dist/dist_max;
                // set the minimal calculated distance to each other LU for the current cell [location]
                CoreGrid.CellList[location]->distance_LU.insert(std::pair<int,min_dist_cell> (lu,tmp_storage_cell));
                // test if the current cell becomes a transition zone cell
                // only if current cell is arable
                if(CoreGrid.CellList[location]->LU_id==1 && (lu==2 || lu== 3)){
                    // the cell is a transition zone cell, if the minimal distance to LU X is < than run paramenter TZ_width
                                    if(tmp_storage_cell.dist<=SRunPara::RunPara.TZ_width){
                                        CoreGrid.CellList[location]->TZ=true;
                                    }
                }// end if lu of location is arable and neighbouring lu is forest or grassland
            } // end if lu is not lu of location
        }// end for loop over all LU classes
    }// end loop over grid*/

    // go through each cell of the grid
    for (unsigned int location=0; location<SRunPara::RunPara.GetSumCells(); ++location){
        //location is the current cell
        //if LU in the current cell is 1
        if (CoreGrid.CellList[location]->LU_id==1){
            //go through neighboring cells within radius of RunPara.TZ_width
            for (int i=std::max<unsigned long>(0,CoreGrid.CellList[location]->x-SRunPara::RunPara.TZ_width);
                 i<std::min<unsigned long>(SRunPara::RunPara.xmax,CoreGrid.CellList[location]->x+SRunPara::RunPara.TZ_width);
                 i++){
                for (int j=std::max<unsigned long>(0,CoreGrid.CellList[location]->y-SRunPara::RunPara.TZ_width);
                     j<std::min<unsigned long>(SRunPara::RunPara.ymax,CoreGrid.CellList[location]->y+SRunPara::RunPara.TZ_width);
                     j++){
                    // and check if lu class of these cells is either 2 or 3
                    if(CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id==2 || CoreGrid.CellList[i*SRunPara::RunPara.xmax+j]->LU_id==2 ){
                        // if so --> set cell to TZ_cell
                        CoreGrid.CellList[location]->TZ=true;
                        }//  end if lu 2 or 3
                    }// end j loop
                }// end i loop
        }// end if lu 1
    }// end cell loop
}// end calculate distance
