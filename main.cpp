#include <QCoreApplication>
#include <iostream>
#include <init.h>
#include <populationdynamics.h>
#include <analyses.h>
#include <update.h>
using namespace std;

// global functions
void one_run (void){


}

void one_step (void){

}

int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    //link to other classes
    //init class
    Init* Init;
    //population dynamic class
    Populationdynamics* PopDyn;
    //analyses
    Analyses* Analyse;
    //updates
    Update* update;


    Init->years=5;
    Init->year=0;
    Init->filename_landscape="Blubb.asc";
    //initialize model
    Init->readLandscape(Init->filename_landscape);

    //start one run
    one_run();

    //analyse and output results


    return a.exec();
}


