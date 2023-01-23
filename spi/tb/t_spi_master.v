`timescale 1ns/1ps
module t_spi_master(
  output reg [3:0] mosi,
  input      [3:0] miso,
  output reg       sclk,
  output reg       cs_n
);

reg integer num_of_lanes;
reg integer  sclk_period_ns;
reg din;
reg burst;
reg i;
reg j;

  initial begin
    cs_n = 1'b1;
    mosi = 1'b0;
    sclk = 1'b0;
  end

  task drive_word(
        input       num_of_lanes,
        input       sclk_period_ns,
        input       [15:0] din,
        input       burst 
  );
  begin
    
       cs_n = 0;

    for ( i=0;i<num_of_lanes;i++)
      mosi[i] = din[i];

    $display ("driving %4b on MOSI", mosi);
    
    #5;//(sclk_period_ns/2ns); //TODO add configurable delay here?

    for ( i=num_of_lanes;i<16;i+=num_of_lanes)
    begin
      sclk = 1;
      #5;//(sclk_period_ns/2ns);
      sclk = 1'b0; 
      //sample MISO at negedge
      for ( j=0;j<num_of_lanes;j++)
        mosi[j] = din[i+j];
      $display ("driving %4b on MOSI", mosi);
      #5;//(sclk_period_ns/2ns);
    end
    sclk = 1;
    #5;//(sclk_period_ns/2ns);
    sclk = 1'b0; 

    #5;//(sclk_period_ns/2ns);//TODO add configurable delay here?
    if (burst == 1'b0)
      cs_n = 1;
    mosi = 1'b0;
  end
  endtask

  

  task drive_dword(
         input       num_of_lanes,
        input       sclk_period_ns,
        input       [15:0] din,
        input       burst 
  );
  begin
       cs_n = 0;

    for ( i=0;i<num_of_lanes;i++)
      mosi[i] = din[i];

    $display ("driving %4b on MOSI", mosi);
    
    #5;//(sclk_period_ns/2ns); //TODO add configurable delay here?

    for ( i=num_of_lanes;i<32;i+=num_of_lanes)
    begin
      sclk = 1;
      #5;//(sclk_period_ns/2ns);
      sclk = 1'b0; 
      //sample MISO at negedge
      for ( j=0;j<num_of_lanes;j++)
        mosi[j] = din[i+j];
      $display ("driving %4b on MOSI", mosi);
      #5;//(sclk_period_ns/2ns);
    end
    sclk = 1;
    #5;//(sclk_period_ns/2ns);
    sclk = 1'b0; 

    #5;//(sclk_period_ns/2ns);//TODO add configurable delay here?
    if (burst == 1'b0)
      cs_n = 1;
    mosi = 1'b0;
  end
  endtask
endmodule
