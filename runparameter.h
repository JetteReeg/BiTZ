#ifndef RUNPARAMETER_H
#define RUNPARAMETER_H

#include <string>
#include <vector>
#include <map>

using namespace std;

//! Structure with all static scenario parameters
struct SRunPara
{
public:
    static SRunPara RunPara;

    //Input Files
    //! Filename of PftTrait-File
    static std::string NameFtFile;
    //! Filename of Landscape file with patch IDs
    static std::string NameLandscapePatchFile;
    //! Filename of LU nest suitability file
    static std::string NameNestSuitabilityFile;
    //! Filename of LU forage suitability file
    static std::string NameForageSuitabilityFile;
    //! Filename of patch definition file
    static std::string NamePatchDefFile;

    // simulation number
    int SimNb;

    //! maximal time
    int t_max;
    //! grid size
    int xmax, ymax;
    //! number of land use classes
    int nb_LU;
    //! width of transition zone
    int TZ_width;
    int TZ_percentage;
    static std::string size_order;

    //! disturbances
    double disturbances;

    //! number of repetitions
    int Nrep;
    //! constructor
    SRunPara();

    //! sum of grid cells
    inline int GetSumCells() const {return xmax*ymax;}
};




#endif // RUNPARAMETER_H
