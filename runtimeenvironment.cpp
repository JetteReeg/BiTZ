/**\file
 * \brief runtimeenvironment.cpp Initialisation and temporal sequence of processes according to the flowchart
*/
#include "runtimeenvironment.h"
#include "gridenvironment.h"
#include <vector>
#include <algorithm>
#include <iostream>
#include <fstream>
#include <sstream>
#include <ctime>

//! initialize global parameter @param year
int RuntimeEnvironment::year=0;
//! initialize global parameter @param weather_year
double RuntimeEnvironment::weather_year=1.0;
//! initialize vector for patch scale output
vector <shared_ptr<SFTout>> Output::FToutdata;
//! initialize vector for cell scale output
vector <shared_ptr<SLandout>> Output::Landoutdata;
//! constructor
RuntimeEnvironment::RuntimeEnvironment():GridEnvironment ()
{

}
/**
 * @brief RuntimeEnvironment::readSimDef: Read in the simulation file including the simulation definition
 * After reading in the file, the simulation run starts.
 * @param file
 */
void RuntimeEnvironment::readSimDef(const string file){
    // read patch ID definitions
    //Open InitFile
    ifstream DefFile(file.c_str());
        if (!DefFile.good()) {
            cerr << ("Error while opening Simulation File");
            exit(3);
        }
        // read the header line and skip it
        string line;
        getline(DefFile, line);
        while (getline(DefFile, line))
        {
            // get simulation parameter
            std::stringstream ss(line);
            //string SimNb;
            //first column
            ss >> SRunPara::RunPara.SimNb;
            ss >> SRunPara::RunPara.NameFtFile;
            ss >> SRunPara::RunPara.NameLandscapePatchFile;
            ss >> SRunPara::RunPara.NamePatchDefFile;
            ss >> SRunPara::RunPara.NameNestSuitabilityFile;
            ss >> SRunPara::RunPara.NameForageSuitabilityFile;
            ss >> SRunPara::RunPara.Nrep;
            ss >> SRunPara::RunPara.t_max;
            ss >> SRunPara::RunPara.ymax;
            ss >> SRunPara::RunPara.xmax;
            ss >> SRunPara::RunPara.nb_LU;
            ss >> SRunPara::RunPara.TZ_width;
            ss >> SRunPara::RunPara.TZ_percentage;
            ss >> SRunPara::RunPara.size_order;
            ss >> SRunPara::RunPara.max_search_attempts;
            ss >> SRunPara::RunPara.scaling;

            // convert to scaling
            SRunPara::RunPara.ymax/=SRunPara::RunPara.scaling;
            SRunPara::RunPara.xmax/=SRunPara::RunPara.scaling;
            one_run();
        }// end read simulation file
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
    //! initialize the landscape environment
    init();
    cout<<"Global initialization finished..."<<endl;

    int rep=0;
    while (rep<SRunPara::RunPara.Nrep){
        cout << "Start with a repetition..."<<endl;

        cout << "Initialize populations..."<<endl;
        //! initialize the populations
        init_populations();
        year=0;

        //! loop over the number of years to be simulated
        while(year<SRunPara::RunPara.t_max) {
            //if necessary, reset or update values for each year
            // run one year
            /**
             * ACHTUNG Anpassungen Lea
             */
            if (year>SRunPara::RunPara.qlossstart) {
                cout << "Qloss started year:" << year <<endl;
                //system("pause");
                for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                    shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
                    for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                        std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                        curr_Pop->set_trans_effect(cell, year);
                    }
                }
             }
            one_year();
        }

        //! write output
        cout << "Write output of repetition..."<<endl;
        WriteOfFile(rep);

        //! clear old variables
        for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
                // link to cell
                shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
                // iterating over FT_pops in cell
                for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                    std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                    //delete curr_Pop;
                }
                cell->FT_pop_List.clear();
                cell->FT_pop_sizes.clear();
        }

        Output::FToutdata.clear();
        Output::Landoutdata.clear();
        GridEnvironment::Patch_defList.clear();
        CoreGrid.CellList.clear();
        cout << "Clear data of repetition..."<<endl;
    //! increase the number of repetitions
    rep++;
    }
}

/**
 * @brief RuntimeEnvironment::one_year
 * This function simulates one year. Functions called within are: growth, update, dispersal
 * @param year: current year
 * functions called: FT_pop::growth, FT_pop::update_pop, FT_pop::dispersal
 */
