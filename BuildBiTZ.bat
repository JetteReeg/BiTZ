g++ -c -fmessage-length=0 -std=c++0x -o gridenvironment.o gridenvironment.cpp
g++ -c -fmessage-length=0 -std=c++0x -o cell.o cell.cpp
g++ -c -fmessage-length=0 -std=c++0x -o ft_pop.o ft_pop.cpp
g++ -c -fmessage-length=0 -std=c++0x -o ft_traits.o ft_traits.cpp
g++ -c -fmessage-length=0 -std=c++0x -o lcg.o lcg.cpp
g++ -c -fmessage-length=0 -std=c++0x -o output.o output.cpp
g++ -c -fmessage-length=0 -std=c++0x -o runparameter.o runparameter.cpp
g++ -c -fmessage-length=0 -std=c++0x -o runtimeenvironment.o runtimeenvironment.cpp
g++ -c -fmessage-length=0 -std=c++0x -o main.o main.cpp
g++ -static -o BiTZ cell.o ft_pop.o ft_traits.o gridenvironment.o lcg.o main.o output.o runparameter.o runtimeenvironment.o