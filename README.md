# Shared BRAM over PS <> PL

## Description

This Verilog/VHDL project facilitates sharing an 8 KB (can be customized) Block RAM (BRAM) between the Processing System (PS) and the Programmable Logic (PL) on the ZCU104 platform (can be used in other boards). The BRAM is made accessible for both PS and PL communication.

## Usage

The Verilog module `top` connects to both the PS and PL of the ZCU104 platform, facilitating access to a shared 8 KB BRAM. It contains logic for accessing the BRAM from both PS and PL, enabling data transfer and manipulation.

## Components

### Input/Output Ports

- `led_out_0`, `led_out_1`, `led_out_2`, `led_out_3`: Output wire ports for connecting to LEDs.

## How to Use

To utilize this Verilog project, follow these steps:

1. Ensure you have Xilinx Vivado installed on your system.
2. Clone the source code + TCL script (`hwdbg-zcu104.tcl`).
3. Open `Vivado Tcl Shell` and navigate to the directory where you have saved the TCL script (Using the `cd` command).
6. Run the TCL script by typing `source hwdbg-zcu104.tcl` in the Vivado command tool.
7. Vivado will then create a Vivado project for the design.
8. Open the generated Vivado project and perform synthesis, implementation, and bitstream generation as per your requirements.
9. Once the bitstream is generated, export the hardware in Vivado.
10. Open the Vitis IDE.
11. Create a platform and an application in Vitis.
12. Copy the contents of the `sw` folder from the generated Vivado project to the Vitis application project.
13. Compile the application in Vitis.
14. Program the FPGA with the generated bitstream using Vitis.
15. Test the functionality of the shared BRAM over PS <> PL. The LEDs on the ZCU104 board should be changed based on the values produced in the C code.