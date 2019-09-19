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
        xcoord=cell->x;
        ycoord=cell->y;
        cout<<"Coordinates for type "<<Traits->FT_type<<": "<<xcoord<<"  "<<ycoord<<endl;
    }// end if not defined
}//end setCell

void FT_pop::set_trans_effect(CCell* cell){
    //go through the map distance_LU
    for (auto var = cell->distance_LU.begin();
            var != cell->distance_LU.end(); ++var) {
        // check if distance is smaller than FT_trait Traits->trans_effect
        if (var->second.dist<Traits->trans_effect){
            //calculate trans_effect in cell for FT_pop
            double patch_size, patch_shape, patch_size_neighbour, patch_shape_neighbour;
            double land_use_suitability;
            double neighbour_patch_effect;
            double local_patch_effect;
            //Wie groß und welche Form hat der aktuelle patch? --> je größer und gleichmäßiger, desto geringer der Effekt? (kleinerer SHAPE + größere AREA = kleinerer Effekt)
            patch_size=cell->PID_def.Area;
            patch_shape=cell->PID_def.Shape;
            local_patch_effect=patch_size/(patch_size+patch_shape);
            //Wie groß und welche Form hat der andere patch? --> je größer und gleichmäßiger desto stärker der Effekt? (kleinere SHAPE + größere AREA = größerer Effekt)
            patch_size_neighbour=var->second.Area;
            patch_shape_neighbour=var->second.Shape;
            neighbour_patch_effect=patch_shape_neighbour/(patch_size_neighbour+patch_shape_neighbour);
            //Je geeigneter die andere LU Klasse, desto geringer der Effekt
            land_use_suitability=Traits->LU_suitability.find(cell->LU_id)->second;
            trans_effect+=var->second.dist*local_patch_effect*neighbour_patch_effect*land_use_suitability;
            cout<<"trans_effect for type "<<Traits->FT_type<<": "<<trans_effect<<endl;
        }
    }
}

void FT_pop::set_popCap(CCell* cell){
    int x = nrand(1000);
    popCap=x;
    cout<<"popCap for type "<<Traits->FT_type<<": "<<popCap<<endl;
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
    //get the

}

void FT_pop::update_pop(FT_pop* pop){
    pop->Pt=pop->Pt1;
    pop->Pt1=0;
}

bool pairCompare( pair<size_t,int> i, pair<size_t,int> j)
{
return i.second < j.second;
}

