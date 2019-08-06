#include "runparameter.h"

//! trait file for functional types
std::string SRunPara::NamePftFile="FuncTypeDef.txt";
//! landscape file
std::string SRunPara::NameLandscapeFile="Landscape.asc";

//! parameters of specific run
SRunPara SRunPara::RunPara=SRunPara();

SRunPara::SRunPara():t_max(100), xmax(100),ymax(100)
{}

//! parameters of specific run
SGridPara SGridPara::GridPara=SGridPara();

SGridPara::SGridPara():land_use(), land_use_id(), distance_LU(), sumCap()
{}

//eof  ---------------------------------------------------------------------
