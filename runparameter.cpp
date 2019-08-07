#include "runparameter.h"

//! trait file for functional types
std::string SRunPara::NamePftFile="FuncTypeDef.txt";
//! landscape file
std::string SRunPara::NameLandscapeFile="Landscape.asc";

//! parameters of specific run
SRunPara SRunPara::RunPara=SRunPara();

SRunPara::SRunPara():t_max(100), xmax(100),ymax(100), nb_LU(4)
{}

SGridPara::SGridPara(){;}

//eof  ---------------------------------------------------------------------
