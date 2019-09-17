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
    //! Filename of LU suitability file
    static std::string NameSuitabilityFile;
    //! Filename of patch definition file
    static std::string NamePatchDefFile;

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
