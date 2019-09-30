#include <QCoreApplication>
#include <iostream>
#include <runparameter.h>
#include <runtimeenvironment.h>
#include <cmath>

#ifdef _WIN32
#include <windows.h>
#endif

#ifdef _WIN64
#include <windows.h>
#endif

#ifdef __linux__
#include <unistd.h>
#endif

#ifdef __APPLE__
#include <unistd.h>
#endif

using namespace std;

//GridEnvironment* Envir=new GridEnvironment;
// global functions?





int main(int argc, char *argv[])
{
    QCoreApplication a(argc, argv);
    #ifdef _WIN32
    DWORD pid=GetCurrentProcessId();
    #endif

    #ifdef _WIN64
    DWORD pid=GetCurrentProcessId();
    #endif

    #ifdef __linux__
    long int pid=getpid();
    #endif

    #ifdef __APPLE__
    long int pid=getpid();
    #endif
    //initialize random number generator
    initLCG( pid, 3487234);
    if (argc>=2) {
            // handle arguments of the model
    }
    // global parameters?



    //start one run
    RuntimeEnvironment::one_run();



    return 0;
    //return a.exec();
}


