#ifndef RUNTIMEENVIRONMENT_H
#define RUNTIMEENVIRONMENT_H


class RuntimeEnvironment
{
public:
    RuntimeEnvironment();
    static int year;
    static void one_year();
    static void one_run();
    static void init();
    static void init_landscape();
    static void init_FTs();
    static void init_populations();
};

#endif // RUNTIMEENVIRONMENT_H
