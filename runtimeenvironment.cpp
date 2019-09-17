#include "runtimeenvironment.h"
#include <gridenvironment.h>
#include <iostream>

int RuntimeEnvironment::year=0;

RuntimeEnvironment::RuntimeEnvironment():GridEnvironment ()
{

}

void RuntimeEnvironment::one_run(){
    init();

    while(year<SRunPara::RunPara.t_max) {
        //if necessary, reset or update values for each year
        //Popdynamics
        one_year();
    }
}

void RuntimeEnvironment::one_year(){
    //go through the whole grid and all Pops in cell
    //iterating over cells
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            CCell* cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                FT_pop* curr_Pop=cell->FT_pop_List.at(pop_i);
                FT_pop::growth(curr_Pop);
            }
    }
    // summarize values for the year to be stored

    year++;
}

void RuntimeEnvironment::init(){
    SRunPara::RunPara.NameFtFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/FT_Definitions.txt";
    SRunPara::RunPara.NameLandscapePatchFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/Agroscapelab_10m_300x300_gerastert_Fragstats_id4_2.asc";
    SRunPara::RunPara.NamePatchDefFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/Patch_ID_definitions.txt";
    SRunPara::RunPara.NameSuitabilityFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/LU_FT_suitability.txt";
    SRunPara::RunPara.t_max=5;
    SRunPara::RunPara.xmax=300;
    SRunPara::RunPara.ymax=300;
    SRunPara::RunPara.nb_LU=5;


    init_landscape();
    init_FTs();
    init_populations();

    while(year<SRunPara::RunPara.t_max) {
        cout<<"year: "<<year<<endl;
        //if necessary, reset or update values for each year
        //Popdynamics
        one_year();
    }
}

void RuntimeEnvironment::init_landscape(){
    readPatchID_def(SRunPara::RunPara.NamePatchDefFile);
    readLandscape();
    calculate_distance_LU();
}

void RuntimeEnvironment::init_FTs(){
    FT_traits::ReadFTDef(SRunPara::RunPara.NameFtFile);
    FT_traits::ReadSuitability(SRunPara::RunPara.NameSuitabilityFile);
}

void RuntimeEnvironment::init_populations(){
    // set start populations for each grid cell
    // for each FT
    for (auto var = FT_traits::FtLinkList.begin();
            var != FT_traits::FtLinkList.end(); ++var) {
        // variable trait stores the trait values
        shared_ptr<FT_traits> traits=var->second;
        // init new FT populations
        int init_pop = 40000;
        InitFTpop(traits, init_pop);
    }

    // Check for consistency:
    // Ft populations were initialized! Ft_pop_sizes hold the initial pop sizes; several FTs in cell
    cout<<"initialisation finished"<<endl;


}

void RuntimeEnvironment::InitFTpop(shared_ptr <FT_traits> traits, int n){
    int x,y;
    int x_cell=SRunPara::RunPara.xmax;
    int y_cell=SRunPara::RunPara.ymax;
    // for n FT populations
    int i = 0;
    while (i<n){
        // find cell
        x=nrand(x_cell);
        y=nrand(y_cell);
        // set population in cell
        CCell* cell = CoreGrid.CellList[x*x_cell+y];
        // if cell doesn't include a FT pop yet...
        // Check if FT exists already in cell
        map <int, int> existing_FT_pop = cell->FT_pop_sizes;
        int current_ID = traits->FT_ID;
        auto search = existing_FT_pop.find(current_ID);
        if(search == existing_FT_pop.end()){
            int start_size = nrand(100)+1;
            FT_pop* FTpop_tmp = new FT_pop(traits,cell,start_size);
            cell->FT_pop_List.push_back(FTpop_tmp);
            cell->FT_pop_sizes.insert(std::make_pair(traits->FT_ID, start_size));
            i++;
        }

       }//for each seed to disperse
}

void RuntimeEnvironment::analyse(){
    // for each FT
    for (auto var = FT_traits::FtLinkList.begin();
            var != FT_traits::FtLinkList.end(); ++var) {
            int pop_size=0;
            int FT_ID=var->second->FT_ID;
            for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                    // link to cell
                    CCell* cell = CoreGrid.CellList[cell_i];
                    // iterating over FT_pops in cell
                    pop_size=+cell->FT_pop_sizes.find(FT_ID)->second;
            }


    }
}
