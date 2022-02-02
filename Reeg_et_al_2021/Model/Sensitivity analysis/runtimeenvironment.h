#ifndef RUNTIMEENVIRONMENT_H
#define RUNTIMEENVIRONMENT_H

#include "gridenvironment.h"
#include "lcg.h"
#include "runparameter.h"
#include "ft_traits.h"
#include "output.h"
#include "cell.h"


//! Environment of the simulation
class RuntimeEnvironment: public GridEnvironment
{
public:
    //! constructor
    RuntimeEnvironment();
    //! year
    static int year;
    //! weather in the specific year
    static double weather_year;
    //! functions
    //! simulation definitions/scenarios
    static void readSimDef(const string file);
    //! run one year
    static void one_year();
    //! run one simulation run
    static void one_run();
    //! initialize the system
    static void init();
    //! initialize the landscape
    static void init_landscape();
    //! initialize the functional types (traits and definitions)
    static void init_FTs();
    //! initialize the populations
    static void init_populations();
    //! initialize FT populations (is called by init_populations
    static void InitFTpop(shared_ptr <FT_traits> traits, int n);
    //! write output files
    static void WriteOfFile(int nrep);
    //! calculate the yearly weather
    static void weather();
    //! help function to use random number generation for normal distribution
    inline static int nrand(int n){return int(floor(combinedLCG()*n));}
};

    //! distance between two points using Pythagoras
    double Distance(const double& xx, const double& yy,
                    const double& x=0, const double& y=0);
    //! compare two index-values in their distance to the center of grid
    bool CompareIndexRel(int i1, int i2);

#endif // RUNTIMEENVIRONMENT_H
