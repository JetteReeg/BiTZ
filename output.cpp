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
SLandout::SLandout():year(0),x(0), y(0), LU_ID(0), FT_ID(0), popsize(0){
}//end PftOut constructor

/**
 * @brief Output::GetOutput_FT: After each year, the population size on patch scale are stored in a struct.
 * @param year
 * @param FT_ID
 * @param lu
 * @param patch_ID
 * @return
 */
shared_ptr <SFTout> Output::GetOutput_FT(int year, int FT_ID, int lu, int patch_ID){
            //create a new struct to add to list
            shared_ptr <SFTout> FTyear=make_shared<SFTout>();
            FTyear->year=year;
            FTyear->FT_ID=FT_ID;
            FTyear->patch_ID=patch_ID;
            FTyear->LU_ID=lu;
            FTyear->popsize=0;
            //go through each cell to summerize the population size per patch
            for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                    // link to cell
                    shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
                    //if cell LU_ID is lu
                    if (cell->pa_id==patch_ID){
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

/**
 * @brief Output::GetOutput_Land: After each 10 years, the population size on cell scale is stored in a struct.
 * @param pop
 * @param year
 * @param x
 * @param y
 * @param lu
 * @param FT_ID
 * @return
 */
shared_ptr <SLandout> Output::GetOutput_Land(std::shared_ptr<FT_pop> pop, int year, int x, int y, int lu, int FT_ID){
            //create a new struct to add to list
            shared_ptr <SLandout> Landyear=make_shared<SLandout>();
            Landyear->x=x;
            Landyear->y=y;
            Landyear->year=year;
            Landyear->LU_ID=lu;
            Landyear->FT_ID=FT_ID;
            Landyear->popsize=pop->Pt;
   return(Landyear);
}// end get output

