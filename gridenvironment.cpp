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

GridEnvironment::GridEnvironment()
{
}

void GridEnvironment::readLandscape(){
    //Open Landscape file
    const char* name=SRunPara::NameLandscapeFile.c_str();
    string line;
    ifstream LandscapeFile(name);
    //check if file exists
    if (!LandscapeFile.good()) { cerr<<("Error while opening landscape file");exit(3); }
    //dummi vector for storage
    int tmp;
    vector <int> v_tmp;
    // copy data
    while(LandscapeFile.good())
    {
        LandscapeFile >> tmp;
        v_tmp.push_back(tmp);
    }

    int index;
    // loop over all gridcells
    for (int x=0; x< (int) SRunPara::RunPara.xmax; x++){
        for (int y=0; y< (int) SRunPara::RunPara.ymax; y++){
            index=x*(int) SRunPara::RunPara.xmax+y;
            // set land use IDs in each cell object
            CCell* cell = new CCell(index,x,y,v_tmp[index]);
            CoreGrid.CellList.push_back(cell);
        }
    }// end loop over all gridcells
}

void GridEnvironment::calculate_distance_LU(){
    // go through each location of the grid
    for (unsigned int location=0; location<SRunPara::RunPara.GetSumCells(); ++location){
        // for each LU
        for (int i=0;i<SRunPara::RunPara.nb_LU;i++) {
            // but only if LU is not the LU of the target cell
            if (i!=CoreGrid.CellList[location]->LU_id){
                // go through each entry CellList[]
                // check if LU of the cell is the current i
                // and calculate the distance; keep the min. distance
                double dist_max = sqrt((pow(SRunPara::RunPara.xmax,2)+pow(SRunPara::RunPara.ymax,2)));
                double dist_min=dist_max, dist_curr=0.0;

                // cell is the current location in the CellList
                for (unsigned int i=0; i<SRunPara::RunPara.GetSumCells(); ++i){
                        // link to cell
                        CCell* cell = CoreGrid.CellList[i];
                        if (i==cell->LU_id){
                            // now calculate the distance
                            int i1,i2,j1,j2;
                            i1 = CoreGrid.CellList[location]->x; //target cell
                            i2 = cell->x; // current cell
                            j1 = CoreGrid.CellList[location]->y; // target cell
                            j2 = cell->y; // current cell
                            dist_curr = sqrt((pow(i2-i1,2)+pow(j2-j1,2)));
                            dist_min = min(dist_min, dist_curr);
                        }// end if target land use class
                }// end inner loop over grid
                dist_min = dist_min/dist_max;
                CoreGrid.CellList[location]->distance_LU.insert(std::pair<int,double>(i,dist_min));
            }
            /*else {
                // set distance for the same land use class to zero TODO: do I really need this
                CoreGrid.CellList[location]->distance_LU.insert(std::pair<int,double>(i,0.0));
            }// end if-else*/
        }// end for loop over all LU classes
    }// end loop over grid
}
