# FPGA Interface
A simple interface to access the PL side of a Zynq device through TCP.

The link allows data transfer between a PC and the FPGA Fabric of the device for processing, testing HW blocks, etc.

The PS is used only to handle TCP/IP (though the lwIp library) and DMA for data transfer.

This project can also be used as an example for instantiating the AXI_DMA IP core. It is based upon Xilinx examples and templates.