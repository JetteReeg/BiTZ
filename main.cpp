#include <QCoreApplication>
#include <iostream>
#include <runparameter.h>
#include <gridenvironment.h>
#include <populationdynamics.h>
#include <analyses.h>
#include <cmath>

using namespace std;

// global parameters?
    SGridPara Grid;
    GridEnvironment Envir;
    //population dynamic class
    Populationdynamics PopDyn;
    //analyses
    //Analyses* Analyse;
// global functions?





int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    if (argc>=2) {
            // handle arguments of the model
    }


    SRunPara::RunPara.NamePftFile="Test.txt";
    SRunPara::RunPara.NameLandscapeFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/300x300Bsp.asc";
    SRunPara::RunPara.t_max=100;
    SRunPara::RunPara.xmax=300;
    SRunPara::RunPara.ymax=300;
    SRunPara::RunPara.nb_LU=5;



    vector <int> tmp = Envir.readLandscape();
    //! set land use ID
    for (int i=0; i<(int) tmp.size(); i++){
        Grid.land_use_id.push_back(tmp[i]);
        //set coordinates
        int x,y;
        tie(x, y) = Envir.set_coordinates(i);
        Grid.x.push_back(x);
        Grid.y.push_back(y);
    }
    //! calculate the distance to each other LU class
    for (int i=0; i<(int) Grid.land_use_id.size(); i++){
        //set closest distance to other land use class
        std::map <int, double> distance_LU_tmp;
        distance_LU_tmp = Envir.get_distance_LU(i);
        Grid.distance_LU.push_back(distance_LU_tmp);
    }












    //analyse and output results


    return a.exec();
}


