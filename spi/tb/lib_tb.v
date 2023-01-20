`include "clk_reset_n_generator.v"
`include "t_apb_master.v"
`include "t_spi_master.v"
`include "spi_slave.v"

module lib_tb ( input clk,
                input reset_n,
                input [15:0] prdata_rm,
                input pready_rm,
                input pslverr_rm,
                input [15:0] prdata_icn,
                input pready_icn,
                input pslverr_icn,

                output reg [1:0] psel,
                output reg penable,
                output reg write,
                output reg strb,
                output reg [19:0] addr,
                output reg [15:0] wdata,
                output reg err
);

reg clk,
reg reset_n,
reg [15:0] prdata_rm,
reg pready_rm,
reg pslverr_rm,
reg [15:0] prdata_icn,
reg pready_icn,
reg pslverr_icn,



clk_reset_n_generator clk_reset_n_generator_i (
  .clk(clk), 
  .reset_n(reset_n)
);

t_apb_rm t_apb_rm_i(
  .pclk(clk),
  .prst_n(reset_n),
  .psel(psel),      
  .penable(penable), 
  .pwrite(pwrite),
  .paddr(paddr),
  .pwdata(pwdata), 
  .pstrb(pstrb),
  .prdata(prdata_rm),
  .pready(pready_rm),
  .pslverr(pslverr_rm)
);  

t_apb_icn t_apb_icn_i(
  .pclk(clk),
  .prst_n(reset_n),
  .psel(psel),      
  .penable(penable), 
  .pwrite(pwrite),
  .paddr(paddr),
  .pwdata(pwdata), 
  .pstrb(pstrb),
  .prdata(prdata_icn),
  .pready(pready_icn),
  .pslverr(pslverr_icn)
);  

t_spi_master t_spi_master_i(
  .mosi(mosi),
  .miso(miso),
  .sclk(sclk),
  .cs_n(cs_n)
);


spi_slave spi_slave_i ( clk,
                        reset_n,
                        sclk,
                        cs_n,
                        [3:0]  mosi,
                        [1:0]  spi_mode,
                        [15:0] prdata_rm,
                        pready_rm,
                        pslverr_rm,
                        [15:0] prdata_icn,
                        pready_icn,
                        pslverr_icn,

                        [3:0]  miso,
                        [1:0] psel,
                        penable,
                        write,
                        strb,
                        [19:0] addr,
                        [15:0] wdata,
                        err
);

endmodule