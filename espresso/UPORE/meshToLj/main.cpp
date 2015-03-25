
#include <iostream>
#include <string>
#include <stdlib.h>

#include "capacitor.h"

//using namespace std;

int main()
{
    electrode* electrodes;
    electrodes = new electrode[2] { electrode("./left_electrode.msh", 100.0),
                                    electrode("./right_electrode.msh", -100.0)};

    capacitor cap(electrodes,2);

    return 0;
}
