#ifndef GRIDENVIRONMENT_H
#define GRIDENVIRONMENT_H

#include "runparameter.h"
#include "cell.h"
using namespace std;

struct Patch_def{
    //! identifier
    int PID;
    //! patch type
    string Type;
    //! patch area
    double Area;
    //! number of border cells (only used in arable patches
    int nb_bordercells;
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
    //! calculate the potential and realized transition zones
    static void calculate_TZ();
    //! links of Patches used
    static map<int,shared_ptr<Patch_def>> Patch_defList;
    //! read Patch ID definition file
    static void readPatchID_def(const string file);
};



extern GridEnvironment CoreGrid;

#endif // GRIDENVIRONMENT_H
