#include <QCoreApplication>
#include <iostream>
#include <runparameter.h>
#include <gridenvironment.h>
#include <populationdynamics.h>
#include <analyses.h>

using namespace std;

// global parameters?

// global functions?




int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    if (argc>=2) {
            // handle arguments of the model
    }

    SRunPara::RunPara.NamePftFile="Test.txt";
    SRunPara::RunPara.NameLandscapeFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/300x300Bsp.txt";
    SRunPara::RunPara.t_max=100;
    SRunPara::RunPara.xmax=14;
    SRunPara::RunPara.ymax=14;

    GridEnvironment Envir;

    vector <int> tmp = Envir.readLandscape();

    for (int i=0; i<tmp.size(); i++)
            SGridPara::GridPara.land_use_id.push_back(tmp[i]);






    //link to other classes
    //population dynamic class
    //Populationdynamics* PopDyn;
    //analyses
    //Analyses* Analyse;




    //analyse and output results


    return a.exec();
}


