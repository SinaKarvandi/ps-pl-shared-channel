/******************************************************************************
* Copyright (C) 2023 Advanced Micro Devices, Inc. All Rights Reserved.
* SPDX-License-Identifier: MIT
******************************************************************************/
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
#include <xil_io.h>
#include <xparameters_ps.h>
#include "xparameters.h"
#include "xil_types.h"
#include "xscugic.h"
#include "sleep.h"

#define INTC_DEVICE_ID XPAR_XSCUGIC_0_BASEADDR // Device ID of the interrupt controller
#define INTC_INTERRUPT_ID 121U // IRQ_F2P[0:9] (Should be changed based on each board) - For ZCU104: 121U

/* Interrupt handler function prototype */
void interrupt_handler (void *CallbackRef);

static XScuGic_Config *intr_cfg; // Configuration parameters of interrupt controller
static XScuGic intr_ctl; // Interrupt controller
static u32 interrupt_times = 0; // Track the number of times PL interrupts PS

int main()
{
    s32 status;
    u32 *address = NULL;

    init_platform();

    print("Hello World\n\r");
    print("Successfully ran Hello World application");

    //------------------------------------------------------------------------
    // Setup PL to PS interrutp
    //

    //
    // Initializing the interrupt controller
    //
    intr_cfg = XScuGic_LookupConfig(INTC_DEVICE_ID);
    if (NULL == intr_cfg) {
        return XST_FAILURE;
    }
    status = XScuGic_CfgInitialize(&intr_ctl, intr_cfg, intr_cfg->CpuBaseAddress) ;
    if (status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    //
    // Set interrupt priority and rising-edge trigger
    //
    XScuGic_SetPriorityTriggerType(&intr_ctl, INTC_INTERRUPT_ID, 0xA0, 0x3);

    //
    // Connect interrupt controller to ARM hardware interrupt handling logic
    //
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT, (Xil_ExceptionHandler) XScuGic_InterruptHandler, &intr_ctl);

    //
    // Enable ARM interrupts
    //
    Xil_ExceptionEnable();

    //
    // Connect interrupt handler
    //
    status = XScuGic_Connect(&intr_ctl, INTC_INTERRUPT_ID, (Xil_InterruptHandler) interrupt_handler, NULL);

    if (status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    //
    // Enable device interrupt
    //
    XScuGic_Enable(&intr_ctl, INTC_INTERRUPT_ID);

    //------------------------------------------------------------------------
    // Change signal from PS to PL
    //
	Xil_Out8(XPAR_XGPIO_0_BASEADDR,0xFF);

    //------------------------------------------------------------------------
    // Read/Write from shared BRAM
    //

    //
    // Read the address
    //
    address = (u32 *) XPAR_AXI_BRAM_0_BASEADDRESS;
    //Xil_DCacheFlushRange((u32)a,8*sizeof(u32));

    //
    // Change ZCU104 LEDs using shared BRAM
    //
    *(address) = 0x1;
    *(address) = 0x2;
    *(address) = 0x3;

    //
    // Print out data from first 10 memory locations of PS-PL
    // shared 8K by 32-bit BRAM memory buffer
    //
    for (u32 i=0;i<3;i++) {
        xil_printf("Memory location %d: 0x%08x\n", i, *(address+i));
    }

    //
    // Sleep loop, interrupts have the spotlight
    //
    while (TRUE) {
        sleep(10);
    }

    cleanup_platform();
    return 0;
}

//
// Interrupt handler
//
void interrupt_handler(void *CallbackRef) {
    XScuGic_Disable(&intr_ctl, INTC_INTERRUPT_ID);
    xil_printf("Interrupted - %u\n", ++interrupt_times) ;
    XScuGic_Enable(&intr_ctl, INTC_INTERRUPT_ID);
}
