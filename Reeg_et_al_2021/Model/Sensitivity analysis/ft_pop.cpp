/**\file
 * \brief ft_pop.cpp Population processes and functions of FTs in a cell
*/
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
#include <ctime>

using namespace std;

//! constructor
FT_pop::FT_pop()
{

}

//! constructor of FT populations on the grid with all variables
FT_pop::FT_pop(shared_ptr<FT_traits> Traits, shared_ptr<CCell> cell, int n):
  cell(nullptr), Traits(Traits), xcoord(0), ycoord(0), nestCap(0),
  trans_effect_res(0), trans_effect_nest(0),  Pt(0), Pt1(0), Emmigrants(0), Immigrants(0)
{
    //!establish this FT on cell
    setCell(cell);
    //! calculate trans_effect for the pop
    set_trans_effect(cell);
    //! calculate nesting capacity
    set_nestCap(cell);
    //! calculate maximal nesting capacity in dispersal area
    set_max_nestCap(cell);
    //! set the initial population size
    Pt=n;

} // end constructor


/**
 * @brief FT_pop::setCell: function to initialise a population within a cell
 * if the cell is not yet defined, it will be defined and the FT population will get xy-coordinates
 * @param cell
 */
void FT_pop::setCell(shared_ptr<CCell> cell){
    //! if cell not defined
    if (this->cell==nullptr){
        //! define cell as cell
        this->cell=cell;
        //! set the coordinates of the cell
        xcoord=cell->x;
        ycoord=cell->y;
    }// end if not defined
}//end setCell

/**
 * @brief FT_pop::set_trans_effect: set the transition zone effect
 * only if the cell is defined as a transition zone cell
 * transition zone effects on resources and nesting are defined
 * @param cell
 */
void FT_pop::set_trans_effect(shared_ptr<CCell> cell){
    //! define if the cell is a transition zone cell
    //! only if the cell is defined as a realized transition zone cell
    if(cell->TZ==true){
        trans_effect_res=Traits->trans_effect_res;
        trans_effect_nest=Traits->trans_effect_nest;
    }

}

/**
 * @brief FT_pop::set_nestCap: Nest capacity is defined for the FT in the specific cell.
 * It depends on the FT specific nesting suitability in the specific land use class and
 * potential transition zone effects.
 * In general, the capacity is 54.7 individuals per m² after Potts & Willmer 1997
 * @param cell
 */
void FT_pop::set_nestCap(shared_ptr<CCell> cell){
    int x=int(floor(SRunPara::RunPara.scaling*SRunPara::RunPara.scaling*54.7));
    if(cell->TZ==true){
        nestCap=int(floor(x*(this->Traits->LU_suitability_nest.find(cell->LU_id)->second+trans_effect_nest)));
    } else nestCap=int(floor(x*this->Traits->LU_suitability_nest.find(cell->LU_id)->second));
}

/**
 * @brief FT_pop::set_max_nestCap: Set the maximal nest capacity that is found in the foraging
 * range of the specific FT.
 * @param cell
 */
void FT_pop::set_max_nestCap(shared_ptr<CCell> cell){
    double max_nest_suitability=0.0;
    int dispersal = int(floor(this->Traits->dispmean));
    // start cell of dispersal area
    int zi_start = cell->x - dispersal;
    if (zi_start<0) zi_start=0;
    // end cell of dispersal area
    int zimax = std::min(cell->x+dispersal, SRunPara::RunPara.xmax);
    // start cell of dispersal area
    int zj_start = cell->y - dispersal;
    if (zj_start<0) zj_start=0;
    // end cell of dispersal area
    int zjmax = std::min(cell->y + dispersal, SRunPara::RunPara.xmax);
    // go through each cell
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
    // set the maximal nest suitability value found within the dispersal range
    MaxNestSuitability=max_nest_suitability;
}

/**
 * @brief FT_pop::set_foraging_individuals: Determine how many FTs/individuals are foraging within the same cell at the same time.
 * For each FT population @param std::shared_ptr<FT_pop> pop , the function goes through all cells within the foraging range and adds the
 * population size to the specific map which includes all competing FTs in the specific cell with the same
 * flying period (1, 2 or 3).
 * @param pop
 */
