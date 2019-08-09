#include <QCoreApplication>
#include <iostream>
#include <runparameter.h>
#include <gridenvironment.h>
#include <runtimeenvironment.h>
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

    RuntimeEnvironment::init();
    RuntimeEnvironment::one_run();




    return a.exec();
}


