#include "cell.h"
#include "gridenvironment.h"

CCell::CCell()
{

}

//! constructor of the cells and their variables
CCell::CCell(int index, int xx,int yy, int pa_id)
:index(index), x(xx),y(yy),pa_id(pa_id), TZ(), TZ_pot(), PID_def(), FT_pop_List(NULL)
{
    TZ=false;
    TZ_pot=false;
}// end constructor
