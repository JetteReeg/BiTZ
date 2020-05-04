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
    Pt=n;// nest capacity is a int value; 100 is the normal max. nest capacity

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
    int x=547; //after Potts & Willmer 1997; Halictus rubicundus
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

void FT_pop::set_foraging_individuals(std::shared_ptr<FT_pop> pop){
    //go through all cells on square around cell
    int dispersal = int(floor(pop->Traits->dispmean));
    //start cell of dispersal area
    int zi_start = pop->cell->x - dispersal;
    if (zi_start<0) zi_start=0;
    int zimax = std::min(pop->cell->x+dispersal, SRunPara::RunPara.xmax);
    int zj_start = pop->cell->y - dispersal;
    if (zj_start<0) zj_start=0;
    int zjmax = std::min(pop->cell->y + dispersal, SRunPara::RunPara.xmax);
    for (int zi=zi_start; zi < zimax; zi++)
      for (int zj=zj_start; zj < zjmax ; zj++)
      {
          double dist_curr = sqrt((pow(zi-pop->cell->x,2)+pow(zj-pop->cell->y,2)));
          // if the cell is within the foraging distance;
          // add the FT to the FT_pop_sizes_foraging;
          if (dist_curr <= pop->Traits->dispmean){
              //pointer to cell
              shared_ptr<CCell> foraging_cell = CoreGrid.CellList[zi*SRunPara::RunPara.xmax+zj];
              // new if not existing, or add
              auto search = foraging_cell->FT_pop_sizes_foraging.find(pop->Traits->FT_ID);
              if(search == foraging_cell->FT_pop_sizes_foraging.end()){
                  foraging_cell->FT_pop_sizes_foraging.insert(std::make_pair(pop->Traits->FT_ID, pop->Pt));
              } else{
                  foraging_cell->FT_pop_sizes_foraging.find(pop->Traits->FT_ID)->second+=pop->Pt;
                }
          }// end if cell is within foraging range
      } // end for all foraging quadrat cells
}

