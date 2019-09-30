#ifndef FT_POP_H
#define FT_POP_H

#include <memory>
#include <ft_traits.h>
#include <lcg.h>


class CCell;

class FT_pop
{
protected:
    //! cell where the FT population is in
    CCell* cell;
public:
    //! constructor
    FT_pop();
    //! constructor for plant objects
    FT_pop(shared_ptr<FT_traits> Traits, CCell* cell, int n);
    //! FT Trait container
    shared_ptr<FT_traits> Traits;

    //! current location
    int xcoord;

    //! current location
    int ycoord;

    //! capacity for each FT population in the cell
    int popCap;

    //! transition zone effect
    double trans_effect;

    //!current population size
    int Pt;

    //! new population size
    int Pt1;

    //! emmigrants
    int Emmigrants;

    //! immigrants
    int Immigrants;

    //! functions
    void setCell(CCell* cell);
    void set_trans_effect(CCell* cell);
    void set_popCap(CCell* cell);
    inline static int nrand(int n){return combinedLCG()*n;}
    static void growth(FT_pop* pop);
    static void dispersal(FT_pop* pop);
    static void update_pop(FT_pop* pop);
    static void update_pop_dispersal(FT_pop* pop);
};

    bool pairCompare( pair<size_t,int> i, pair<size_t,int> j);

#endif // FT_POP_H
