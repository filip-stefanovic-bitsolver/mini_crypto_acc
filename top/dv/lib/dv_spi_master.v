module dv_spi_master(
  output reg [3:0] mosi,
  input      [3:0] miso,
  output reg       sclk,
  output reg       cs_n
);

initial begin
  cs_n = 1'b1;
  mosi = 'z;
  sclk = 1'b0;
end

/*task drive(
  input int num_of_lanes,
  input sclk_period_ns,
  input logic din [],
  output logic dout []
);
  int i;
  dout = new [din.size()];
begin
  cs_n = 0;
  mosi[0] = din[4*i+0];
  mosi[1] = din[4*i+1];
  mosi[2] = din[4*i+2];
  mosi[3] = din[4*i+3];
  #10ns; //TODO add configurable delay?
  while (i < din.size())
    sclk = 1;
    #(sclk_period_ns/2ns);
    sclk = 1'b0; 
    //sample MISO at negedge
    dout[4*i+0] = miso[0];
    dout[4*i+1] = miso[1];
    dout[4*i+2] = miso[2];
    dout[4*i+3] = miso[3];
    #(sclk_period_ns/2ns);
    i = i + num_of_lanes;
end

endtask*/

endmodule