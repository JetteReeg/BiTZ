#ifndef FT_POP_H
#define FT_POP_H

#include <memory>
#include <ft_traits.h>



class FT_pop
{
public:
    FT_pop();

    //! FT Traits
    shared_ptr<FT_traits> Traits;

    //! current location
    double xcoord;
    //! current location
    double ycoord;

    //! capacity for each population -> where to calculate?
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
};

#endif // FT_POP_H
