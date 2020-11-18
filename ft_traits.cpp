/**\file
 * \brief ft_traits.cpp Trait definitions of the FTs
*/
#include "ft_traits.h"
#include "runparameter.h"

#include <cstdlib>
#include <string>
#include <fstream>
#include <iostream>
#include <memory>
#include <cassert>
#include <sstream>
//! map of all FTs and the specific traits
map< string, shared_ptr<FT_traits> > FT_traits::FtLinkList = map< string, shared_ptr<FT_traits> >();
//! constructor
FT_traits::FT_traits()
{

}

/**
 * @brief FT_traits::ReadFTDef: Reads in the FT definition file
 * @param file
 */
void FT_traits::ReadFTDef(const string file){
    //Open InitFile
    ifstream FTFile(file.c_str());
        if (!FTFile.good()) {
            cerr << ("Error while opening FT File");
            exit(3);
        }
        // read the header line and skip it
        string line;
        getline(FTFile, line);
        while (getline(FTFile, line))
        {
            // get the trait data for each PFT
            std::stringstream ss(line);
            // create a structure for the traits
            shared_ptr<FT_traits> traits = make_shared<FT_traits>();
            ss >> traits->FT_type >> traits->FT_ID >> traits->R
                    >> traits->b >> traits->c >> traits ->mu
                    >> traits->omega >> traits->dispsd >>traits->dispmean >> traits->flying_period >> traits->dist_eff >> traits->trans_effect_nest >> traits->trans_effect_res;
            // add a new PFT to the list of PFTs

            // convert traits to the scaling of the current model run
            traits->dispsd/=SRunPara::RunPara.scaling;
            traits->dispmean/=SRunPara::RunPara.scaling;

            FT_traits::FtLinkList.insert(std::make_pair(traits->FT_type, traits));
        }// end read all trait data for PFTs
}

/**
 * @brief FT_traits::ReadNestSuitability: Reads in the nest suitability file
 * it include the nest suitability in each land use class for each FT
 * @param file
 */
void FT_traits::ReadNestSuitability(const string file){
    //Open InitFile
    ifstream SuitabilityFile(file.c_str());
        if (!SuitabilityFile.good()) {
            cerr << ("Error while opening nest suitability File");
            exit(3);
        }
    string line;
    // copy the first line of the file
    getline(SuitabilityFile, line);
    //create vector of maps to store suitablity of LU classes for each FT
    std::stringstream ss(line);
    //skip first column
    string dummi;
    string dummi2;
    ss>>dummi;
    vector <string> nb_FT;
    while(!ss.eof()){
        ss >> dummi2;
        nb_FT.push_back(dummi2);
    }
    // now insert the numbers
    while (getline(SuitabilityFile, line))
    {
        std::stringstream ss(line);
        unsigned count2=0;
        int LU_ID;
        //first column holds the LU_ID; key for the maps that are created
        ss >> LU_ID;
        string curr_FT;
        while(!ss.eof()){
            //set the FT_type
            curr_FT=nb_FT.at(count2);
            // get the value
            double suitability;
            ss >> suitability;
            //insert to suitability vector in FT_trait file
            auto var = FT_traits::FtLinkList.find(curr_FT);
            shared_ptr<FT_traits> traits=var->second;
            traits->LU_suitability_nest.insert(std::make_pair(LU_ID, suitability));
            count2++;
        }
    }// end read suitability
}

/**
 * @brief FT_traits::ReadForageSuitability: Reads in the resource suitability file
 * it includes the forage suitability in each land use class for each FT
 * @param file
 */
void FT_traits::ReadForageSuitability(const string file){
    //Open InitFile
    ifstream SuitabilityFile(file.c_str());
        if (!SuitabilityFile.good()) {
            cerr << ("Error while opening forage suitability File");
            exit(3);
        }
    string line;
    // copy the first line of the file
    getline(SuitabilityFile, line);
    //create vector of maps to store suitablity of LU classes for each FT
    std::stringstream ss(line);
    //skip first column
    string dummi;
    string dummi2;
    ss>>dummi;
    vector <string> nb_FT;
    while(!ss.eof()){
        ss >> dummi2;
        nb_FT.push_back(dummi2);
    }
    // now insert the numbers
    while (getline(SuitabilityFile, line))
    {
        std::stringstream ss(line);
        unsigned count2=0;
        int LU_ID;
        //first column holds the LU_ID; key for the maps that are created
        ss >> LU_ID;
        string curr_FT;
        while(!ss.eof()){
            //set the FT_type
            curr_FT=nb_FT.at(count2);
            // get the value
            double suitability;
            ss >> suitability;
            //insert to suitability vector in FT_trait file
            auto var = FT_traits::FtLinkList.find(curr_FT);
            shared_ptr<FT_traits> traits=var->second;
            traits->LU_suitability_forage.insert(std::make_pair(LU_ID, suitability));
            count2++;
        }
    }// end read suitability
}
