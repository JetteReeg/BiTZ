#include "output.h"
#include "runparameter.h"
#include "ft_traits.h"
#include "gridenvironment.h"
#include "runtimeenvironment.h"

Output::Output()
{

}

/**
 * constructor
 */
SFTout::SFTout():year(0),FT_ID(0), LU_ID(0), popsize(0){
}//end PftOut constructor

/**
 * constructor
 */
SComout::SComout():year(0),LU_ID(0), nb_FT(0), diversity(0.0){
}//end PftOut constructor

shared_ptr <SFTout> Output::GetOutput_FT(int year, int FT_ID, int lu){
            //create a new struct to add to list
            shared_ptr <SFTout> FTyear=make_shared<SFTout>();
            FTyear->year=year;
            FTyear->FT_ID=FT_ID;
            FTyear->LU_ID=lu;
            //go through each cell
            for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                    // link to cell
                    shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
                    //if cell LU_ID is lu
                    if (cell->LU_id==lu){
                         map <int, int> existing_FT_pop = cell->FT_pop_sizes;
                         auto search = existing_FT_pop.find(FT_ID);
                         // if FT_ID is found - add pop size
                         if(search != existing_FT_pop.end()){
                             for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                                 std::shared_ptr<FT_pop> tmp_Pop=cell->FT_pop_List.at(pop_i);
                                 // if it's the current FT add individual
                                 if (tmp_Pop->Traits->FT_ID==FT_ID){
                                     FTyear->popsize+=tmp_Pop->Pt;
                                       }// end add popsize
                                 } // end find FT_ID
                           }// end if FT_ID exist
                        } // end if LU_ID of cell is lu
    }// for each cell
   return(FTyear);
}// end get output

shared_ptr <SComout> Output::GetOutput_Com(int year, int lu){
            //create a new struct to add to list
            shared_ptr <SComout> Comyear=make_shared<SComout>();
            Comyear->year=year;
            Comyear->LU_ID=lu;
            Comyear->nb_FT=0;
            Comyear->diversity=0.0;
            //go through each cell
            int nb_cell=0;
            int totalN=0;
            int totalN_tmp=0;
            for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                    // link to cell
                    shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
                    //if cell LU_ID is lu
                    if (cell->LU_id==lu){
                        // get nb of FT in cell
                         // total number of individuals
                         for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                             if(cell->FT_pop_List.at(pop_i)->Pt>0){
                                 Comyear->nb_FT++;
                                 totalN=totalN+cell->FT_pop_List.at(pop_i)->Pt;
                                 totalN_tmp=totalN_tmp+cell->FT_pop_List.at(pop_i)->Pt;
                             }
                         }
                         if (totalN_tmp>0) nb_cell++;
                         totalN_tmp=0;
                    }
            }// for each cell

            for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                // link to cell
                shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
                //if cell LU_ID is lu
                if (cell->LU_id==lu){
                    // get diversity index
                    // calculate relative number of individuals in cell and sum it up
                    for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                        if (cell->FT_pop_List.at(pop_i)->Pt>0){
                            double pi = double ((1.0*cell->FT_pop_List.at(pop_i)->Pt)/(1.0*totalN));
                            pi= pi*log(pi);
                            Comyear->diversity=Comyear->diversity+pi;
                            }
                        }
                } // end if LU_ID of cell is lu

            }
            Comyear->diversity = Comyear->diversity/nb_cell;
            Comyear->nb_FT = Comyear->nb_FT/nb_cell;
   return(Comyear);
}// end get output

