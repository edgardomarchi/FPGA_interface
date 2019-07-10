#ifndef __PLATFORM_CONFIG_H_
#define __PLATFORM_CONFIG_H_


#define PLATFORM_EMAC_BASEADDR XPAR_XEMACPS_0_BASEADDR

#define PLATFORM_ZYNQ

#define MAX_SIGNAL_LENGTH 1500

void platform_setup_interrupts(void);
void init_platform();
void cleanup_platform();

#endif
