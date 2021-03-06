#define _MAIN_C_SRC

//-------------------------MODULES USED-------------------------------------
#include "ledctrl.h"
//-------------------------DEFINITIONS AND MACORS---------------------------



//-------------------------TYPEDEFS AND STRUCTURES--------------------------



//-------------------------PROTOTYPES OF LOCAL FUNCTIONS--------------------



//-------------------------EXPORTED VARIABLES ------------------------------



//-------------------------GLOBAL VARIABLES---------------------------------



//-------------------------EXPORTED FUNCTIONS-------------------------------
int main(void)
{
    ledctrl_init();
    while(1){
        ledctrl_blinkled(9, 200);
        ledctrl_blinkled(8, 400);
        ledctrl_blinkled(6, 800);
        ledctrl_blinkled(4, 1000);
        ledctrl_blinkled(2, 2000);
    }

    return 0;
}


//-------------------------LOCAL FUNCTIONS----------------------------------
void HardFault_Handler(void)
{
    while(1);
}
