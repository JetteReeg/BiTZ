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
    //go through the map distance_LU
    for (auto var = cell->distance_LU.begin();
            var != cell->distance_LU.end(); ++var) {
        // check if distance is smaller than FT_trait Traits->trans_effect
        if (var->second<Traits->trans_effect){
            //calculate trans_effect in cell for FT_pop
            double patch_size, patch_shape, patch_size_neighbour, patch_shape_neighbour;
            //Wie groß und welche Form hat der aktuelle patch? --> je größer und gleichmäßiger, desto geringer der Effekt? (kleinerer SHAPE + größere AREA = kleinerer Effekt)
            patch_size=cell->PID_def.Area;
            patch_shape=cell->PID_def.Shape;
            //Wie groß und welche Form hat der andere patch? --> je größer und gleichmäßiger desto stärker der Effekt? (kleinere SHAPE + größere AREA = größerer Effekt)

            //Je geeigneter die andere LU Klasse, desto geringer der Effekt
            double land_use_suitability=Traits->LU_suitability.find(cell->LU_id)->second;

        }
    }








//--> combine the resulting effs in one variable
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
    int K = pop->popCap;
    double C=20.0;
    double LU_suitability=pop->Traits->LU_suitability.find(cell->LU_id)->second;
    // result
    double Nt1j;

    //sum over all FT_pop_List
    double sum=0.0;
    if(!curr_FT_list.empty()){
        for (unsigned i=0; i < curr_FT_list.size(); i++) {
            FT_pop* curr_Pop=curr_FT_list.at(i);
            if(curr_Pop->Traits->FT_ID!=pop->Traits->FT_ID){
                double ci=curr_Pop->Traits->c;
                int Ni = curr_Pop->Pt;
                double to_add=(1+((cj-ci)/C))*Ni;
                cout<<"sum of other FTs: "<<to_add<<endl;
                sum+=to_add;
            }
        }
    }
    //check function!
    Nt1j=(Ntj*Rj*(1-trans_effect)*LU_suitability)/(1+((Rj-1)*pow(((Ntj+sum)/K),bj)));
    cout << "Nt: "<<Ntj<< " and Nt+1: " <<Nt1j<<endl;
    //update Pt1 value of Pop
    pop->Pt1=(int) Nt1j;
}

void FT_pop::dispersal(FT_pop* pop){

}

bool pairCompare( pair<size_t,int> i, pair<size_t,int> j)
{
return i.second < j.second;
}

