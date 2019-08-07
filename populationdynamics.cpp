#include "populationdynamics.h"

Populationdynamics::Populationdynamics()
{

}

void Populationdynamics::dyn_function(int PopSize, int K, double r, double b){
    // normal Maynard-Smith and Slatkin function
    //for example Nt+1=[Nt*local_weather*R]/[1+(R-1)*(Nt/Kt)^b]

    // add effect of transition zones (distance to other land-use classes?
};

void Populationdynamics::dispersal(int PopSize){
    // add here all parameters needed for dispersal
};
