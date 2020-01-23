#include <iostream>
#include <sstream>
#include "runparameter.h"
#include "runtimeenvironment.h"
#include <cmath>
#include <stdio.h>

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


int main(int argc, char *argv[])
{
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
    // read in simulation parameters
    // for each line/SimNb start one run
    // output file should be named according to SimNb

    stringstream strd;
    strd<<"Input/Simulations.txt";
    cout<<strd.str()<<endl;
    static std::string NameSimFile=strd.str();
    cout<<NameSimFile<<endl;
    RuntimeEnvironment::readSimDef(NameSimFile);





    return 0;
    //return a.exec();
}


