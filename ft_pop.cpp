#include "ft_pop.h"
#include "cell.h"
#include "runparameter.h"
#include <algorithm>
#include <iostream>
#include <numeric>
#include <iterator>
#include "lcg.h"
#include <math.h>
#include "gridenvironment.h"

using namespace std;

FT_pop::FT_pop()
{

}

FT_pop::FT_pop(shared_ptr<FT_traits> Traits, shared_ptr<CCell> cell, int n):
  cell(nullptr), Traits(Traits), xcoord(0), ycoord(0), nestCap(0), trans_effect_nest(0),
  trans_effect_res(0),  Pt(0), Pt1(0), Emmigrants(0), Immigrants(0)
{
    //establish this FT on cell
    setCell(cell);
    // calculate trans_effect for the pop
    set_trans_effect(cell);
    // calculate nesting capacity
    set_nestCap(cell);
    //calculate maximal nesting capacity in dispersal area
    set_max_nestCap(cell);
    // calculate resource capacity
    set_resCap(cell);
    Pt=n*nestCap/100;// nest capacity is a int value; 100 is the normal max. nest capacity

} // end constructor

void FT_pop::setCell(shared_ptr<CCell> cell){
    // if cell not defined
    if (this->cell==nullptr){
        // define cell as cell
        this->cell=cell;
        xcoord=cell->x;
        ycoord=cell->y;
        //cout<<"Coordinates for type "<<Traits->FT_type<<": "<<xcoord<<"  "<<ycoord<<endl;
    }// end if not defined
}//end setCell

void FT_pop::set_trans_effect(shared_ptr<CCell> cell){

    //define if the cell is a transition zone cell
    if(cell->TZ==true){
        trans_effect_res=Traits->trans_effect_res;
        trans_effect_nest=Traits->trans_effect_nest;
    }

}

void FT_pop::set_nestCap(shared_ptr<CCell> cell){
    //int x = nrand(100);
    int x=100; //todo check how many nests could be within 10x10m
    if(cell->TZ==true){
        nestCap=int(floor(x*(this->Traits->LU_suitability_nest.find(cell->LU_id)->second+trans_effect_nest)));
    } else nestCap=int(floor(x*this->Traits->LU_suitability_nest.find(cell->LU_id)->second));
}

void FT_pop::set_max_nestCap(shared_ptr<CCell> cell){
    double max_nest_suitability=0.0;
    int dispersal = int(floor(this->Traits->dispmean));
    //start cell of dispersal area
    int zi_start = cell->x - dispersal;
    if (zi_start<0) zi_start=0;
    int zimax = std::min(cell->x+dispersal, SRunPara::RunPara.xmax);
    int zj_start = cell->y - dispersal;
    if (zj_start<0) zj_start=0;
    int zjmax = std::min(cell->y + dispersal, SRunPara::RunPara.xmax);
    //
    for (int zi=zi_start; zi < zimax; zi++)
      for (int zj=zj_start; zj < zjmax ; zj++)
      {
          double dist_curr = sqrt((pow(zi-cell->x,2)+pow(zj-cell->y,2)));
          if (dist_curr <= this->Traits->dispmean){
              double nest_suitability=this->Traits->LU_suitability_nest.find(CoreGrid.CellList[zi*SRunPara::RunPara.xmax+zj]->LU_id)->second;
              if (cell->TZ==true) nest_suitability=nest_suitability + trans_effect_nest;
              max_nest_suitability=max(nest_suitability, max_nest_suitability);
          }
      }
    MaxNestSuitability=max_nest_suitability;
}

void FT_pop::set_resCap(shared_ptr<CCell> cell){
    // initialise values
    double sum_res=0.0;
    int cell_area=0;
    //go through all cells on square around cell
    int dispersal = int(floor(this->Traits->dispmean));
    //start cell of dispersal area
    int zi_start = cell->x - dispersal;
    if (zi_start<0) zi_start=0;
    int zimax = std::min(cell->x+dispersal, SRunPara::RunPara.xmax);

    int zj_start = cell->y - dispersal;
    if (zj_start<0) zj_start=0;
    int zjmax = std::min(cell->y + dispersal, SRunPara::RunPara.xmax);
    // todo account for TZ effect
    for (int zi=zi_start; zi < zimax; zi++)
      for (int zj=zj_start; zj < zjmax ; zj++)
      {
          double dist_curr = sqrt((pow(zi-cell->x,2)+pow(zj-cell->y,2)));
          if (dist_curr <= this->Traits->dispmean){
              if(cell->TZ) sum_res+=this->trans_effect_res;
              sum_res+=this->Traits->LU_suitability_forage.find(CoreGrid.CellList[zi*SRunPara::RunPara.xmax+zj]->LU_id)->second;
              cell_area++;
          }
      }
    //cout<<"sum of resources"<<sum_res<<endl;
    //cout<<"cell number"<<cell_area<<endl;
    // output: sum/nb of cells --> foraging capacity in cell for the specific type
    if (cell_area!=0){
        resCap = sum_res/cell_area;
    } else resCap=0.0;
}

