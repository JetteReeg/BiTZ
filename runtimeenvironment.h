#ifndef RUNTIMEENVIRONMENT_H
#define RUNTIMEENVIRONMENT_H

#include <gridenvironment.h>
#include <lcg.h>
#include "runparameter.h"
#include "ft_traits.h"
#include <cell.h>

class RuntimeEnvironment: public GridEnvironment
{
public:
    RuntimeEnvironment();
    static int year;
    static void one_year();
    static void one_run();
    static void init();
    static void init_landscape();
    static void init_FTs();
    static void init_populations();
    static void InitFTpop(shared_ptr <FT_traits> traits, int n);
    static void analyse();
    inline static int nrand(int n){return combinedLCG()*n;}
};

#endif // RUNTIMEENVIRONMENT_H