void FT_pop::set_foraging_individuals(std::shared_ptr<FT_pop> pop){
    //go through all cells on square around cell
    int dispersal = int(floor(pop->Traits->dispmean));
    //start cell of dispersal area x
    int zi_start = pop->cell->x - dispersal;
    if (zi_start<0) zi_start=0;
    //end cell of dispersal area x
    int zimax = std::min(pop->cell->x+dispersal, SRunPara::RunPara.xmax);
    //start cell of dispersal area y
    int zj_start = pop->cell->y - dispersal;
    if (zj_start<0) zj_start=0;
    //end cell of dispersal area y
    int zjmax = std::min(pop->cell->y + dispersal, SRunPara::RunPara.xmax);
    // flying period of the FT
    int flying_period_j=pop->Traits->flying_period;
    switch(flying_period_j){
      case 1:
        for (int zi=zi_start; zi < zimax; zi++)
          for (int zj=zj_start; zj < zjmax ; zj++)
          {
              double dist_curr = sqrt((pow(zi-pop->cell->x,2)+pow(zj-pop->cell->y,2)));
              // if the cell is within the foraging distance;
              // add the FT population to the FT_pop_sizes_foraging depending of the flying period
              if (dist_curr <= pop->Traits->dispmean){
                  //pointer to cell
                  shared_ptr<CCell> foraging_cell = CoreGrid.CellList[zi*SRunPara::RunPara.xmax+zj];
                  // new if not existing, or add
                  auto search = foraging_cell->FT_pop_sizes_foraging_1.find(pop->Traits->FT_ID);
                  if(search == foraging_cell->FT_pop_sizes_foraging_1.end()){
                      foraging_cell->FT_pop_sizes_foraging_1.insert(std::make_pair(pop->Traits->FT_ID, pop->Pt));
                  } else{
                      foraging_cell->FT_pop_sizes_foraging_1.find(pop->Traits->FT_ID)->second+=pop->Pt;
                    }
                  //new if not existing or add
                  auto search1 = foraging_cell->FT_pop_sizes_foraging_3.find(pop->Traits->FT_ID);
                  if(search1 == foraging_cell->FT_pop_sizes_foraging_3.end()){
                      foraging_cell->FT_pop_sizes_foraging_3.insert(std::make_pair(pop->Traits->FT_ID, pop->Pt));
                  } else{
                      foraging_cell->FT_pop_sizes_foraging_3.find(pop->Traits->FT_ID)->second+=pop->Pt;
                    }
              }// end if cell is within foraging range
          } // end for all foraging quadrat cells
        break;
      case 2:
        for (int zi=zi_start; zi < zimax; zi++)
          for (int zj=zj_start; zj < zjmax ; zj++)
          {
              double dist_curr = sqrt((pow(zi-pop->cell->x,2)+pow(zj-pop->cell->y,2)));
              // if the cell is within the foraging distance;
              // add the FT to the FT_pop_sizes_foraging depending of the flying period
              if (dist_curr <= pop->Traits->dispmean){
                  //pointer to cell
                  shared_ptr<CCell> foraging_cell = CoreGrid.CellList[zi*SRunPara::RunPara.xmax+zj];
                  // new if not existing, or add
                  auto search = foraging_cell->FT_pop_sizes_foraging_2.find(pop->Traits->FT_ID);
                  if(search == foraging_cell->FT_pop_sizes_foraging_2.end()){
                      foraging_cell->FT_pop_sizes_foraging_2.insert(std::make_pair(pop->Traits->FT_ID, pop->Pt));
                  } else{
                      foraging_cell->FT_pop_sizes_foraging_2.find(pop->Traits->FT_ID)->second+=pop->Pt;
                    }
                  // new if not existing or add
                  auto search1 = foraging_cell->FT_pop_sizes_foraging_3.find(pop->Traits->FT_ID);
                  if(search1 == foraging_cell->FT_pop_sizes_foraging_3.end()){
                      foraging_cell->FT_pop_sizes_foraging_3.insert(std::make_pair(pop->Traits->FT_ID, pop->Pt));
                  } else{
                      foraging_cell->FT_pop_sizes_foraging_3.find(pop->Traits->FT_ID)->second+=pop->Pt;
                    }
              }// end if cell is within foraging range
          } // end for all foraging quadrat cells
        break;
      case 3:
        for (int zi=zi_start; zi < zimax; zi++)
          for (int zj=zj_start; zj < zjmax ; zj++)
          {
              double dist_curr = sqrt((pow(zi-pop->cell->x,2)+pow(zj-pop->cell->y,2)));
              // if the cell is within the foraging distance;
              // add the FT to the FT_pop_sizes_foraging depending of the flying period
              if (dist_curr <= pop->Traits->dispmean){
                  //pointer to cell
                  shared_ptr<CCell> foraging_cell = CoreGrid.CellList[zi*SRunPara::RunPara.xmax+zj];
                  // new if not existing, or add
                  auto search = foraging_cell->FT_pop_sizes_foraging_1.find(pop->Traits->FT_ID);
                  if(search == foraging_cell->FT_pop_sizes_foraging_1.end()){
                      foraging_cell->FT_pop_sizes_foraging_1.insert(std::make_pair(pop->Traits->FT_ID, pop->Pt));
                  } else{
                      foraging_cell->FT_pop_sizes_foraging_1.find(pop->Traits->FT_ID)->second+=pop->Pt;
                    }
                  // new if not existing, or add
                  auto search1 = foraging_cell->FT_pop_sizes_foraging_2.find(pop->Traits->FT_ID);
                  if(search1 == foraging_cell->FT_pop_sizes_foraging_2.end()){
                      foraging_cell->FT_pop_sizes_foraging_2.insert(std::make_pair(pop->Traits->FT_ID, pop->Pt));
                  } else{
                      foraging_cell->FT_pop_sizes_foraging_2.find(pop->Traits->FT_ID)->second+=pop->Pt;
                    }
                  // new if not existing, or add
                  auto search2 = foraging_cell->FT_pop_sizes_foraging_3.find(pop->Traits->FT_ID);
                  if(search2 == foraging_cell->FT_pop_sizes_foraging_3.end()){
                      foraging_cell->FT_pop_sizes_foraging_3.insert(std::make_pair(pop->Traits->FT_ID, pop->Pt));
                  } else{
                      foraging_cell->FT_pop_sizes_foraging_3.find(pop->Traits->FT_ID)->second+=pop->Pt;
                    }
              }// end if cell is within foraging range
          } // end for all foraging quadrat cells
        break;
  }
}

