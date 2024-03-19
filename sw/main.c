/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"


int main()
{

  u32 *address = NULL;
  init_platform();

  print("Program initialized.\n");

  //
  // Read the address
  //
  address = (u32 *) XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR;
  //Xil_DCacheFlushRange((u32)a,8*sizeof(u32));

  //
  // Change ZCU104 LEDs using shared BRAM
  //
  *(address) = 0x1;
  *(address) = 0x2;
  *(address) = 0x3;
  *(address) = 0x4;
  *(address) = 0x5;
  *(address) = 0x6;
  *(address) = 0x7;
  *(address) = 0x8;

  //
  // Print out data from first 10 memory locations of PS-PL
  // shared 8K by 32-bit BRAM memory buffer
  //
  for (u32 i=0;i<10;i++) {
	  xil_printf("Memory location %d: 0x%08x\n", i, *(address+i));
  }

  cleanup_platform();
  return 0;
}
