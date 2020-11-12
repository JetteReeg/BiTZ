#ifndef CELL_H
#define CELL_H

#include <map>
#include <vector>
#include "ft_pop.h"

using namespace std;

class CCell
{
public:
    //! index of vector
    int index;
    //! x coordinate
    int x;
    //! y coordinate
    int y;
    //! Land use ID
    int LU_id;
    //! Patch ID
    int pa_id;
    //! transition zone cell
    bool TZ;
    //! potential transition zone cell
    bool TZ_pot;

    struct Patch_ID_Definitions
    {
        //! identifier
        int PID;
        //! patch type
        string Type;
        //! patch area
        double Area;
        //! number of bordercells (only considered in arable patches)
        int nb_bordercells;
    };
    Patch_ID_Definitions PID_def;

    //! List of all FT populations in cell
    vector<std::shared_ptr<FT_pop>> FT_pop_List;
    //! Map of all population sizes of FT in cell
    map <int, int> FT_pop_sizes;
    //! population size of foraging type 1
    map <int, int> FT_pop_sizes_foraging_1;
    //! population size of foraging type 2
    map <int, int> FT_pop_sizes_foraging_2;
    //! population size of foraging type 3
    map <int, int> FT_pop_sizes_foraging_3;
    //! constructors
    CCell();
    CCell(int index, int xx,int yy, int pa_id);
    //! functions
    //! set LU classes in cell
    void Set_lu_classes();
};

#endif // CELL_H
