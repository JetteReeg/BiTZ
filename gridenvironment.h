#ifndef GRIDENVIRONMENT_H
#define GRIDENVIRONMENT_H

#include <QObject>
#include "runparameter.h"

using namespace std;

class GridEnvironment
{
public:
    GridEnvironment();//constructor
    vector <int> readLandscape();
};

#endif // GRIDENVIRONMENT_H
