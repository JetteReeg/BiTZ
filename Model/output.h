#ifndef OUTPUT_H
#define OUTPUT_H
#include <vector>
#include <string>
#include <memory>
#include "ft_pop.h"

//! output structure on the patch scale (yearly)
struct SFTout{
    //! year
    int year;
    //! identifier for the FT
    int FT_ID;
    //! identifier for the land use class
    int LU_ID;
    //! identifier for the patch
    int patch_ID;
    //! population size
    int popsize;
    //! constructor
    SFTout();
};

//! output structure on the cell scale (every 10th year)
struct SLandout{
    //! year
    int year;
    //! x coordinate
    int x;
    //! y coordinate
    int y;
    //! identifier for the land use class
    int LU_ID;
    //! identifier for the functional type
    int FT_ID;
    //! population size
    int popsize;
    //! constructor
    SLandout();
};

//! class for all output data
class Output
{
public:
    //! constructor
    Output();
    //! vector to store output on patch scale
    static std::vector <std::shared_ptr<SFTout>> FToutdata;
    //! vector to store output on cell scale
    static std::vector <std::shared_ptr<SLandout>> Landoutdata;
    //! save the patch scale output
    static std::shared_ptr<SFTout> GetOutput_FT(int year, int FT_ID, int lu, int patch_ID);
    //! save the cell scale output
    static std::shared_ptr<SLandout> GetOutput_Land(std::shared_ptr<FT_pop> pop, int year, int x, int y, int lu, int FT_ID);
};

#endif // OUTPUT_H