void RuntimeEnvironment::one_year(){
    cout << "current year: "<< year+1 <<endl;

    //! calculate current weather conditions
    cout << "Calculate weather conditions..."<<endl;
    weather();

    //! get updated foraging range grid
    cout << "Update foraging range grid..."<<endl;
    //!clear old lists
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
        shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
        cell->FT_pop_sizes_foraging_1.clear();
        cell->FT_pop_sizes_foraging_2.clear();
        cell->FT_pop_sizes_foraging_3.clear();
    }

    //! calculate the new foraging range grid
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
        // link to cell
        shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
        // iterating over FT_pops in cell
        for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
            // get the current population
            std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
            // add the population size in all foraging cells to the map FT_pop_sizes_foraging
            FT_pop::set_foraging_individuals(curr_Pop);
        }// end for all populations in cell
    }// end for all cells

    //! calculate the growth of each FT population: go through the whole grid and all Pops in cell
    FT_pop::growth(weather_year);
    cout << "growth completed!"<<endl;

    //! update population sizes
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                FT_pop::update_pop(curr_Pop);
            }
    }
    cout<< "update completed!"<<endl;

    //! calculate the dispersal of each migranting individual
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                FT_pop::dispersal(curr_Pop);
            }
    }
    cout<< "migration completed!"<<endl;

    //! update the population sizes with the immigrants
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
            // link to cell
            shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                FT_pop::update_pop_dispersal(curr_Pop);
            }
    }
    cout<< "update after migration completed!"<<endl;

    //! calculate the disturbances

    //! go through patch ids and select all patches that are being disturbed
    vector<int> PID_disturbed;
    for (auto it = GridEnvironment::Patch_defList.begin(); it!=GridEnvironment::Patch_defList.end(); it++){
        shared_ptr<Patch_def> tmp = it->second;
        double probability = combinedLCG();
        // for arable patches, the probability is 90% for being disturbed within the current year
        if (tmp->Type=="arable" && probability < 1.0){
            PID_disturbed.push_back(tmp->PID);
        }
        // for grassland patches, the probability is 30% for being disturbed within the current year
        if (tmp->Type=="grassland" && probability < 0.8){
            PID_disturbed.push_back(tmp->PID);
        }
    }
    //! go through all cells and check if it is disturbed
    for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i){
        // link to cell
        shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
        // only if cell is no TZ cell
        if(!cell->TZ){
            // if the cell belongs to a disturbed arable or grassland patch, all populations are disturbed
            if (std::find(PID_disturbed.begin(), PID_disturbed.end(), cell->pa_id) != PID_disturbed.end()){
                for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                    std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                    FT_pop::disturbance(curr_Pop);
                } // end for all populations in cell
            }// end if disturbed arable patch
            // if urban
            if (cell->LU_id==4 && combinedLCG()<0.7){
                for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                    std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                    FT_pop::disturbance(curr_Pop);
                }
            }

            // if forest
            if (cell->LU_id==2 && combinedLCG()<0.3){
                for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                    std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                    FT_pop::disturbance(curr_Pop);
                }
            }
            // if bare
            if (cell->LU_id==0  && combinedLCG()<0.7){
                for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                    std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                    FT_pop::disturbance(curr_Pop);
                }
            }

        }// end not TZ cell
   }
    cout<< "disturbance completed!"<<endl;


    //! summarize values for the year to be stored for each FT on a patch scale every year
    for (auto var = FT_traits::FtLinkList.begin();
            var != FT_traits::FtLinkList.end(); ++var) {
        // for each patch ID
        for (auto patch = GridEnvironment::Patch_defList.begin();
                patch != GridEnvironment::Patch_defList.end(); ++patch) {
            int patch_ID = patch->second->PID;
            string lu = patch->second->Type;
            int LU_id;
            if (lu=="bare") LU_id=0;
            if (lu=="arable") LU_id=1;
            if (lu=="forest") LU_id=2;
            if (lu=="grassland") LU_id=3;
            if (lu=="urban") LU_id=4;
            if (lu=="water") LU_id=5;
            if (lu=="transition") LU_id=6;
            shared_ptr <SFTout> tmp=Output::GetOutput_FT(year, var->second->FT_ID, LU_id, patch_ID);
            Output::FToutdata.push_back(tmp);
        }
    }

    //! summarize values for the year to be stored for each FT on a cell scale every 10th year
    if (year % 10 == 0 || year==(SRunPara::RunPara.t_max-1)){
        for (unsigned int cell_i=0; cell_i<SRunPara::RunPara.GetSumCells(); ++cell_i) {
            shared_ptr<CCell> cell = CoreGrid.CellList[cell_i];
            // iterating over FT_pops in cell
            for (unsigned pop_i=0; pop_i < cell->FT_pop_List.size(); pop_i++){
                std::shared_ptr<FT_pop> curr_Pop=cell->FT_pop_List.at(pop_i);
                int x = curr_Pop->xcoord;
                int y = curr_Pop->ycoord;
                int lu = cell->LU_id;
                int FT_ID = curr_Pop->Traits->FT_ID;
                shared_ptr <SLandout> tmp=Output::GetOutput_Land(curr_Pop, year, x, y, lu, FT_ID);
                Output::Landoutdata.push_back(tmp);
            }
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
    year=0;
    //initialise the landscape
    init_landscape();
    //initialise the functional types
    init_FTs();
}
/**
 * @brief RuntimeEnvironment::init_landscape
 * initialises the landscape: reads in the patch ID definitions, the landscape patch file and calculates the smallest distances to other land use classes
 */
void RuntimeEnvironment::init_landscape(){
    readPatchID_def(SRunPara::RunPara.NamePatchDefFile);
    readLandscape();
    calculate_TZ();
    cout << "Initialization of landscape finished..."<<endl;
}
/**
 * @brief RuntimeEnvironment::init_FTs
 * initialises the functional types: reads in the FT definitions and LU suitabilities of the FTs
 */
void RuntimeEnvironment::init_FTs(){
    FT_traits::ReadFTDef(SRunPara::RunPara.NameFtFile);
    FT_traits::ReadNestSuitability(SRunPara::RunPara.NameNestSuitabilityFile);
    FT_traits::ReadForageSuitability(SRunPara::RunPara.NameForageSuitabilityFile);
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
        int init_pop = 1000;
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
        shared_ptr<CCell> cell = CoreGrid.CellList[x*x_cell+y];
        // if cell doesn't include a FT pop yet...
        // Check if FT exists already in cell
        map <int, int> existing_FT_pop = cell->FT_pop_sizes;
        int current_ID = traits->FT_ID;
        auto search = existing_FT_pop.find(current_ID);
        if(search == existing_FT_pop.end()){
            int start_size = nrand(100)+1;
            //int start_size=1;
            std::shared_ptr<FT_pop> FTpop_tmp = std::make_shared< FT_pop >(traits,cell,start_size);
            cell->FT_pop_List.push_back(FTpop_tmp);
            cell->FT_pop_sizes.insert(std::make_pair(traits->FT_ID, start_size));
            i++;
        }
       }//for each start population
}
/**
 * @brief RuntimeEnvironment::WriteOfFile: Writing of the output file
 */
