#include <QCoreApplication>
#include <iostream>
#include <runparameter.h>
#include <runtimeenvironment.h>
#include <cmath>

using namespace std;

//GridEnvironment* Envir=new GridEnvironment;
// global functions?





int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    if (argc>=2) {
            // handle arguments of the model
    }
    // global parameters?



    RuntimeEnvironment::init();
    RuntimeEnvironment::one_run();




    return a.exec();
}


