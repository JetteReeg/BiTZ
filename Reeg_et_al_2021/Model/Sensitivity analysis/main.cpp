/**\file
 * \brief main.cpp Read in the simulation file and start a simulation run
*/
#include <iostream>
#include <sstream>
#include "runparameter.h"
#include "runtimeenvironment.h"
#include <cmath>
#include <stdio.h>
#include <algorithm>

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

    #ifdef __linux__
    long int pid=getpid();
    #endif

    #ifdef __APPLE__
    long int pid=getpid();
    #endif

    //! initialize random number generator
    initLCG( pid, 3487234);
    //! handle arguments of the model
    if (argc>=2) {
        SRunPara::RunPara.MC=atoi(argv[1]);
    }
    //! read in simulation parameters
    //! for each line/SimNb start one run
    //! output file is named according to SimNb
    stringstream strd;
    strd<<"Input/Simulations.txt";
    cout<<strd.str()<<endl;
    static std::string NameSimFile=strd.str();
    cout<<NameSimFile<<endl;
    //! Read in the simulation/scenario file and then run the simulation
    RuntimeEnvironment::readSimDef(NameSimFile);
    return 0;
}


