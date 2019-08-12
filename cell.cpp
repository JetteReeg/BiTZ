#include "cell.h"
#include <gridenvironment.h>

CCell::CCell()
{

}

CCell::CCell(int index, int xx,int yy, int LU_id)
:index(index), x(xx),y(yy),LU_id(LU_id),sumCap(0),FT_pop_List(NULL)
{

}// end constructor
