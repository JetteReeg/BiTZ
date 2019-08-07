#ifndef GRIDENVIRONMENT_H
#define GRIDENVIRONMENT_H

#include <QObject>
#include "runparameter.h"

using namespace std;

class GridEnvironment
{
public:
    GridEnvironment();//constructor
    //! read the lanscape
    vector <int> readLandscape();
    //! set the coordinates for each vector entry
    std::tuple<int,int> set_coordinates(int);
    //! calculate the closest distance to other land use class
    std::map<int, double> get_distance_LU(int);
};

#endif // GRIDENVIRONMENT_H
