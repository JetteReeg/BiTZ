#include "ft_pop.h"
#include <cell.h>
#include <runparameter.h>
#include <algorithm>
#include <iostream>
#include <numeric>
#include <iterator>
#include <lcg.h>
#include <math.h>
#include <gridenvironment.h>

FT_pop::FT_pop()
{

}

FT_pop::FT_pop(shared_ptr<FT_traits> Traits, CCell* cell, int n):
  cell(NULL), Traits(Traits), xcoord(0), ycoord(0), nestCap(0), trans_effect(0),
  Pt(n), Pt1(0), Emmigrants(0), Immigrants(0)
{
    //establish this FT on cell
    setCell(cell);
    // calculate trans_effect for the pop
    set_trans_effect(cell);
    // calculate nesting capacity
    set_nestCap(cell);
    // calculate resource capacity
    set_resCap(cell);

} // end constructor

void FT_pop::setCell(CCell* cell){
    // if cell not defined
    if (this->cell==NULL){
        // define cell as cell
        this->cell=cell;
        xcoord=cell->x;
        ycoord=cell->y;
        //cout<<"Coordinates for type "<<Traits->FT_type<<": "<<xcoord<<"  "<<ycoord<<endl;
    }// end if not defined
}//end setCell

void FT_pop::set_trans_effect(CCell* cell){

    //define if the cell is a transition zone cell
    if(cell->TZ==true){
        trans_effect=Traits->trans_effect;
    }

}

void FT_pop::set_nestCap(CCell* cell){
    int x = nrand(100);
    nestCap=floor(x*this->Traits->LU_suitability_nest.find(cell->LU_id)->second);
    //cout<<"popCap for type "<<Traits->FT_type<<": "<<popCap<<endl;
}

void FT_pop::set_resCap(CCell* cell){
    // initialise values
    double sum_res=0.0;
    int cell_area=0;
    //go through all cells on grid
    for (unsigned int location=0; location<SRunPara::RunPara.GetSumCells(); ++location){
        // if cell is within foraging distance range --> add LU suitability for foraging and count nb. of cell
        //1. calculate distance to current cell:
        int x = CoreGrid.CellList[location]->x;// x location of matrix cell
        int y = CoreGrid.CellList[location]->y;// y location of matricx cell
        //distance of the two cells
        double dist_curr = sqrt((pow(x-cell->x,2)+pow(y-cell->y,2)));
        if (dist_curr <= this->Traits->dispmean){
            sum_res+=this->Traits->LU_suitability_forage.find(CoreGrid.CellList[location]->LU_id)->second;
            cell_area++;
        }
    }
    // output: sum/nb of cells --> foraging capacity in cell for the specific type
    resCap = sum_res/cell_area;

    //go through the map distance_LU
    /*for (auto var = cell->distance_LU.begin();
            var != cell->distance_LU.end(); ++var) {
        // check if distance is smaller than FT_trait Traits->trans_effect
        if (var->second.dist<Traits->trans_effect){
            //calculate trans_effect in cell for FT_pop
            double patch_size, patch_shape, patch_size_neighbour, patch_shape_neighbour;
            double land_use_suitability;
            double land_use_suitability_neighbour;
            double neighbour_patch_effect;
            double local_patch_effect;
            //Wie groß und welche Form hat der aktuelle patch? --> je größer und gleichmäßiger, desto geringer der Effekt? (kleinerer SHAPE + größere AREA = kleinerer Effekt)
            patch_size=cell->PID_def.Area;
            patch_shape=cell->PID_def.Shape;
            local_patch_effect=patch_size/(patch_size+patch_shape);
            //Wie groß und welche Form hat der andere patch? --> je größer und gleichmäßiger desto stärker der Effekt? (kleinere SHAPE + größere AREA = größerer Effekt)
            patch_size_neighbour=var->second.Area;
            patch_shape_neighbour=var->second.Shape;
            neighbour_patch_effect=patch_size_neighbour/(patch_size_neighbour+patch_shape_neighbour);
            //Je geeigneter die andere LU Klasse, desto geringer der Effekt
            land_use_suitability=Traits->LU_suitability.find(cell->LU_id)->second;
            land_use_suitability_neighbour=Traits->LU_suitability.find(var->first)->second;
            trans_effect+=var->second.dist*local_patch_effect*land_use_suitability*neighbour_patch_effect*land_use_suitability_neighbour;
            //cout<<"trans_effect for type "<<Traits->FT_type<<": "<<trans_effect<<endl;
        }
    }*/
}
// growth is not doing its thing
void FT_pop::growth(FT_pop* pop, double weather_year){
    // get the cell of the current population
    CCell* cell=pop->cell;
    vector<FT_pop*> curr_FT_list=cell->FT_pop_List;
    //
    // population function variables and parameters:
    int Ntj=pop->Pt;
    double Rj=pop->Traits->R;
    double trans_effect = 1-pop->trans_effect;
    double cj=pop->Traits->c;
    double bj = pop->Traits->b;
    int K = pop->nestCap;
    double C=28.0;
    double foraging_suitability=pop->resCap;
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
                //cout<<"sum of other FTs: "<<to_add<<endl;
                sum+=to_add;
            }
        }
    }
    //check function!
    Nt1j=(foraging_suitability*weather_year*trans_effect*Ntj*Rj)/(1+((Rj-1)*pow(((Ntj+sum)/K),bj)));
    //cout << "Nt: "<<Ntj<< " and Nt+1: " <<Nt1j<<endl;
    //update Pt1 value of Pop
    pop->Pt1=max(0,(int) Nt1j);
}

