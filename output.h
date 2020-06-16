#ifndef OUTPUT_H
#define OUTPUT_H
#include <vector>
#include <string>
#include <memory>
#include <ft_pop.h>

struct SFTout{
    int year;
    int FT_ID;
    int LU_ID;
    int patch_ID;
    int popsize;
    SFTout();
};

struct SLandout{
    int year;
    int x;
    int y;
    int LU_ID;
    int FT_ID;
    int popsize;
    SLandout();
};

class Output
{
public:
    Output();
    static std::vector <std::shared_ptr<SFTout>> FToutdata;
    static std::vector <std::shared_ptr<SLandout>> Landoutdata;
    static std::shared_ptr<SFTout> GetOutput_FT(int year, int FT_ID, int lu, int patch_ID);
    static std::shared_ptr<SLandout> GetOutput_Land(std::shared_ptr<FT_pop> pop, int year, int x, int y, int lu, int FT_ID);
};

#endif // OUTPUT_H
