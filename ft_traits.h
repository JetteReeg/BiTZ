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

    //! identifier as string and as integer
    string FT_type;
    int FT_ID;

    //! population function after Maynard-Smith and Slatkin
    //! growth rate
    double R;
    //! shape factor of the density compensation
    double b;
    //! competition effect
    double c;
    //! effects of the transition zones on nesting size and resource availability
    double trans_effect_nest;
    double trans_effect_res;

    //! dispersal parameters
    double mu; // how many individuals will disperse?
    double omega; // how strong is the effect if population is beyond the capacity?
    double dist_eff; // susceptibility for disturbances
    double dispsd; // standard deviation of dispersal distance
    double dispmean; // mean of dispersal distance
    int flying_period; // period of resource uptake
    map <int, double> LU_suitability_nest; // map of the nesting suitability for each land use class
    map <int, double> LU_suitability_forage; // map of the forage suitability for each land use class

    //! functions to read in FT definition file, nest suitability file and forage suitability file
    static void ReadFTDef(const string file);
    static void ReadNestSuitability(const string file);
    static void ReadForageSuitability(const string file);
};

#endif // FT_TRAITS_H