void FT_pop::dispersal(FT_pop* pop){
    //get the number of dispering individuals
    double fract;
    double P_disp_t; //Percent of dispersing individuals
    //int Disp_t; //number of dispersing individuals
    fract=(1.0*pop->Pt)/(1.0*pop->nestCap);
    P_disp_t=min(0.9, pop->Traits->mu*pow(fract,pop->Traits->omega));
    //Disp_t stores the number of dispersing individuals
    pop->Emmigrants=(int) floor(P_disp_t*pop->Pt);
    //Update the remaining individuals in cell
    pop->Pt=pop->Pt-pop->Emmigrants;
    // nb. of tries to find a suitable patch
    int tries=0;
    int emmig=pop->Emmigrants;
    //now disperse the individuals within the grid and if FT already exists in the cell: increase Pt1 OR initialise Ft in new cell
    for (emmig; emmig==0; emmig--){
        tries=0;
        bool cell_found=false;
        while (tries<10 && cell_found==false)
            {
            // direction of dispersal
            double alpha=2*3.1415*combinedLCG();
            double random=combinedLCG();
            double d; //distance
            int dx, dy;
            int new_xcoord, new_ycoord;

            while (random==0.0) {random=combinedLCG();}  //random shall not be 0

            double sigma=sqrt(log((pop->Traits->dispsd/pop->Traits->dispmean)*(pop->Traits->dispsd/pop->Traits->dispmean)+1));
            double mu=log(pop->Traits->dispmean)-0.5*sigma;
            d=exp(normcLCG(mu,sigma));

            //d=-(pop->Traits->D*log(random));
            dx=floor(sin(alpha)*d);
            dy=floor(cos(alpha)*d);
            // new cell
            new_xcoord=pop->xcoord+dx;                        //periodische Randbedingungen?
            new_ycoord=pop->ycoord+dy;

            // if new cell is within the grid
            if (new_xcoord<SRunPara::RunPara.xmax && new_ycoord<SRunPara::RunPara.ymax
                    && new_xcoord>=0 && new_ycoord>=0) {
                //pointer to cell
                CCell* cell_new = CoreGrid.CellList[new_xcoord*SRunPara::RunPara.xmax+new_ycoord];
                //check if FT can exist in new cell
                //get LU suitability of the land use class
                double LU_suitablity=pop->Traits->LU_suitability_nest.find(cell_new->LU_id)->second;
                //only if suitablity is higher than 0.5
                if (LU_suitablity>0.5){
                    // check if pop exists in the new cell
                    // if cell doesn't include a population of the current FT yet...
                    // Check if FT exists already in cell
                    map <int, int> existing_FT_pop = cell_new->FT_pop_sizes;
                    int current_ID = pop->Traits->FT_ID;
                    auto search = existing_FT_pop.find(current_ID);
                    // if not found initialize a new Pop of this FT
                    if(search == existing_FT_pop.end()){
                        int start_size = 1;
                        FT_pop* FTpop_tmp = new FT_pop(pop->Traits,cell_new,start_size);
                        cell_new->FT_pop_List.push_back(FTpop_tmp);
                        cell_new->FT_pop_sizes.insert(std::make_pair(FTpop_tmp->Traits->FT_ID, start_size));
                      } else {// if yes and if capacity is not reached yet: add it
                        for (unsigned pop_i=0; pop_i < cell_new->FT_pop_List.size(); pop_i++){
                            FT_pop* tmp_Pop=cell_new->FT_pop_List.at(pop_i);
                            // if it's the current FT add individual
                            if (tmp_Pop->Traits->FT_ID==current_ID && tmp_Pop->Pt<tmp_Pop->nestCap){
                                tmp_Pop->Immigrants++;
                                  }
                              }
                       }// end else
                    cell_found=true;
                }  //else: individual is dying since LU id is not suitable
            }
        tries++;
        }//end while tries <10
    }// end for loop
    pop->Emmigrants=0;//else: individual is outside of the grid or dying
}

void FT_pop::update_pop(FT_pop* pop){
    pop->Pt=pop->Pt1;
    pop->Pt1=0;
}

void FT_pop::update_pop_dispersal(FT_pop* pop){
    pop->Pt+=pop->Immigrants;
    pop->Immigrants=0;
}

void FT_pop::disturbance(FT_pop* pop){
    // random number for each PFT --> how much is population decreased by the disturbance?
    double dist_prob_pop=combinedLCG();
    // todo: disturbances should depend on LU class
    pop->Pt=pop->Pt*dist_prob_pop;
}

bool pairCompare( pair<size_t,int> i, pair<size_t,int> j)
{
return i.second < j.second;
}

