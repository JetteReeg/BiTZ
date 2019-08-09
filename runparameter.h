#ifndef RUNPARAMETER_H
#define RUNPARAMETER_H

#include <string>
#include <vector>
#include <map>

using namespace std;


//! Structure for all environmental grid parameters
struct SGridPara
{
public:
    // location within the grid:

    vector<int> x;
    vector<int> y;

    //! land use class
    vector<std::string> land_use;

    //! numerical land use class
    vector<int> land_use_id;

    //! distance to other land use classes
    vector<map<int, double> > distance_LU;

    //! capacity
    vector<int> sumCap;

    SGridPara();

};

extern SGridPara Grid;

//! Structure for all population grid parameters
struct SPopGridPara
{
public:
    //! capacity for each population
    int popCap;

    //! transition zone effect
    double trans_effect;

    //!current population size
    int Pt;

    //! new population size
    int Pt1;

    //! emmigrants
    int Emmigrants;

    //! immigrants
    int Immigrants;
};

//! Structure with all static scenario parameters
struct SRunPara
{
public:
    static SRunPara RunPara;

    //Input Files
    //! Filename of PftTrait-File
    static std::string NameFtFile;
    //! Filename of Landscape file
    static std::string NameLandscapeFile;

    //! maximal time
    int t_max;
    //! grid size
    int unsigned xmax, ymax;
    //! number of land use classes
    int nb_LU;

    //! constructor
    SRunPara();

    //! sum of grid cells
    inline int unsigned GetSumCells() const {return xmax*ymax;}
};



#endif // RUNPARAMETER_H
