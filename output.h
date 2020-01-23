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

struct SComout{
    int year;
    int LU_ID;
    double nb_FT;
    double diversity;
    SComout();
};

class Output
{
public:
    Output();
    static std::vector <std::shared_ptr<SFTout>> FToutdata;
    static std::vector <std::shared_ptr<SComout>> Comoutdata;
    static std::shared_ptr<SFTout> GetOutput_FT(int year, int FT_ID, int lu);
    static std::shared_ptr<SComout> GetOutput_Com(int year, int lu);
};

#endif // OUTPUT_H
