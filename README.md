# Serial Peripheral Interface (SPI)
 Basic implementation in Verilog language.
 See Wikipedia for further description. https://en.wikipedia.org/wiki/Serial_Peripheral_Interface

 Might need refinement:
  - adding overflow control,
  - a buffer to save data at the end of each transaction.
  - spi_clock frequency control

The master can handle the four SPI operation modes using the signals cpha (clock phase) and cpol (clock polarity):

Mode 0: cpol-0 cpha-0 |
Mode 1: cpol-0 cpha-1 |
Mode 2: cpol-1 cpha-0 |
Mode 3: cpol-1 cpha-1 

For synchronization:

Modes 0 and 3: slave needs to sample and send at rising edge.
Modes 1 and 2: slave needs to sample and send at falling edge.
(this needs to be manually changed on slave's processes).

---> Needs further testing changing reg width and transaction size.
Tested only with default parameters.
