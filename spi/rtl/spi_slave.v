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
                  output [3:0]  miso,
                  output  [1:0] psel,
                  output  penable,
                  output  pwrite,
                  output  [1:0] pstrb,
                  output  [19:0] paddr,
                  output  [15:0] pwdata,
                  output  err
);


// reg clk;
// reg reset_n;
// reg sclk;
// reg cs_n;
// reg [3:0]  mosi;
// reg [1:0]  spi_mode;
// reg [15:0] prdata_rm;
// reg pready_rm;
// reg pslverr_rm;
// reg [15:0] prdata_icn;
// reg pready_icn;
// reg pslverr_icn;
// reg [1:0] psel;
// reg penable;
// reg write;
// reg strb;
wire [19:0] addr;
wire [15:0] wdata;
wire [15:0] rdata;
wire [3:0] status;
wire [15:0] prdata_s;
wire [1:0] psel_s;
wire [1:0] pstrb_s;
wire [19:0] paddr_s;
wire [15:0] pwdata_s;

spi_data_path spi_data_path (  .clk(clk),
                               .reset_n(reset_n),
                               .sclk(sclk),
                               .cs_n(cs_n),
                               .mosi(mosi),
                               .spi_mode(spi_mode),
                               .rdata(rdata),

                               .address_ready(address_ready),
                               .data_ready(data_ready), 
                               .miso(miso),
                               .addr(addr),
                               .status(status),
                               .wdata(wdata),
                               .cs_n_o(cs_n_o),
                               .miso_start(miso_start),
                               .status_ready(status_ready)
                               
);


control_fsm control_fsm ( .clk(clk),
                          .reset_n(reset_n),
                          .address_ready(address_ready),
                          .data_ready(data_ready),
                          .addr(addr),
                          .status(status),
                          .wdata(wdata),
                          .pready_s(pready_s),
                          .prdata_s(prdata_s),
                          .pslverr_s_rm(pslverr_s_rm),
                          .pslverr_s_icn(pslverr_s_icn),
                          .cs_n_o(cs_n_o),
                          .miso_start(miso_start),
                          .psel_s(psel_s),
                          .penable_s(penable_s),
                          .pwrite_s(pwrite_s), 
                          .pstrb_s(pstrb_s),
                          .paddr_s(paddr_s),
                          .pwdata_s(pwdata_s),
                          .rdata(rdata),
                          .err(err),
                          .status_ready(status_ready)
);


secure_fsm secure_fsm ( .clk(clk),
                         .reset_n(reset_n),
                         .psel_s(psel_s),
                         .penable_s(penable_s),
                         .pwrite_s(pwrite_s),
                         .pstrb_s(pstrb_s),
                         .paddr_s(paddr_s),
                         .pwdata_s(pwdata_s),
                         .prdata_rm(prdata_rm),
                         .pready_rm(pready_rm),
                         .pslverr_rm(pslverr_rm),
                         .prdata_icn(prdata_icn),
                         .pready_icn(pready_icn),
                         .pslverr_icn(pslverr_icn),
                         .psel(psel),
                         .penable(penable),
                         .pwrite(pwrite),
                         .pstrb(pstrb),
                         .paddr(paddr),
                         .pwdata(pwdata),
                         .prdata_s(prdata_s),
                         .pready_s(pready_s),
                         .pslverr_s_rm(pslverr_s_rm),
                         .pslverr_s_icn(pslverr_s_icn)
);

endmodule

