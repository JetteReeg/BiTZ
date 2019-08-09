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
                    >> traits->omega >> traits->D >> traits->alpha;
            // add a new PFT to the list of PFTs
            FT_traits::FtLinkList.insert(std::make_pair(traits->FT_type, traits));
        }// end read all trait data for PFTs
}