void FT_pop::growth(std::shared_ptr<FT_pop> pop, double weather_year){
    // get the cell of the current population
    shared_ptr<CCell> cell=pop->cell;
    vector<std::shared_ptr<FT_pop>> curr_FT_list=cell->FT_pop_List;
    int Ntj=pop->Pt;
    double Rj=pop->Traits->R;
    double cj=pop->Traits->c;
    double bj = pop->Traits->b;
    int K = pop->nestCap;
    //
    int dispersal = int(floor(pop->Traits->dispmean)); // foraging distance
    int count_cells=0;// nb of cells within foraging distance
    double res_comp=0.0; // competition for resources
    double resource_uptake=0.0;//resource uptake
    double sum_res=0.0; // sum without competition impacts
    //
    // within the foraging range of the FT: calculate the interspecific competition for resources in each cell
    //go through all cells on square around cell
    //start cell of dispersal area
    int zi_start = pop->cell->x - dispersal;
    if (zi_start<0) zi_start=0;
    int zimax = std::min(pop->cell->x+dispersal, SRunPara::RunPara.xmax);
    int zj_start = pop->cell->y - dispersal;
    if (zj_start<0) zj_start=0;
    int zjmax = std::min(pop->cell->y + dispersal, SRunPara::RunPara.xmax);
    // loop over foraging distance
    for (int zi=zi_start; zi < zimax; zi++)
      for (int zj=zj_start; zj < zjmax ; zj++)
      {
          double dist_curr = sqrt((pow(zi-pop->cell->x,2)+pow(zj-pop->cell->y,2)));
          // if the cell is within the foraging distance;
          if (dist_curr <= pop->Traits->dispmean){
              // link to the map
              //pointer to cell
              shared_ptr<CCell> foraging_cell = CoreGrid.CellList[zi*SRunPara::RunPara.xmax+zj];
              // within foraging cell: calculate the resource competition factor and resource uptake
              double C_res=0; // sum of all c-values
              int sum_pop=0;
              // loop over all FT_pop_sizes_foraging entries
              for(auto it=foraging_cell->FT_pop_sizes_foraging.begin(); it!=foraging_cell->FT_pop_sizes_foraging.end(); it++) {
                    // get the flying period of the FT
                    string ID = to_string(it->first);
                    if(FT_traits::FtLinkList.find(ID)->second->flying_period==3){
                        C_res+=FT_traits::FtLinkList.find(ID)->second->c;
                        sum_pop+=it->second;
                        } else {
                        if(FT_traits::FtLinkList.find(ID)->second->flying_period == pop->Traits->flying_period ||
                                FT_traits::FtLinkList.find(ID)->second->flying_period == 3) {
                                C_res+=FT_traits::FtLinkList.find(ID)->second->c;
                                sum_pop+=it->second;
                            }
                        }
                    }
               // C_es is now sum of Trait c of all FTs in cell with the same flying period as the current pop FT
              double sum_res_comp=0.0; // sum of all competition impacts
              //double sum_pop=0.0; // sum of all population sizes

              for(auto it=foraging_cell->FT_pop_sizes_foraging.begin(); it!=foraging_cell->FT_pop_sizes_foraging.end(); it++) {
                  string ID = to_string(it->first);
                  cout<<"flyping period: "<<FT_traits::FtLinkList.find(ID)->second->flying_period<<" compared with: "<<pop->Traits->flying_period<<endl;
                  cout<<"FT ID: "<<it->first <<" compared with: "<<pop->Traits->FT_ID<<endl;
                  // if pop is flying over the whole year or in both periods; consider all populations in the cell
                  if (pop->Traits->flying_period==3 && it->first!=pop->Traits->FT_ID) {
                      double ci=FT_traits::FtLinkList.find(ID)->second->c;
                      /*double suitability=FT_traits::FtLinkList.find(ID)->second->LU_suitability_forage.find(foraging_cell->LU_id)->second;
                      if(foraging_cell->TZ) suitability+=FT_traits::FtLinkList.find(ID)->second->trans_effect_res;
                      */
                      double suitability=1.0;
                      int Ni = it->second;
                      double prop_N = 1.0*Ni/sum_pop;
                      cout<<"ci: "<<ci<<" cj: "<<cj<<" C_res: "<<C_res<<endl;
                      cout<<"prop_N: "<<prop_N<<" suitability: "<<suitability<<endl;

                      double to_add=(1+((cj-ci)/C_res))*prop_N*suitability;
                      //cout<<"sum of other FTs: "<<to_add<<endl;
                      sum_res_comp+=to_add;
                      //sum_pop+=it->second; // add the population size of the competition FT
                  }
                  if(pop->Traits->flying_period!=3 && it->first!=pop->Traits->FT_ID &&
                          // only consider the populations with the same flying period
                          (FT_traits::FtLinkList.find(ID)->second->flying_period == pop->Traits->flying_period ||
                           FT_traits::FtLinkList.find(ID)->second->flying_period == 3)){
                      double ci=FT_traits::FtLinkList.find(ID)->second->c;
                      /*double suitability=FT_traits::FtLinkList.find(ID)->second->LU_suitability_forage.find(foraging_cell->LU_id)->second;
                      if(foraging_cell->TZ) suitability+=FT_traits::FtLinkList.find(ID)->second->trans_effect_res;
                      */
                      double suitability=1.0;
                      int Ni = it->second;
                      double prop_N = 1.0*Ni/sum_pop;
                      cout<<"ci: "<<ci<<" cj: "<<cj<<" C_res: "<<C_res<<endl;
                      cout<<"prop_N: "<<prop_N<<" suitability: "<<suitability<<endl;
                      double to_add=(1+((cj-ci)/C_res))*prop_N*suitability;
                      //cout<<"sum of other FTs: "<<to_add<<endl;
                      sum_res_comp+=to_add;
                      //sum_pop+=it->second;// add the population size of the competition FT
                  }
                }
              // add the whole population size of the same FT ID (no intraspecific competition) to both values
              //sum_res_comp+=foraging_cell->FT_pop_sizes_foraging.find(pop->Traits->FT_ID)->second;
              //sum_pop+=foraging_cell->FT_pop_sizes_foraging.find(pop->Traits->FT_ID)->second;
              // the relation gives the competition factor for this specific cell
              /*if (sum_res_comp>0)res_comp+=(sum_res_comp/sum_pop);
                else res_comp+=1;*/
              // to calculate the competition per cell, multiply by LU suitability for foraging factor and sum it up for all foraging cells
              double uptake = pop->Traits->LU_suitability_forage.find(foraging_cell->LU_id)->second;
              if(foraging_cell->TZ) uptake+=pop->trans_effect_res;
              cout<<"resource uptake without competiton: "<<uptake<<endl;
              // proportion of selected FT population in the cell
              double prop_N = 1.0*foraging_cell->FT_pop_sizes_foraging.find(pop->Traits->FT_ID)->second/sum_pop;
              cout<<"own proportion in cell: "<<prop_N<<endl;
              double to_add = prop_N;
              sum_res_comp+=to_add;
              cout<< "competition effect: "<<sum_res_comp<<endl;
              if (sum_res_comp>0)resource_uptake+=(sum_res_comp*uptake);
                else resource_uptake+=(1.0*uptake);
              sum_res+=uptake;
              cout<<"resource uptake in cell: "<<resource_uptake<<endl;
              cout<<"resource uptake without competiton: "<<sum_res<<endl;
              count_cells++;
          }
      }

    // put it in relation to the foraged cells
    res_comp/=count_cells;
    resource_uptake/=count_cells;
    sum_res/=count_cells;
    cout<<"mean resource uptake with competition: "<<resource_uptake<<endl;
    cout<<"mean resource uptake without competition: "<<sum_res<<endl;
    cout<<"resource capacity: "<<pop->resCap<<endl;

    //cout<<"competition: "<<pop->Traits->c<<" Resource competition: "<<res_comp << "Resource uptake: "<<resource_uptake<<endl;
    //
    // population function variables and parameters:

    // interspecific competition
    //calculate C: sum of cs of FTs in cell
    // only count FTs with the same flying period
    // go through FT_pop_List
    double C=0;
    for (unsigned i=0; i < curr_FT_list.size(); i++) {
        std::shared_ptr<FT_pop> curr_Pop=curr_FT_list.at(i);
        // for each FT -> get Traits->c and calculate sum --> this is C; but only for FTs with the same flying period
        if (pop->Traits->flying_period==3) {
            C=C+curr_Pop->Traits->c;
        } else {
            if(curr_Pop->Traits->flying_period == pop->Traits->flying_period || curr_Pop->Traits->flying_period == 3) C=C+curr_Pop->Traits->c;
            }
    }
    // C is now sum of Trait c of FTs in cell
    double foraging_suitability=resource_uptake;//pop->resCap;
    // result
    double Nt1j;

    //sum over all FT_pop_List
    double sum=0.0;
    if(!curr_FT_list.empty()){
        for (unsigned i=0; i < curr_FT_list.size(); i++) {
            std::shared_ptr<FT_pop> curr_Pop=curr_FT_list.at(i);
            // if pop is flying over the whole year or in both periods; consider all populations in the cell
            if (pop->Traits->flying_period==3 && curr_Pop->Traits->FT_ID!=pop->Traits->FT_ID) {
                double ci=curr_Pop->Traits->c;
                int Ni = curr_Pop->Pt;
                double to_add=(1+((cj-ci)/C))*Ni;
                //cout<<"sum of other FTs: "<<to_add<<endl;
                sum+=to_add;
            }
            if(pop->Traits->flying_period!=3 && curr_Pop->Traits->FT_ID!=pop->Traits->FT_ID &&
                    // only consider the populations with the same flying period
                    (curr_Pop->Traits->flying_period == pop->Traits->flying_period || curr_Pop->Traits->flying_period == 3)){
                double ci=curr_Pop->Traits->c;
                int Ni = curr_Pop->Pt;
                double to_add=(1+((cj-ci)/C))*Ni; // TODO control if function is correct!
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
        int max_tries=SRunPara::RunPara.max_search_attempts;
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
                }
                // if a new cell wasn't found until now
                if (cell_found==false){
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
                    }// end if no cell was found in the first try
                }// one try; end if random cell is within grid
            tries++;
        }// end while after max tries --> individual dies
    }// end for all emmigrants
    pop->Emmigrants=0;//individuals which haven't found a new cell within the max_search_attempts are dying (or assumed to have migrated outside the grid)
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
    pop->Pt*=(1.0-pop->Traits->dist_eff);
    // pop->Pt=int(floor(pop->Pt*dist_prob_pop));
    shared_ptr<CCell> cell=pop->cell;
    cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
}

bool pairCompare( pair<size_t,int> i, pair<size_t,int> j)
{
return i.second < j.second;
}

