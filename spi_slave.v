/**
SPI simple slave module.

Does not sends or receives any extra control signals.
Thus to test master with different SPI modes, 
slave processes need to be manually changed.

For synchronization:
Modes 0 and 3: slave needs to sample and send at rising edge
Modes 1 and 2: slave needs to sample and send at falling edge


Author: Jiovana Gomes (gomesjiovana@gmail.com)
25/10/2024

**/

module spi_slave #(
    parameter DATA_WIDTH = 32
) (
    input      rst, 
    input      cs, 
    input      sclk, 
    input      mosi, 
    output reg miso
);

reg [DATA_WIDTH-1:0] data;

// shifts mosi content into data register
always @(posedge sclk or negedge rst) begin
    if (!rst)
        data <= 32'b0;
    else if (!cs)
        data <= {data[DATA_WIDTH-2:0], mosi};
end

//sends data reg MSB as miso
always @(posedge sclk or negedge cs)
    if (!cs) 
        miso <= data[DATA_WIDTH-1];
    else
        miso <= 'bz;

endmodule