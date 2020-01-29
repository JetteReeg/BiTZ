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
    //TODO: CHECK output! --> what do I need? nb. FT per cell? per lu class? overall N?
            shared_ptr <SComout> Comyear=make_shared<SComout>();
            Comyear->year=year;
            Comyear->LU_ID=lu;
            Comyear->nb_FT=0;
            double nb_FT_in_lu=0;
            double div_in_lu=0.0;
            //go through each cell
            int nb_cell=0; // count number of cells of LU
            int totalNin_LU=0; // total N in LU

            for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                    // link to cell
                    shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
                    //if cell LU_ID is lu
                    if (cell->LU_id==lu){
                        int nb_FT_in_cell=0;
                        double div_in_cell=0.0;
                        int totalN_in_cell=0;
                        nb_cell++;
                        // get nb of FT in cell
                         // total number of individuals
                         for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                             if(cell->FT_pop_List.at(pop_i)->Pt>0){
                                 nb_FT_in_cell++; //nb_FT in Zelle
                                 totalN_in_cell=totalN_in_cell+cell->FT_pop_List.at(pop_i)->Pt;// total N in Zelle
                             }
                         }
                         // calculate relative pi
                         for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                             if(cell->FT_pop_List.at(pop_i)->Pt>0){
                                 double pi = double ((1.0*cell->FT_pop_List.at(pop_i)->Pt)/(1.0*totalN_in_cell));
                                 div_in_cell= div_in_cell + pi*log(pi);
                             }
                         }
                         div_in_cell=-div_in_cell;
                         // summarise
                         nb_FT_in_lu=nb_FT_in_lu+nb_FT_in_cell;
                         div_in_lu=div_in_lu+div_in_cell;
                         totalNin_LU=totalNin_LU+totalN_in_cell;
                    }
            }// for each cell

            Comyear->diversity = div_in_lu/nb_cell;
            Comyear->nb_FT = nb_FT_in_lu/nb_cell;
            Comyear->totalN=totalNin_LU;
   return(Comyear);
}// end get output

