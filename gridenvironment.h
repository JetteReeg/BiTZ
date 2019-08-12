#ifndef GRIDENVIRONMENT_H
#define GRIDENVIRONMENT_H

#include "runparameter.h"
#include <cell.h>
using namespace std;

class GridEnvironment
{
public:
    //! List of all cells
    vector <CCell*> CellList;
    //! constructor
    GridEnvironment();

    //! read the lanscape
    static void readLandscape();
    //! calculate the closest distance to other land use class
    static void calculate_distance_LU();
};

extern GridEnvironment CoreGrid;

#endif // GRIDENVIRONMENT_H