void FT_pop::growth(std::shared_ptr<FT_pop> pop, double weather_year){
    // get the cell of the current population
    shared_ptr<CCell> cell=pop->cell;
    vector<std::shared_ptr<FT_pop>> curr_FT_list=cell->FT_pop_List;
    //
    // population function variables and parameters:
    int Ntj=pop->Pt;
    double Rj=pop->Traits->R;
    double cj=pop->Traits->c;
    double bj = pop->Traits->b;
    int K = pop->nestCap;
    //calculate C: sum of cs of FTs in cell
    // go through FT_pop_List
    double C=0;
    for (unsigned i=0; i < curr_FT_list.size(); i++) {
        std::shared_ptr<FT_pop> curr_Pop=curr_FT_list.at(i);
    // for each FT -> get Traits->c and calculate sum --> this is C
        C=C+curr_Pop->Traits->c;
    }
    // C is now sum of Trait c of FTs in cell
    double foraging_suitability=pop->resCap;
    // result
    double Nt1j;

    //sum over all FT_pop_List
    double sum=0.0;
    if(!curr_FT_list.empty()){
        for (unsigned i=0; i < curr_FT_list.size(); i++) {
            std::shared_ptr<FT_pop> curr_Pop=curr_FT_list.at(i);
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
    Nt1j=(foraging_suitability*weather_year*Ntj*Rj)/(1+((Rj-1)*pow(((Ntj+sum)/K),bj)));
    //cout << "Nt: "<<Ntj<< " and Nt+1: " <<Nt1j<<endl;
    //update Pt1 value of Pop
    pop->Pt1=max(0,int(floor(Nt1j)));
    cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
}

void FT_pop::dispersal(std::shared_ptr<FT_pop> pop){
    //get the number of dispering individuals
    double fract;
    double P_disp_t; //Percent of dispersing individuals
    //int Disp_t; //number of dispersing individuals
    fract=(1.0*pop->Pt)/(1.0*pop->nestCap);
    P_disp_t=min(0.9, pop->Traits->mu*pow(fract,pop->Traits->omega));
    //Disp_t stores the number of dispersing individuals
    pop->Emmigrants=int (floor(P_disp_t*pop->Pt));
    //Update the remaining individuals in cell
    pop->Pt=pop->Pt-pop->Emmigrants;
    // nb. of tries to find a suitable patch
    int tries=0;
    int emmigrants=pop->Emmigrants;
    //now disperse the individuals within the grid and if FT already exists in the cell: increase Pt1 OR initialise Ft in new cell
    for (int emmig=emmigrants; emmig>0; emmig--){
        // highest potential nest capacity:
        double max_nest_suit=pop->MaxNestSuitability;
        bool cell_found=false;
        int max_tries=1000;
        while (cell_found==false && tries < max_tries){
            // get a cell to disperse to
            // direction of dispersal
            double alpha=2*3.1415*combinedLCG();
            //double random=combinedLCG();
            double d; //distance
            int dx, dy;
            int new_xcoord, new_ycoord;
            // distance
            double sigma=sqrt(log((pop->Traits->dispsd/pop->Traits->dispmean)*(pop->Traits->dispsd/pop->Traits->dispmean)+1));
            double mu=log(pop->Traits->dispmean)-0.5*sigma;
            d=exp(normcLCG(mu,sigma));
            // resulting cell
            dx=int(floor(sin(alpha)*d));
            dy=int(floor(cos(alpha)*d));
            // new cell
            new_xcoord=pop->xcoord+dx;                        //periodische Randbedingungen?
            new_ycoord=pop->ycoord+dy;

            // if new cell is within the grid
            if (new_xcoord<SRunPara::RunPara.xmax && new_ycoord<SRunPara::RunPara.ymax
                    && new_xcoord>=0 && new_ycoord>=0) {
                //pointer to cell
                shared_ptr<CCell> cell_new = CoreGrid.CellList[new_xcoord*SRunPara::RunPara.xmax+new_ycoord];
                //check if LU suitability for nesting is max_nest_cap
                double LU_suitability=pop->Traits->LU_suitability_nest.find(cell_new->LU_id)->second;
                // if the cells land use suitability is the same or higher as the maximal nest suitability --> immigrate
                if (LU_suitability>=max_nest_suit){
                    // check if pop exists in the new cell
                    // if cell doesn't include a population of the current FT yet...
                    // Check if FT exists already in cell
                    map <int, int> existing_FT_pop = cell_new->FT_pop_sizes;
                    int current_ID = pop->Traits->FT_ID;
                    auto search = existing_FT_pop.find(current_ID);
                    // if not found initialize a new Pop of this FT
                    if(search == existing_FT_pop.end()){
                        int start_size = 1;
                        std::shared_ptr<FT_pop> FTpop_tmp = std::make_shared< FT_pop >(pop->Traits,cell_new,start_size);
                        //FT_pop* FTpop_tmp = new FT_pop();
                        //FT_pop* FTpop_tmp = new FT_pop(pop->Traits,cell_new,start_size);
                        cell_new->FT_pop_List.push_back(FTpop_tmp);
                        cell_new->FT_pop_sizes.insert(std::make_pair(FTpop_tmp->Traits->FT_ID, start_size));
                        cell_found=true;
                      } else {// if yes and if capacity is not reached yet: add it
                        for (unsigned pop_i=0; pop_i < cell_new->FT_pop_List.size(); pop_i++){
                            std::shared_ptr<FT_pop> tmp_Pop=cell_new->FT_pop_List.at(pop_i);
                            // if it's the current FT add individual
                            if (tmp_Pop->Traits->FT_ID==current_ID && tmp_Pop->Pt<tmp_Pop->nestCap){
                                tmp_Pop->Immigrants++;
                                cell_found=true;
                                }
                        }// add immigrant only if capacity is not reached yet; else search for new cell
                     }// end else
                } else {// end if cell is one of the most suitable cells
                    // with increasing probability individuals also excepts less suitable cell for immigration
                    double prob_take_less = tries/max_tries;
                    double lesser = LU_suitability/max_nest_suit;
                    // generate random number
                    double random=combinedLCG();
                    if ((LU_suitability !=0.0) & (random<prob_take_less*lesser)){
                        // check if pop exists in the new cell
                        // if cell doesn't include a population of the current FT yet...
                        // Check if FT exists already in cell
                        map <int, int> existing_FT_pop = cell_new->FT_pop_sizes;
                        int current_ID = pop->Traits->FT_ID;
                        auto search = existing_FT_pop.find(current_ID);
                        // if not found initialize a new Pop of this FT
                        if(search == existing_FT_pop.end()){
                            int start_size = 1;
                            std::shared_ptr<FT_pop> FTpop_tmp = std::make_shared< FT_pop >(pop->Traits,cell_new,start_size);
                            //FT_pop* FTpop_tmp = new FT_pop();
                            //FT_pop* FTpop_tmp = new FT_pop(pop->Traits,cell_new,start_size);
                            cell_new->FT_pop_List.push_back(FTpop_tmp);
                            cell_new->FT_pop_sizes.insert(std::make_pair(FTpop_tmp->Traits->FT_ID, start_size));
                            cell_found=true;
                          } else {// end if individual takes a less suitable patch
                            // if FT already exists and capacity is not reached yet: add it
                            for (unsigned pop_i=0; pop_i < cell_new->FT_pop_List.size(); pop_i++){
                                std::shared_ptr<FT_pop> tmp_Pop=cell_new->FT_pop_List.at(pop_i);
                                // if it's the current FT add individual
                                if (tmp_Pop->Traits->FT_ID==current_ID && tmp_Pop->Pt<tmp_Pop->nestCap){
                                    tmp_Pop->Immigrants++;
                                    cell_found=true;
                                      }// end if capacity is not yet reached
                                  }// end loop over all FTs in cell
                           }// end else (if FT exists)
                    }  //end if individual takes a less suitable cell (only if capacity is not yet reached; otherwise search new
                    }// end else (if not suitable and does not take a less suitable cell)
                }// one try; end if random cell is within grid
            tries++;
        }// end while after max tries --> individual dies
    }// end for all emmigrants
    pop->Emmigrants=0;//else: individual is outside of the grid or dying as not finding a nesting site
}

void FT_pop::update_pop(std::shared_ptr<FT_pop> pop){
    pop->Pt=pop->Pt1;
    pop->Pt1=0;
    shared_ptr<CCell> cell=pop->cell;
    cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
}

void FT_pop::update_pop_dispersal(std::shared_ptr<FT_pop> pop){
    pop->Pt+=pop->Immigrants;
    pop->Immigrants=0;
    shared_ptr<CCell> cell=pop->cell;
    cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
}

void FT_pop::disturbance(std::shared_ptr<FT_pop> pop){
    // depends on susceptibility
    if (combinedLCG()<pop->Traits->dist_eff) pop->Pt=0;
    // pop->Pt=int(floor(pop->Pt*dist_prob_pop));
    shared_ptr<CCell> cell=pop->cell;
    cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
}

bool pairCompare( pair<size_t,int> i, pair<size_t,int> j)
{
return i.second < j.second;
}