/**
 * @brief FT_pop::growth: Calculation of the growth for each FT_pop.
 * The function goes through each cell and in each cell through all FT populations.
 * STEP 1: within the foraging range of the FT: calculate the interspecific competition for resources in each cell
 * STEP 2: calculate the interspecific  nest competition
 * STEP 3: calculate the actual growth
 * @param weather_year
 */
void FT_pop::growth(double weather_year){
    // go through all grid cells
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                std::shared_ptr<FT_pop> pop=cell->FT_pop_List.at(pop_i);
                //
                // variables needed
                vector<std::shared_ptr<FT_pop>> curr_FT_list=cell->FT_pop_List; // list of FT populations in cell
                int Ntj=pop->Pt; // current population size of j
                double Rj=pop->Traits->R; // growth rate of j
                double cj=pop->Traits->c; // competition factor of j
                double bj = pop->Traits->b; // density compensation factor of j
                double C=0; // cummulative competition factors
                int K = pop->nestCap; // nest capacity of j
                int dispersal = int(floor(pop->Traits->dispmean)); // foraging distance of j
                int count_cells=0;// nb of cells within foraging distance
                double resource_uptake=0.0;//mean resource uptake

                // STEP 1: within the foraging range of the FT: calculate the interspecific competition for resources in each cell
                //start cell x of dispersal area
                int zi_start = pop->cell->x - dispersal;
                if (zi_start<0) zi_start=0; // boundary
                // end cell x of dispersal area
                int zimax = std::min(pop->cell->x+dispersal, SRunPara::RunPara.xmax);
                //start cell y of dispersal area
                int zj_start = pop->cell->y - dispersal;
                if (zj_start<0) zj_start=0; // boundary
                // end cell y of dispersal area
                int zjmax = std::min(pop->cell->y + dispersal, SRunPara::RunPara.xmax);
                // loop over the foraging distance
                for (int zi=zi_start; zi < zimax; zi++)
                  for (int zj=zj_start; zj < zjmax ; zj++)
                  {
                      // distance to the home cell
                      double dist_curr = sqrt((pow(zi-pop->cell->x,2)+pow(zj-pop->cell->y,2)));
                      // if the cell is within the foraging distance;
                      if (dist_curr <= pop->Traits->dispmean){
                          //pointer to the foraging cell
                          shared_ptr<CCell> foraging_cell = CoreGrid.CellList[zi*SRunPara::RunPara.xmax+zj];
                          // within foraging cell: calculate the resource competition factor and resource uptake
                          double C_res=0; // sum of all c-values only considering FTs with the same flying period
                          int sum_pop=0; // sum of all population sizes only considering FTs with the same flying period
                          double uptake = pop->Traits->LU_suitability_forage.find(foraging_cell->LU_id)->second; // resource uptake without competition
                            if(foraging_cell->TZ) uptake+=pop->trans_effect_res;
                          // loop over all FT_pop_sizes_foraging entries
                          // to calculate the sum of the competition coefficients (C_res) and the sum of the populations (sum_pop)
                          double sum_res_comp=0.0; // sum of all competition impacts; own population size with the whole factor
                          int flying_period_j=pop->Traits->flying_period;
                          switch(flying_period_j){
                            // if flying period of the current FT pop is 1 --> take list 1 of foraging FT pops in cell
                             case 1:
                                    for (auto const& it : foraging_cell->FT_pop_sizes_foraging_1){
                                        string IDi = to_string(it.first);
                                        // only consider FTs with the same flying period
                                        C_res+=FT_traits::FtLinkList.find(IDi)->second->c;
                                        sum_pop+=it.second;
                                    }

                                    for (auto const& it : foraging_cell->FT_pop_sizes_foraging_1){
                                        string IDi = to_string(it.first);
                                        double ci=FT_traits::FtLinkList.find(IDi)->second->c; // competition factor of i
                                        double suitability=1.0; // suitability for the competitor FT - not used
                                        int Ni = it.second; // population size of the competitor FT
                                        double to_add=(1+((cj-ci)/C_res))*Ni*suitability; // competition impact of FT i
                                        sum_res_comp+=to_add; // sum it up
                                       }
                                    sum_res_comp/=sum_pop;
                                    // resource uptake under competition
                                    resource_uptake+=(sum_res_comp*uptake);
                                    // counting the number of foraging cells
                                    count_cells++;
                                    break;
                             // if flying period of the current FT pop is 2 --> take list 2 of foraging FT pops in cell
                              case 2:
                                     for (auto const& it : foraging_cell->FT_pop_sizes_foraging_2){
                                         string IDi = to_string(it.first);
                                         // only consider FTs with the same flying period
                                         C_res+=FT_traits::FtLinkList.find(IDi)->second->c;
                                         sum_pop+=it.second;
                                     }

                                     for (auto const& it : foraging_cell->FT_pop_sizes_foraging_2){
                                         string IDi = to_string(it.first);
                                         double ci=FT_traits::FtLinkList.find(IDi)->second->c; // competition factor of i
                                         double suitability=1.0; // suitability for the competitor FT - not used
                                         int Ni = it.second; // population size of the competitor FT
                                         double to_add=(1+((cj-ci)/C_res))*Ni*suitability; // competition impact of FT i
                                         sum_res_comp+=to_add; // sum it up
                                        }
                                     sum_res_comp/=sum_pop;
                                     // resource uptake under competition
                                     resource_uptake+=(sum_res_comp*uptake);
                                     // counting the number of foraging cells
                                     count_cells++;
                                    break;
                              // if flying period of the current FT pop is 3 --> take list 3 of foraging FT pops in cell
                              case 3:
                                     for (auto const& it : foraging_cell->FT_pop_sizes_foraging_3){
                                         string IDi = to_string(it.first);
                                         // only consider FTs with the same flying period
                                         C_res+=FT_traits::FtLinkList.find(IDi)->second->c;
                                         sum_pop+=it.second;
                                     }

                                     for (auto const& it : foraging_cell->FT_pop_sizes_foraging_3){
                                         string IDi = to_string(it.first);
                                         double ci=FT_traits::FtLinkList.find(IDi)->second->c; // competition factor of i
                                         double suitability=1.0; // suitability for the competitor FT - not used
                                         int Ni = it.second; // population size of the competitor FT
                                         double to_add=(1+((cj-ci)/C_res))*Ni*suitability; // competition impact of FT i
                                         sum_res_comp+=to_add; // sum it up
                                        }
                                     sum_res_comp/=sum_pop;
                                     // resource uptake under competition
                                     resource_uptake+=(sum_res_comp*uptake);
                                     // counting the number of foraging cells
                                     count_cells++;
                                    break;
                            }// end of switch
                      }// end of if dispersal distance
                  }// end loop over all dispersal cells
                // put it in relation to the foraged cells to get an averaged resource uptake
                double foraging_suitability=resource_uptake/count_cells;

                // STEP 2: calculate the interspecific  nest competition
                //calculate C: sum of cs of FTs in cell
                for (unsigned i=0; i < curr_FT_list.size(); i++) {
                    int flying_period_j=pop->Traits->flying_period;
                    int flying_period_i=curr_FT_list.at(i)->Traits->flying_period;
                    double ci=curr_FT_list.at(i)->Traits->c;
                    // only consider FTs with the same flying period
                    switch(flying_period_j){
                      case 1:
                          if (flying_period_i !=2){
                              C+=ci;
                          }
                        break;
                      case 2:
                          if (flying_period_i !=1){
                              C+=ci;
                          }
                        break;
                      case 3:
                        C+=ci;
                        break;
                  }// end of switch
                }// end loop over all FT pop in cell
                // C is now sum of Trait c of FTs in cell with the same flying period

                //sum of nest competition over all populations
                double sum=0.0;
                for (unsigned i=0; i < curr_FT_list.size(); i++) {
                    int flying_period_j=pop->Traits->flying_period;
                    int flying_period_i=curr_FT_list.at(i)->Traits->flying_period;
                    double ci=curr_FT_list.at(i)->Traits->c;
                    int Ni = curr_FT_list.at(i)->Pt;

                    switch(flying_period_j){
                      case 1:
                          if (flying_period_i !=2){
                              double to_add=(1+((cj-ci)/C))*Ni;
                              sum+=to_add;
                          }
                        break;
                      case 2:
                          if (flying_period_i !=1){
                              double to_add=(1+((cj-ci)/C))*Ni;
                              sum+=to_add;
                          }
                        break;
                      case 3:
                        double to_add=(1+((cj-ci)/C))*Ni;
                        sum+=to_add;
                        break;
                    }// end switch
                 }// end loop over all FT pops in cell

                // actual growth function
                double Nt1j=(foraging_suitability*weather_year*Ntj*Rj)/(1+((Rj-1)*pow(((sum)/K),bj))); // sum includes Nj
                //update Pt1 value of Pop
                pop->Pt1=max(0,int(floor(Nt1j)));
                cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
            }
    }

}

