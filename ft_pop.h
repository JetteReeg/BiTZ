#ifndef FT_POP_H
#define FT_POP_H

#include <memory>
#include "ft_traits.h"
#include "lcg.h"


class CCell;

class FT_pop
{
protected:
    //! cell where the FT population is in
    shared_ptr<CCell> cell;
public:
    //! constructor
    FT_pop();
    //! constructor for plant objects
    FT_pop(shared_ptr<FT_traits> Traits, shared_ptr<CCell> cell, int n);
    //! FT Trait container
    shared_ptr<FT_traits> Traits;

    //! current location
    int xcoord;

    //! current location
    int ycoord;

    //! nest capacity for each FT population in the cell
    int nestCap;
    double MaxNestSuitability;

    //! foraging capacity for each FT population in the cell
    double resCap;

    //! transition zone effect for resources and nesting sites
    double trans_effect_res;
    double trans_effect_nest;

    //!current population size
    int Pt;

    //! new population size
    int Pt1;

    //! emmigrants
    int Emmigrants;

    //! immigrants
    int Immigrants;

    //! functions
    void setCell(shared_ptr<CCell> cell);
    void set_trans_effect(shared_ptr<CCell> cell);
    void set_nestCap(shared_ptr<CCell> cell);
    void set_max_nestCap(shared_ptr<CCell> cell);
    void set_resCap(shared_ptr<CCell> cell);
    static void set_foraging_individuals(std::shared_ptr<FT_pop> pop);
    inline static int nrand(int n){return int(floor(combinedLCG()*n));}
    static void growth(std::shared_ptr<FT_pop> pop, double weather_year);
    static void dispersal(std::shared_ptr<FT_pop> pop);
    static void update_pop(std::shared_ptr<FT_pop> pop);
    static void update_pop_dispersal(std::shared_ptr<FT_pop> pop);
    static void disturbance(std::shared_ptr<FT_pop> pop);
};

    bool pairCompare( pair<size_t,int> i, pair<size_t,int> j);

#endif // FT_POP_H
