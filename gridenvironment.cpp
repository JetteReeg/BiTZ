#include "gridenvironment.h"
#include "runparameter.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <string>
#include <cmath>

using namespace std;

GridEnvironment::GridEnvironment()
{
}

vector <int> GridEnvironment::readLandscape(){
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
    //return dummi vector
    return v_tmp;
}

std::tuple<int, int> GridEnvironment::set_coordinates(int location){
    int y,x;
    y = (int) ceil(location/ SRunPara::RunPara.xmax);
    x = (int) location % SRunPara::RunPara.xmax;
    return std::make_tuple(x,y);
}

std::map<int, double> GridEnvironment::get_distance_LU(int location){

    std::map<int, double> distances;
    // for each LU
    for (int i=0;i<SRunPara::RunPara.nb_LU;i++) {
        // but only if LU is not the LU of the current cell
        if (i!=Grid.land_use_id[location]){
            //go through each entry in Grid vector
            // check if LU is the current i
            // and calculate the distance; keep the min. distance
            double dist_min=SRunPara::RunPara.GetSumCells(), dist_curr=0.0;

            // cell is the current location in the Grid vector
            for (int cell=0; cell<(int) Grid.land_use_id.size(); cell++){
                if (i==Grid.land_use_id[cell]){
                    // now calculate the distance
                    int i1,i2,j1,j2;
                    i1 = Grid.x[location]; //target cell
                    i2 = Grid.x[cell]; // current cell
                    j1 = Grid.y[location]; // target cell
                    j2 = Grid.y[cell]; // current cell
                    dist_curr = sqrt((pow(i2-i1,2)-pow(j2-j1,2)));
                    dist_min = min(dist_min, dist_curr);
                }
            }
            distances.insert(std::pair<int,double>(i,dist_min));
        }

    }

    return distances;
}
