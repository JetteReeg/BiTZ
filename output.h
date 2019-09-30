#ifndef OUTPUT_H
#define OUTPUT_H
#include <vector>
#include <string>
#include <memory>

struct SFTout{
    int year;
    int FT_ID;
    int LU_ID;
    int popsize;
    SFTout();
};

class Output
{
public:
    Output();
    static std::vector <SFTout*> FToutdata;
    static SFTout* GetOutput(int year, int FT_ID, int lu);
};

#endif // OUTPUT_H
