module t_spi_master(
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
    input  byte din []
  );
    bit din_bits[];
  begin
    din_bits = new [din.size()*8];
    for (int i=0;i<din.size();i++)
      for (int j=0;j<8;j++)
        din_bits[8*i+j] = ((din[i]>>j) & 1);
    foreach (din[i])
      $display("din[%d] = %8x", i, din[i]);
    foreach (din_bits[i])
      $display("din_bits[%d] = %b", i, din_bits[i]);
    $display("din_bits.size() = %d", din_bits.size());
    $display ("pulling down CS_n");
    cs_n = 0;

    for (int i=0;i<num_of_lanes;i++)
      mosi[i] = din_bits[i];

    $display ("driving %4b on MOSI", mosi);
    
    #(sclk_period_ns/2ns); //TODO add configurable delay here?

    for (int i=num_of_lanes;i<din_bits.size();i+=num_of_lanes)
    begin
      sclk = 1;
      #(sclk_period_ns/2ns);
      sclk = 1'b0; 
      //sample MISO at negedge
      for (int j=0;j<num_of_lanes;j++)
        mosi[j] = din_bits[i+j];
      $display ("driving %4b on MOSI", mosi);
      #(sclk_period_ns/2ns);
    end
    sclk = 1;
    #(sclk_period_ns/2ns);
    sclk = 1'b0; 

    #(sclk_period_ns/2ns);//TODO add configurable delay here?

    cs_n = 1;
    mosi = 'z;
  end

endtask

endmodule