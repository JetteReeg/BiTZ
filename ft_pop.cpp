#include "ft_pop.h"
#include <cell.h>
#include <runparameter.h>
#include <algorithm>
#include <iostream>
#include <numeric>
#include <iterator>


FT_pop::FT_pop()
{

}

FT_pop::FT_pop(shared_ptr<FT_traits> Traits, CCell* cell, int n):
  cell(NULL), Traits(Traits), xcoord(0), ycoord(0), popCap(0), trans_effect(0),
  Pt(n), Pt1(0), Emmigrants(0), Immigrants(0)
{
    //establish this FT on cell
    setCell(cell);
    // calculate trans_effect for the pop
    set_trans_effect(cell);
    // calculate popCap
    set_popCap(cell);
} // end constructor

void FT_pop::setCell(CCell* cell){
    // if cell not defined
    if (this->cell==NULL){
        // define cell as cell
        this->cell=cell;
        this->xcoord=cell->x;
        this->ycoord=cell->y;
    }// end if not defined
}//end setCell

void FT_pop::set_trans_effect(CCell* cell){
    // get minimal distance to a different LU_class
    pair<size_t,float> min = *min_element(cell->distance_LU.begin(), cell->distance_LU.end
    (), pairCompare );
    // get sum of distances
    double sum_distance=0.0;
    for (auto const& x : cell->distance_LU)
    {
        sum_distance+=x.second;
    }
    //cout<<"min_distance "<<min.second;
    //cout <<"sum distance "<<sum_distance<<endl;
    // Option 1: sum_distance * FT_trait trans_effect
    //this->trans_effect=sum_distance*Traits->trans_effect;

    // Option 2: minimal distance * FT_trait trans_effect
    this->trans_effect=min.second*Traits->trans_effect;
}

void FT_pop::set_popCap(CCell* cell){
    int x = nrand(1000);
    this->popCap=x;
}

void FT_pop::growth(FT_pop* pop){
    // get the cell of the current population
    CCell* cell=pop->cell;
    vector<FT_pop*> curr_FT_list=cell->FT_pop_List;
    //
    // population function variables and parameters:
    int Ntj=pop->Pt;
    double Rj=pop->Traits->R;
    double trans_effect = pop->trans_effect;
    double cj=pop->Traits->c;
    double bj = pop->Traits->b;
    double C=20.0;
    // result
    double Nt1j;

    //sum over all FT_pop_List
    double sum=0.0;
    for (unsigned i=0; i < curr_FT_list.size(); i++) {
        FT_pop* curr_Pop=curr_FT_list.at(i);
        if(curr_Pop->Traits->FT_ID!=pop->Traits->FT_ID){
            double ci=curr_Pop->Traits->c;
            int Ni = curr_Pop->Pt;
            sum=+(1+(cj-ci)/C*Ni);
        }
    }
    //check function!
    Nt1j=(Ntj*Rj*trans_effect)/(1+(Rj-1)*pow((Ntj+sum),bj));
    //update Pt1 value of Pop
    pop->Pt1=(int) Nt1j;
}

void FT_pop::dispersal(FT_pop* pop){

}

bool pairCompare( pair<size_t,int> i, pair<size_t,int> j)
{
return i.second < j.second;
}

