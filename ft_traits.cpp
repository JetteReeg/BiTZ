#include "ft_traits.h"

#include <cstdlib>
#include <string>
#include <fstream>
#include <iostream>
#include <memory>
#include <cassert>
#include <sstream>

map< string, shared_ptr<FT_traits> > FT_traits::FtLinkList = map< string, shared_ptr<FT_traits> >();

FT_traits::FT_traits()
{

}

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
                    >> traits->omega >> traits->D >> traits->alpha >> traits->trans_effect;
            // add a new PFT to the list of PFTs
            FT_traits::FtLinkList.insert(std::make_pair(traits->FT_type, traits));
        }// end read all trait data for PFTs
}

void FT_traits::ReadSuitability(const string file){
    //Open InitFile
    ifstream SuitabilityFile(file.c_str());
        if (!SuitabilityFile.good()) {
            cerr << ("Error while opening suitability File");
            exit(3);
        }
    string line;
    // copy data
    getline(SuitabilityFile, line);
    //create vector of maps to store suitablity of LU classes for each FT
    std::stringstream ss(line);
    //skip first column
    string dummi;
    ss>>dummi;
    vector <string> nb_FT;
    //int count=0;
    while(ss){
        ss >> dummi;
        nb_FT.push_back(dummi);
        //count++;
    }
    // create a vector or maps for  all nb_FT
    // int = LU; double=suitability

    // now insert the numbers
    while (getline(SuitabilityFile, line))
    {
        std::stringstream ss(line);
        unsigned count2=0;
        int LU_ID;
        //first column holds the LU_ID; key for the maps that are created
        ss >> LU_ID;
        string curr_FT;
        while(ss){
            //set the FT_type
            curr_FT=nb_FT.at(count2);
            // get the value
            double suitability;
            ss >> suitability;
            //insert to suitability vector in FT_trait file
            auto var = FT_traits::FtLinkList.find(curr_FT);
            shared_ptr<FT_traits> traits=var->second;
            traits->LU_suitability.insert(std::make_pair(LU_ID, suitability));
        }
    }// end read suitability
}
