/**\file
 * \brief runparameter.cpp general run parameters
*/
#include "runparameter.h"

//! trait file for functional types
std::string SRunPara::NameFtFile="FuncTypeDef.txt";
//! landscape patch file
std::string SRunPara::NameLandscapePatchFile="Landscape.asc";
//! nest suitability file
std::string SRunPara::NameNestSuitabilityFile="LU_suitability_nest.txt";
//! forage suitability file
std::string SRunPara::NameForageSuitabilityFile="LU_suitability_forage.txt";
//! patch ID definition file
std::string SRunPara::NamePatchDefFile="Patch_ID_definitions.txt";
//! size order
std::string SRunPara::size_order="ascending";

//! parameters of specific run
SRunPara SRunPara::RunPara=SRunPara();

//! constructor
SRunPara::SRunPara():t_max(100), xmax(100),ymax(100), nb_LU(4), Nrep(1), qlossstart(1), qloss_trans_res(0.05), qloss_trans_nest(0.05), refresh_trans_effect_res(2), refresh_trans_effect_nest(2), refresh_frequency(1), refresh_measures(true)
{}

//eof  ---------------------------------------------------------------------
