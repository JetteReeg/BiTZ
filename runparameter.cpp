#include "runparameter.h"

//! trait file for functional types
std::string SRunPara::NameFtFile="FuncTypeDef.txt";
//! landscape class file
std::string SRunPara::NameLandscapeClassFile="Landscape.asc";
//! landscape patch file
std::string SRunPara::NameLandscapePatchFile="Landscape.asc";
//! suitability file
std::string SRunPara::NameSuitabilityFile="LU_suitability.txt";

//! parameters of specific run
SRunPara SRunPara::RunPara=SRunPara();

SRunPara::SRunPara():t_max(100), xmax(100),ymax(100), nb_LU(4)
{}

//eof  ---------------------------------------------------------------------
