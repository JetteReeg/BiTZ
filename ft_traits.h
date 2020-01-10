#ifndef FT_TRAITS_H
#define FT_TRAITS_H

#include <string>
#include <vector>
#include <map>
#include <memory>

using namespace std;

class FT_traits
{
public:
    FT_traits();

    //! links of Pfts(SPftTrais) used
    static map<string,shared_ptr<FT_traits>> FtLinkList;

    // identifier
    string FT_type;
    int FT_ID;

    // population function
    double R;
    double b;
    double c;
    double trans_effect;

    // dispersal parameters
    double mu;
    double omega;
    double alpha;
    double dispsd;
    double dispmean;

    map <int, double> LU_suitability_nest;
    map <int, double> LU_suitability_forage;

    static void ReadFTDef(const string file);
    static void ReadNestSuitability(const string file);
    static void ReadForageSuitability(const string file);
};

#endif // FT_TRAITS_H
