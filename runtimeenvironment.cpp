#include "runtimeenvironment.h"
#include <gridenvironment.h>
#include <iostream>
#include <fstream>
#include <sstream>

int RuntimeEnvironment::year=0;
double RuntimeEnvironment::weather_year=1.0;
vector <SFTout*> Output::FToutdata;

RuntimeEnvironment::RuntimeEnvironment():GridEnvironment ()
{

}
/**
 * @brief RuntimeEnvironment::one_run
 * This function initializes one simulation run and afterwards start a while loop over the number of simulated years.
 * @param year: current year
 * @param SRunPara::RunPara.t_max: number of maximal simulated years
 */
void RuntimeEnvironment::one_run(){
    cout<<"Start one simulation run..."<<endl;
    cout<<" Initialize..."<<endl;
    init();
    cout<<"Initialization finished..."<<endl;
    cout << "Start with year one..."<<endl;
    while(year<SRunPara::RunPara.t_max) {
        //if necessary, reset or update values for each year
        //Popdynamics
        one_year();
    }
    //write output
    WriteOfFile();

    //clear old variables
    CoreGrid.CellList.clear();
    FT_traits::FtLinkList.clear();
}
/**
 * @brief RuntimeEnvironment::one_year
 * This function simulates one year. Functions called within are: growth, update, dispersal
 * @param year: current year
 * functions called: FT_pop::growth, FT_pop::update_pop, FT_pop::dispersal
 */
void RuntimeEnvironment::one_year(){
    // calculate current weather conditions
    weather();
    //go through the whole grid and all Pops in cell
    //iterating over cells
    cout << "current year: "<< year+1 <<endl;
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            CCell* cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                FT_pop* curr_Pop=cell->FT_pop_List.at(pop_i);
                FT_pop::growth(curr_Pop, weather_year);
            }
    }
    cout << "growth completed!"<<endl;

    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            CCell* cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                FT_pop* curr_Pop=cell->FT_pop_List.at(pop_i);
                FT_pop::update_pop(curr_Pop);
            }
    }
    cout<< "update completed!"<<endl;
    //TODO: check dispersal function!
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            CCell* cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                FT_pop* curr_Pop=cell->FT_pop_List.at(pop_i);
                FT_pop::dispersal(curr_Pop);
            }
    }
    cout<< "migration completed!"<<endl;

    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            CCell* cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                FT_pop* curr_Pop=cell->FT_pop_List.at(pop_i);
                FT_pop::update_pop_dispersal(curr_Pop);
            }
    }
    cout<< "update after migration completed!"<<endl;

    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            CCell* cell = CoreGrid.CellList[cell_i];
            double dist_prob=combinedLCG();
            if (dist_prob<SRunPara::RunPara.disturbances){
                // iterating over FT_pops in cell
                for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                    FT_pop* curr_Pop=cell->FT_pop_List.at(pop_i);
                    FT_pop::disturbance(curr_Pop);
                }
            }
    }
    cout<< "disturbance completed!"<<endl;


    // summarize values for the year to be stored
    //for each FT type ID
    for (auto var = FT_traits::FtLinkList.begin();
            var != FT_traits::FtLinkList.end(); ++var) {
        // for each LU_ID
        for (int lu=0;lu<SRunPara::RunPara.nb_LU;lu++) {
            SFTout* tmp=Output::GetOutput(year, var->second->FT_ID, lu);
            Output::FToutdata.push_back(tmp);
        }
    }
    cout<< "yearly output completed!"<<endl;
    year++;
}
/**
 * @brief RuntimeEnvironment::init
 * Initializes one simulation run; sets the initial conditions, calls init_landscape, init_FTs, init_populations
 */
void RuntimeEnvironment::init(){
    SRunPara::RunPara.NameFtFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/FT_Definitions.txt";
    SRunPara::RunPara.NameLandscapePatchFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/Agroscapelab_10m_300x300_gerastert_Fragstats_id4_2.asc";
    SRunPara::RunPara.NamePatchDefFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/Patch_ID_definitions.txt";
    SRunPara::RunPara.NameSuitabilityFile="C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/Input/LU_FT_suitability.txt";
    SRunPara::RunPara.t_max=50;
    SRunPara::RunPara.xmax=300;
    SRunPara::RunPara.ymax=300;
    SRunPara::RunPara.nb_LU=6;
    SRunPara::RunPara.TZ_width=1;
    SRunPara::RunPara.disturbances=0.1;
    year=0;
    //initialise the landscape
    init_landscape();
    //initialise the functional types
    init_FTs();
    //initialise the populations
    init_populations();
}
/**
 * @brief RuntimeEnvironment::init_landscape
 * initialises the landscape: reads in the patch ID definitions, the landscape patch file and calculates the smallest distances to other land use classes
 */
void RuntimeEnvironment::init_landscape(){
    readPatchID_def(SRunPara::RunPara.NamePatchDefFile);
    readLandscape();
    calculate_distance_LU();
    cout << "Initialization of landscape finished..."<<endl;
}
/**
 * @brief RuntimeEnvironment::init_FTs
 * initialises the functional types: reads in the FT definitions and LU suitabilities of the FTs
 */
void RuntimeEnvironment::init_FTs(){
    FT_traits::ReadFTDef(SRunPara::RunPara.NameFtFile);
    FT_traits::ReadSuitability(SRunPara::RunPara.NameSuitabilityFile);
    cout << "Initialization of FTs finished..."<<endl;
}
/**
 * @brief RuntimeEnvironment::init_populations
 * initialises the first populations in the landscape
 */
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
    cout << "Initialization of FT_pops finished..."<<endl;
}
/**
 * @brief RuntimeEnvironment::InitFTpop
 * @param traits Trait set of the specific FT
 * @param n pop size to be inizialised
 */
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
/**
 * @brief RuntimeEnvironment::WriteOfFile
 */
void RuntimeEnvironment::WriteOfFile(){
    string NameGridOutFile= "C:/Users/JetteR/ownCloud/Bibs/BiTZ/branches/Initialize-Model/GridOut.txt";
    ofstream myfile(NameGridOutFile.c_str(),ios::app);
    if (!myfile.good()) {cerr<<("Error while opening Output File");exit(3); }
    // write header
    myfile.seekp(0, ios::end);
    long size=myfile.tellp();
    // header of the file
    if (size==0){
        myfile<<"Year\t"
                  <<"FT_ID\t"
                  <<"LU_ID\t"
                  <<"Popsize"
                  ;
            myfile<<"\n";
        }

    // get values for each year
    for (vector <SFTout>::size_type i=0; i<Output::FToutdata.size(); ++i){
        myfile<<Output::FToutdata[i]->year
                 <<'\t'<<Output::FToutdata[i]->FT_ID
                 <<'\t'<<Output::FToutdata[i]->LU_ID
                 <<'\t'<<Output::FToutdata[i]->popsize
              <<"\n";
    }// end for each year
    myfile.close();
}

/**
 * @brief RuntimeEnvironment::weather
 */
void RuntimeEnvironment::weather(){
    // int bimodal=random(10);
    double eps;
    //if (bimodal<6) eps=my_random_normal(my_mean=-0.3,my_stdev=0.15);
    //else
    //normal distribution
    eps=normcLCG(0.1,0.15);

    /*Unimodal verteilte Klimaeinflüsse*/
    //double eps=my_random_normal(my_mean,my_stdev=0.15);

    //annual weather randomly fluctuates with eps from [-0.5, 0.5]
    weather_year= 1.0;
    weather_year=weather_year*(1+eps);
    cout<<"weather condition: "<< weather_year << endl;
}
