#include "output.h"
#include <runparameter.h>
#include <ft_traits.h>
#include <gridenvironment.h>
#include <runtimeenvironment.h>

Output::Output()
{

}

/**
 * constructor
 */
SFTout::SFTout():year(0),FT_ID(0), LU_ID(0), popsize(0){
}//end PftOut constructor

SFTout* Output::GetOutput(int year, int FT_ID, int lu){
            //create a new struct to add to list
            SFTout* FTyear=new SFTout();
            FTyear->year=year;
            FTyear->FT_ID=FT_ID;
            FTyear->LU_ID=lu;
            //go through each cell
            for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                    // link to cell
                    CCell* cell = CoreGrid.CellList[cell_i];
                    //if cell LU_ID is lu
                    if (cell->LU_id==lu){
                         map <int, int> existing_FT_pop = cell->FT_pop_sizes;
                         auto search = existing_FT_pop.find(FT_ID);
                         // if FT_ID is found - add pop size
                         if(search != existing_FT_pop.end()){
                             for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                                 FT_pop* tmp_Pop=cell->FT_pop_List.at(pop_i);
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

