#ifndef RUNTIMEENVIRONMENT_H
#define RUNTIMEENVIRONMENT_H

#include "gridenvironment.h"
#include "lcg.h"
#include "runparameter.h"
#include "ft_traits.h"
#include "output.h"
#include "cell.h"



class RuntimeEnvironment: public GridEnvironment
{
public:
    RuntimeEnvironment();
    static int year;
    static double weather_year;
    static void readSimDef(const string file);
    static void one_year();
    static void one_run();
    static void init();
    static void init_landscape();
    static void init_FTs();
    static void init_populations();
    static void InitFTpop(shared_ptr <FT_traits> traits, int n);
    static void WriteOfFile(int nrep);
    static void weather();
    inline static int nrand(int n){return int(floor(combinedLCG()*n));}
};

//! distance between two points using Pythagoras
    double Distance(const double& xx, const double& yy,
                    const double& x=0, const double& y=0);
    //! compare two index-values in their distance to the center of grid
    bool CompareIndexRel(int i1, int i2);

#endif // RUNTIMEENVIRONMENT_H