/**
 * @brief FT_pop::dispersal: Simulate the dispersal of individuals.
 * For each population, maximal 90%, but at least Pt/nestCap^omega of the individuals of each FT pop are dispersing.
 * Each dispersing individuals tries to find the cell with the maximal nest capacity in the foraging range.
 * But with increasing search attempts, the probability increases that it will choose a less suitable cell.
 * @param pop
 */
void FT_pop::dispersal(std::shared_ptr<FT_pop> pop){
    //get the number of dispering individuals
    double fract;
    double P_disp_t; //Percent of dispersing individuals
    fract=(1.0*pop->Pt)/(1.0*pop->nestCap); //depends on the nest capacity
    P_disp_t=min(0.9, pop->Traits->mu*pow(fract,pop->Traits->omega));
    //Emmigrants stores the number of dispersing individuals
    pop->Emmigrants=int (floor(P_disp_t*pop->Pt));
    //Update the remaining individuals in cell
    pop->Pt=pop->Pt-pop->Emmigrants;
    // count the number of search attempts to find a suitable patch
    int tries=0;
    // help variable
    int emmigrants=pop->Emmigrants;
    //now disperse the individuals within the grid and if FT already exists in the cell: increase Pt1 OR initialise Ft in new cell
    for (int emmig=emmigrants; emmig>0; emmig--){
        // highest potential nest capacity:
        double max_nest_suit=pop->MaxNestSuitability;
        // switch for finding a cell
        bool cell_found=false;
        // maximal number of search attempts possible
        int max_tries=SRunPara::RunPara.max_search_attempts;
        // while the individual hasn't found/decided for a new cell
        while (cell_found==false && tries < max_tries){
            // get a cell to disperse to
            // direction of dispersal
            double alpha=2*3.1415*combinedLCG();
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
            new_xcoord=pop->xcoord+dx;
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
                    // if cell doesn't include a population of the current FT yet, create a new one
                    // Check if FT exists already in cell
                    map <int, int> existing_FT_pop = cell_new->FT_pop_sizes;
                    int current_ID = pop->Traits->FT_ID;
                    auto search = existing_FT_pop.find(current_ID);
                    // if not found initialize a new Pop of this FT
                    if(search == existing_FT_pop.end()){
                        int start_size = 1;
                        std::shared_ptr<FT_pop> FTpop_tmp = std::make_shared< FT_pop >(pop->Traits,cell_new,start_size);
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
                    if ((LU_suitability !=0.0) && (random<prob_take_less*lesser)){
                        // check if pop exists in the new cell
                        // if cell doesn't include a population of the current FT yet create a new one
                        // Check if FT exists already in cell
                        map <int, int> existing_FT_pop = cell_new->FT_pop_sizes;
                        int current_ID = pop->Traits->FT_ID;
                        auto search = existing_FT_pop.find(current_ID);
                        // if not found initialize a new Pop of this FT
                        if(search == existing_FT_pop.end()){
                            int start_size = 1;
                            std::shared_ptr<FT_pop> FTpop_tmp = std::make_shared< FT_pop >(pop->Traits,cell_new,start_size);
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

/**
 * @brief FT_pop::update_pop: Update the population sizes after the growth of all populations in the grid
 * @param pop
 */
void FT_pop::update_pop(std::shared_ptr<FT_pop> pop){
    pop->Pt=pop->Pt1;
    pop->Pt1=0;
    shared_ptr<CCell> cell=pop->cell;
    cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
}

/**
 * @brief FT_pop::update_pop_dispersal: Update the population sizes after dispersal of all populations in the grid.
 * Immigrants are only counted after all individuals have emmigrated
 * @param pop
 */
void FT_pop::update_pop_dispersal(std::shared_ptr<FT_pop> pop){
    pop->Pt+=pop->Immigrants;
    pop->Immigrants=0;
    shared_ptr<CCell> cell=pop->cell;
    cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
}

/**
 * @brief FT_pop::disturbance: Calculate the number of individuals after disturbance events
 * Susceptibility to disturbance is determind by the disturbance effect trait of each FT
 * @param pop
 */
void FT_pop::disturbance(std::shared_ptr<FT_pop> pop){
    // depends on susceptibility
    pop->Pt=int(max(0.0,floor(pop->Pt*(1.0-pop->Traits->dist_eff))));
    shared_ptr<CCell> cell=pop->cell;
    cell->FT_pop_sizes.find(pop->Traits->FT_ID)->second=pop->Pt;
}

bool pairCompare( pair<size_t,int> i, pair<size_t,int> j)
{
return i.second < j.second;
}

