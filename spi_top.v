/**
Serial Peripheral Interface (SPI) protocol basic implementation.

Might need refinement:
  - adding overflow control,
  - a buffer to save data at the end of transaction.
  - spi_clock frequency control

Can handle the four SPI modes using the signals cpha and cpol.
Mode 0: cpol-0 cpha-0 Mode 1: cpol-0 cpha-1 
Mode 2: cpol-1 cpha-0 Mode 3: cpol-1 cpha-1

For synchronization:
Modes 0 and 3: slave needs to sample and send at rising edge
Modes 1 and 2: slave needs to sample and send at falling edge
(this needs to be manually changed on slave's processes)

Needs further testing changing reg width and transaction size.
Tested only with default parameters.

Author: Jiovana Gomes (gomesjiovana@gmail.com)
25/10/2024
**/

module spi_master #(
    parameter REG_WIDTH  = 32,
    parameter COUNTER_WIDTH = $clog2(REG_WIDTH),
    parameter TRANS_SIZE = 32
)(
    // system side
    input rstn, 
    input sys_clk, 
    input t_start,
    input [REG_WIDTH-1:0] data_in, // data to feed SPI buffer
    input [COUNTER_WIDTH:0] t_size, // transaction size, how many bits to transmit
    input cpha,// phase of each bit transmission cycle relative to spi_clk
    input cpol, //spi_clock polarity: if true clock idles high
    // SPI side 
    input miso,
    output wire mosi,
    output reg spi_clk,
    output reg cs
);

reg [REG_WIDTH-1:0] shift_reg_neg, shift_reg_pos;
wire [REG_WIDTH-1:0] shift_reg;
reg [COUNTER_WIDTH:0] count;


// generates and controls the serial clock polarity based on cpol flag
always @(*) begin
  if (!cs) begin
    if (cpol)
      spi_clk <= ~sys_clk;
    else
      spi_clk <= sys_clk;
  end else begin
    if (cpol)
      spi_clk <= 1'b1;
    else
      spi_clk <= 1'b0;
  end

end

//controls the clock counter and chip select signals
always @(posedge sys_clk) begin
  if (!rstn) begin
    count <= 'b0;   
    cs <= 1'b1;
  end else if (t_start) begin
    count <= t_size;
    cs <= 1'b0;
  end else begin
    count <= count - 1'b1;
    cs <= 1'b0;
  end
end


//sends MSB first
assign mosi = (!cs) ? shift_reg[REG_WIDTH-1] : 1'bz;

// samples miso at negedge 
always @(negedge spi_clk or negedge rstn) begin
  if (!rstn)
    shift_reg_neg <= 'b0;
  else begin
    if (t_start)
      shift_reg_neg <= data_in;
    else if (!cs) 
      shift_reg_neg <= {shift_reg_neg[REG_WIDTH-2:0], miso};
  end
end

//samples miso at posedge
always @(posedge spi_clk or negedge rstn) begin
  if (!rstn)
    shift_reg_pos <= 'b0;
  else begin
    if (t_start)
      shift_reg_pos <= data_in;
    else if (!cs) 
      shift_reg_pos <= {shift_reg_pos[REG_WIDTH-2:0], miso};
  end
end

// decides whether to use values sampled at pos or neg edges based on control flags
assign shift_reg = (cpha ~^ cpol) ? shift_reg_neg : shift_reg_pos;

endmodule