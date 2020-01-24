#ifndef GRIDENVIRONMENT_H
#define GRIDENVIRONMENT_H

#include "runparameter.h"
#include "cell.h"
using namespace std;

struct Patch_def{
    // identifier
    int PID;
    // patch type
    string Type;
    // patch area
    double Area;
    //
    double Area_CSD;
    double Area_LSD;
    double Perim;
    double Perim_csd;
    double Perim_cps;
    double Perim_lsd;
    double Gyrate;
    double Para;
    double Shape;
    };

class GridEnvironment: public CCell
{
public:
    //! List of all cells
    vector <shared_ptr<CCell>> CellList;
    //! constructor
    GridEnvironment();

    //! read the lanscape
    static void readLandscape();
    //! calculate the closest distance to other land use class
    static void calculate_TZ();
    //! links of Patches used
    static map<int,shared_ptr<Patch_def>> Patch_defList; //TODO: muss es ein shared_ptr sein?
    //! read Patch ID definition file
    static void readPatchID_def(const string file);
};



extern GridEnvironment CoreGrid;

#endif // GRIDENVIRONMENT_H
