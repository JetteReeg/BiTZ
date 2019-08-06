#include "gridenvironment.h"
#include "runparameter.h"
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <string>

using namespace std;

GridEnvironment::GridEnvironment()
{
}

vector <int> GridEnvironment::readLandscape(){

    //Open Landscape file
    const char* name=SRunPara::NameLandscapeFile.c_str();

    string line;

    ifstream LandscapeFile(name);

    if (!LandscapeFile.good()) { cerr<<("Error while opening landscape file");exit(3); }
    //  // read header
    //	string line;
    //	getline(LandscapeFile,line);


    int tmp;
    vector <int> v_tmp;

    // copy data
    while(LandscapeFile.good())
    {
        LandscapeFile >> tmp;
        v_tmp.push_back(tmp);
    }
    return v_tmp;
}