void RuntimeEnvironment::WriteOfFile(int nrep){
    //FToutdata
    stringstream strd;
    strd<<"Output/GridOut_"<<SRunPara::RunPara.SimNb<<"_"<<SRunPara::RunPara.MC<<".txt";
    string NameGridOutFile=strd.str();
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
                 <<"Pa_ID\t"
                  <<"Popsize"
                  ;
            myfile<<"\n";
        }

    // get values for each year
    for (vector <SFTout>::size_type i=0; i<Output::FToutdata.size(); ++i){
        myfile<<Output::FToutdata[i]->year
                 <<'\t'<<Output::FToutdata[i]->FT_ID
                 <<'\t'<<Output::FToutdata[i]->LU_ID
                   <<'\t'<<Output::FToutdata[i]->patch_ID
                 <<'\t'<<Output::FToutdata[i]->popsize
              <<"\n";
    }// end for each year
    myfile.close();

    //Landoutdata
    strd.str(std::string());
    strd<<"Output/LandOut_"<<SRunPara::RunPara.SimNb<<"_"<<SRunPara::RunPara.MC<<".txt";
    string NameLandOutFile=strd.str();
    ofstream Landfile(NameLandOutFile.c_str(),ios::app);
    if (!Landfile.good()) {cerr<<("Error while opening Output File");exit(3); }
    // write header
    Landfile.seekp(0, ios::end);
    long size_com=Landfile.tellp();
    // header of the file
    if (size_com==0){
        Landfile<<"Year\t"
               <<"x\t"
               <<"y\t"
                  <<"LU_ID\t"
                  <<"FT_ID\t"
                  <<"popsize\t"
                  ;
            Landfile<<"\n";
        }

    // get values for each year
    for (vector <SLandout>::size_type i=0; i<Output::Landoutdata.size(); ++i){
        Landfile<<Output::Landoutdata[i]->year
                 <<'\t'<<Output::Landoutdata[i]->x
                 <<'\t'<<Output::Landoutdata[i]->y
                   <<'\t'<<Output::Landoutdata[i]->LU_ID
                     <<'\t'<<Output::Landoutdata[i]->FT_ID
                       <<'\t'<<Output::Landoutdata[i]->popsize
              <<"\n";
    }// end for each year
    Landfile.close();
}

/**
 * @brief RuntimeEnvironment::weather: Calculation of the yearly weather
 */
void RuntimeEnvironment::weather(){
    // int bimodal=random(10);
    double eps;
    //if (bimodal<6) eps=my_random_normal(my_mean=-0.3,my_stdev=0.15);
    //else
    //normal distribution
    eps=normcLCG(0.0,0.15);

    /*Unimodal verteilte Klimaeinflüsse*/
    //double eps=my_random_normal(my_mean,my_stdev=0.15);

    //annual weather randomly fluctuates with eps from [-0.5, 0.5]
    weather_year= 1.0;
    weather_year=weather_year*(1+eps);
}
/**
    calculates the distance between two cells in the grid
    @param xx, yy, x, y pairs of coordinates
  \return eucledian distance between two pairs of coordinates (xx,yy) and (x,y)
*/
double Distance(const double& xx, const double& yy,
                const double& x, const double& y){
    return sqrt((xx-x)*(xx-x) + (yy-y)*(yy-y));
}

/**
 * @brief CompareIndexRel: Compares two integers
 * @param i1
 * @param i2
 * @return
 */
bool CompareIndexRel(int i1, int i2)
{
    const int Num=SRunPara::RunPara.xmax;
    return  Distance(i1/Num,i1%Num  ,Num/2,Num/2)
         <Distance(i2/Num,i2%Num  ,Num/2,Num/2);
}
