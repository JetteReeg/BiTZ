#include "runtimeenvironment.h"
#include "runparameter.h"
#include "gridenvironment.h"
#include "ft_traits.h"

int RuntimeEnvironment::year=0;

RuntimeEnvironment::RuntimeEnvironment()
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
    vector <int> tmp = GridEnvironment::readLandscape();
    //! set land use ID
    for (int i=0; i<(int) tmp.size(); i++){
        Grid.land_use_id.push_back(tmp[i]);
        //set coordinates
        int x,y;
        tie(x, y) = GridEnvironment::set_coordinates(i);
        Grid.x.push_back(x);
        Grid.y.push_back(y);
    }
    //! calculate the distance to each other LU class
    for (int i=0; i<(int) Grid.land_use_id.size(); i++){
        //set closest distance to other land use class
        std::map <int, double> distance_LU_tmp;
        distance_LU_tmp = GridEnvironment::get_distance_LU(i);
        Grid.distance_LU.push_back(distance_LU_tmp);
    }
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
        // go through the grid
        for (int i=0; i<(int) Grid.land_use_id.size(); i++){

            }
    }
    // go through the grid

    // calculate trans_effect for each FT

}
