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
        // identifier
        int PID;
        // patch type
        string Type;
        // patch area
        double Area;
        //
        //double Area_CSD;
        //double Area_LSD;
        //double Perim;
        //double Perim_csd;
        //double Perim_cps;
        //double Perim_lsd;
        //double Gyrate;
        //double Para;
        double Shape;
        int nb_bordercells;
    };
    Patch_ID_Definitions PID_def;

    //! List of all FT populations in cell
    vector<std::shared_ptr<FT_pop>> FT_pop_List;
    //! Map of all population sizes of FT in cell
    map <int, int> FT_pop_sizes;
    map <int, int> FT_pop_sizes_foraging;
    //! constructors
    CCell();
    CCell(int index, int xx,int yy, int pa_id);
    //! functions
    //! set LU classes in cell
    void Set_lu_classes();
};

#endif // CELL_H
