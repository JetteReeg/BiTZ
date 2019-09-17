#include "cell.h"
#include <gridenvironment.h>

CCell::CCell()
{

}

CCell::CCell(int index, int xx,int yy, int pa_id)
:index(index), x(xx),y(yy),pa_id(pa_id), PID_def(),sumCap(0),FT_pop_List(NULL)
{

}// end constructor
