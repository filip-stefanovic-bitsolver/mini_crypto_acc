`include "spi_data_path.v"
`include "control_fsm.v"
`include "secure_fsm.v"

module spi_slave (input clk,
                  input reset_n,
                  input sclk,
                  input cs_n,
                  input [3:0]  mosi,
                  input [1:0]  spi_mode,
                  input [15:0] prdata_rm,
                  input pready_rm,
                  input pslverr_rm,
                  input [15:0] prdata_icn,
                  input pready_icn,
                  input pslverr_icn,
                  output reg [3:0]  miso,
                  output reg [1:0] psel,
                  output reg penable,
                  output reg write,
                  output reg strb,
                  output reg [19:0] addr,
                  output reg [15:0] wdata,
                  output reg err
);


reg clk;
reg reset_n;
reg sclk;
reg cs_n;
reg [3:0]  mosi;
reg [1:0]  spi_mode;
reg [15:0] prdata_rm;
reg pready_rm;
reg pslverr_rm;
reg [15:0] prdata_icn;
reg pready_icn;
reg pslverr_icn;
//reg [3:0]  miso;
//reg [1:0] psel;
//reg penable;
//reg write;
//reg strb;
//reg [19:0] addr;
//reg [15:0] wdata;


spi_data_path spi_data_path0 ( clk,
                               reset_n,
                               sclk,
                               cs_n,
                               mosi,
                               spi_mode,
                               rdata,

                               address_ready,
                               data_ready, 
                               miso,
                               addr,
                               status,
                               wdata,
                               cs_n_o,
                               miso_start
);


control_fsm control_fsm0 ( clk,
                           reset_n,
                           address_ready,
                           data_ready,
                           addr,
                           status,
                           wdata,
                           pready_s,
                           prdata_s,
                           pslverr_s_rm,
                           pslverr_s_icn,
                           cs_n_o,
                           miso_start,

                           psel_s,
                           penable_s,
                           pwrite_s, 
                           pstrb_s,
                           paddr_s,
                           pwdata_s,
                           rdata,
                           err
);


secure_fsm secure_fsm0 ( clk,
                         reset_n,
                         psel_s,
                         penable_s,
                         pwrite_s,
                         pstrb_s,
                         paddr_s,
                         pwdata_s,
                         prdata_rm,
                         pready_rm,
                         pslverr_rm,
                         prdata_icn,
                         pready_icn,
                         pslverr_icn,

                         psel,
                         penable,
                         pwrite,
                         pstrb,
                         paddr,
                         pwdata,
                         prdata_s,
                         pready_s,
                         pslverr_s_rm,
                         pslverr_s_icn
);

endmodule

