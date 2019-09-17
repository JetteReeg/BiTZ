#include "runparameter.h"

//! trait file for functional types
std::string SRunPara::NameFtFile="FuncTypeDef.txt";
//! landscape patch file
std::string SRunPara::NameLandscapePatchFile="Landscape.asc";
//! suitability file
std::string SRunPara::NameSuitabilityFile="LU_suitability.txt";
//! patch ID definition file
std::string SRunPara::NamePatchDefFile="Patch_ID_definitions.txt";

//! parameters of specific run
SRunPara SRunPara::RunPara=SRunPara();

SRunPara::SRunPara():t_max(100), xmax(100),ymax(100), nb_LU(4)
{}

//eof  ---------------------------------------------------------------------
