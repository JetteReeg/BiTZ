#ifndef CELL_H
#define CELL_H

#include <map>
#include <vector>
#include <ft_pop.h>
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
    //! distance to other land use classes
    map<int, double> distance_LU;
    //! capacity
    int sumCap;
    //! List of all FT populations in cell
    vector<FT_pop*> FT_pop_List;
    //! Map of all population sizes of FT in cell
    map <int, int> FT_pop_sizes;
    //! constructors
    CCell();
    CCell(int index, int xx,int yy, int LU_id);
    //! functions
    //! set LU classes in cell
    void Set_lu_classes();
};

#endif // CELL_H
