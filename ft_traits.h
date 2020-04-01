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
    double trans_effect_nest;// how much does TZ increase nesting site availability?
    double trans_effect_res; // how much does TZ increase resource availability?

    // dispersal parameters
    double mu; // how many individuals will disperse?
    double omega; // how strong is the effect if population is beyond the capacity?
    double dist_eff; // susceptibility for disturbances
    double dispsd; // standard deviation of dispersal distance
    double dispmean; // mean of dispersal distance
    int flying_period; // period of resource uptake
    map <int, double> LU_suitability_nest;
    map <int, double> LU_suitability_forage;

    static void ReadFTDef(const string file);
    static void ReadNestSuitability(const string file);
    static void ReadForageSuitability(const string file);
};

#endif // FT_TRAITS_H
