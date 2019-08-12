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
    //go through eacht PFT

}

void RuntimeEnvironment::init(){
    SRunPara::RunPara.NameFtFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/FT_Definitions.txt";
    SRunPara::RunPara.NameLandscapeFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/300x300Bsp.asc";
    SRunPara::RunPara.t_max=100;
    SRunPara::RunPara.xmax=300;
    SRunPara::RunPara.ymax=300;
    SRunPara::RunPara.nb_LU=5;


    init_landscape();
    init_FTs();
    init_populations();
}

void RuntimeEnvironment::init_landscape(){
    readLandscape();
   // GridEnvironment::calculate_distance_LU();
}

void RuntimeEnvironment::init_FTs(){
    FT_traits::ReadFTDef(SRunPara::RunPara.NameFtFile);
}

void RuntimeEnvironment::init_populations(){
    // set start populations for each grid cell
    // for each FT
    for (auto var = FT_traits::FtLinkList.begin();
            var != FT_traits::FtLinkList.end(); ++var) {
        // variable trait stores the trait values
        shared_ptr<FT_traits> traits=var->second;
        // init new FT populations
        int init_pop = 10;
        InitFTpop(traits, init_pop);
    }

    // check if there are FT_pop's in cells:
    /*for (int location=0; location < CoreGrid.CellList.size();
            ++location) {
            CCell* cell = CoreGrid.CellList[location];

            cout<<"x: "<<cell->x <<"y: "<<cell->y  <<"PFT: ";
            if (!cell->FT_pop_sizes.empty()){
                int ID=cell->FT_pop_sizes.begin()->first;
                 cout << ID;
    }
                  else cout <<"empty"<<endl;
    }*/
    // calculate trans_effect for each FT

}

void RuntimeEnvironment::InitFTpop(shared_ptr <FT_traits> traits, int n){
    int x,y;
    int x_cell=SRunPara::RunPara.xmax;
    int y_cell=SRunPara::RunPara.ymax;
    // for each FT population
    for (int i=0; i<n; ++i){
        // find cell
        x=nrand(x_cell);
        y=nrand(y_cell);
        // set population in cell
        CCell* cell = CoreGrid.CellList[x*x_cell+y];
        int start_size = nrand(100);
        FT_pop* FTpop = new FT_pop(traits,cell,start_size);
        cell->FT_pop_List.push_back(FTpop);
        cell->FT_pop_sizes.insert(std::make_pair(traits->FT_ID, start_size));
       }//for each seed to disperse
}
