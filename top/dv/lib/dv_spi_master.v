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

task drive(
  input  int num_of_lanes,
  input  int sclk_period_ns,
  input  bit din [],
  output bit dout []
);
  int i;
  dout = new [din.size()];
begin
  $display ("pulling down CS_n");
  cs_n = 0;
  mosi[0] = din[4*i+0];
  mosi[1] = din[4*i+1];
  mosi[2] = din[4*i+2];
  mosi[3] = din[4*i+3];
  $display ("driving %4b on MOSI", mosi);
  #(sclk_period_ns/2ns); //TODO add configurable delay here?
  while (i < din.size())
  begin
    sclk = 1;
    #(sclk_period_ns/2ns);
    sclk = 1'b0; 
    //sample MISO at negedge
    dout[4*i+0] = miso[0];
    dout[4*i+1] = miso[1];
    dout[4*i+2] = miso[2];
    dout[4*i+3] = miso[3];
    mosi[0] = din[4*i+0];
    mosi[1] = din[4*i+1];
    mosi[2] = din[4*i+2];
    mosi[3] = din[4*i+3];
    #(sclk_period_ns/2ns);
    i = i + num_of_lanes;
  end
  cs_n = 1;
end

endtask

endmodule