#ifndef POPULATIONDYNAMICS_H
#define POPULATIONDYNAMICS_H

#include <QObject>

class Populationdynamics : public QObject
{
    Q_OBJECT
public:
    explicit Populationdynamics(QObject *parent = nullptr);
    void dyn_function(int PopSize, int K, double r){
    };


signals:

public slots:
};

#endif // POPULATIONDYNAMICS_H
