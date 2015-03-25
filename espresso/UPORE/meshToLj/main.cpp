
#include <iostream>
#include <string>
#include <stdlib.h>

#include "capacitor.hpp"

//using namespace std;

int main()
{
    std::string path_le = "./left_electrode.msh";
    std::string path_re = "./right_electrode.msh";
    electrode* electrodes;
    electrodes = new electrode[2] { electrode(path_le, 100.0),
                                    electrode(path_re, -100.0)};

    capacitor cap(electrodes,2);

    return 0;
}
