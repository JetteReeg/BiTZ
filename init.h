#ifndef INIT_H
#define INIT_H

#include <QObject>
#include<strstream>
using namespace std;

class Init : public QObject
{
    Q_OBJECT
public:
    explicit Init(QObject *parent = nullptr);
    void readLandscape(string filename);
    void initPopulations();
    //global parameters
    //years <-> runtime
    int years;
    //current year
    int year;
    //name landscape file
    string filename_landscape="landscape.asc";
    //grid size
    int grid_size=0;
    //PFT classifications

signals:

public slots:
};

#endif // INIT_H
