# PS <> PL Shared Channel 

## Description

This Verilog/VHDL project creates a channel between the Processing System (PS) and the Programmable Logic (PL) by sharing an 8 KB (can be customized) Block RAM (BRAM) as well as an interrupt line from PL to PS, and a GPIO line from PS to PL. The BRAM is made accessible for both PS and PL communication.

## Usage

The Verilog module `top` connects to both the PS and PL of the ZCU104 platform, facilitating access to a shared 8 KB BRAM. It contains logic for accessing the BRAM from both PS and PL, enabling data transfer and manipulation.

## Supported Boards

Currently, the following boards are supported, but you can modify the source code and use it on other Xilinx boards.

- ZCU104

## Components

### Input/Output Ports

`led_out_0`, `led_out_1`, `led_out_2`, `led_out_3`: Output wire ports for connecting to LEDs.

- The 0th LED is turned on when the PS sends a signal to the PS.
- The 1st LED is a blinker indicating that an interrupt is triggered from PL to PS.
- The 2nd and 3rd LEDs are connected to the first 2 bits of the 8 KB BRAM.
- The interrupt handler will be triggered by each blink of the 1st LED, and you can see the output by using a serial monitor.

### LEDs Placement Order

Here's the picture of ZCU104's LEDs placement order.

![ZCU104 LEDs placement order](https://raw.githubusercontent.com/SinaKarvandi/images/main/repo/ps-pl-shared-channel/zcu104-shared-channel.jpg)

## How to Use

To utilize this Verilog project, follow these steps:

1. Ensure you have Xilinx Vivado installed on your system.
2. Clone the source code + TCL script (`hwdbg-zcu104.tcl`).
3. Open `Vivado Tcl Shell` and navigate to the directory where you have saved the TCL script (Using the `cd` command).
6. Run the TCL script by typing `source hwdbg-zcu104.tcl` in the Vivado command tool.
7. Vivado will then create a Vivado project for the design.
8. Open the generated Vivado project and perform synthesis, implementation, and bitstream generation as per your requirements.
9. Once the bitstream is generated, export the hardware to Vivado.
10. Open the Vitis IDE.
11. Create a platform and an application in Vitis.
12. Copy the contents of the `sw` folder from the generated Vivado project to the Vitis application project.
13. Compile the application in Vitis.
14. Program the FPGA with the generated bitstream using Vitis.
15. Test the functionality of the shared channel over PS <> PL. The LEDs on the ZCU104 board should be changed based on the values produced in the C code.