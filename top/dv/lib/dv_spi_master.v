module dv_spi_master(
  output reg [3:0] mosi,
  input      [3:0] miso,
  output reg       sclk,
  output reg       cs_n,
  output reg [1:0] spi_mode

);


  initial begin
    cs_n = 1'b1;
    mosi = 'z;
    sclk = 1'b0;
    spi_mode = 2'b00;
  end

  task drive_word(
    input int          num_of_lanes,
    input int          sclk_period_ns,
    input logic        [15:0] din,
    input logic        burst = 0,
    //input logic        result_en,
    output logic       [15:0] result_w
  );
  begin
    if (num_of_lanes == 1)
      spi_mode = 2'b01;
    else if (num_of_lanes == 2)
      spi_mode = 2'b10;
    else if (num_of_lanes == 4)
      spi_mode = 2'b11;    
    else   
      spi_mode = 2'b00; 
    cs_n = 0;
    // for (int i=0;i<num_of_lanes;i++)
    //   mosi[i] = din[i];
    $display ("driving %4b on MOSI", mosi);
    #(sclk_period_ns/2ns); //TODO add configurable delay here?
    for (int i=0;i<16;i+=num_of_lanes)
    begin
      sclk = 1;
      for (int j=0;j<num_of_lanes;j++)
        mosi[j] = din[i+j];
      $display ("driving %4b on MOSI", mosi);
      #(sclk_period_ns/2ns);
      sclk = 1'b0; 
      //sample MISO at negedge
      //if (result_en) begin
      if (i>=0 && i<16 && (num_of_lanes == 1)) 
        begin
          for (int j=0;j<num_of_lanes;j++)
            result_w[i+j] = miso[j];
        end
        if (i>=0 && i<16 && (num_of_lanes == 2)) 
        begin
          for (int j=0;j<num_of_lanes;j++)
            result_w[i+j] = miso[j];
        end
        if (i>=0 && i<16 && (num_of_lanes == 4)) 
        begin
          for (int j=0;j<num_of_lanes;j++)
            result_w[i+j] = miso[j];
        end
        //end
        #(sclk_period_ns/2ns);
    end
    sclk = 1;
    #(sclk_period_ns/2ns);
    // if (num_of_lanes == 1) 
    //   result_w[15] = miso[0];
    // else if (num_of_lanes == 2)
    //   result_w[15:14] = miso[1:0];
    // else if (num_of_lanes == 4) 
    //   result_w[15:12] = miso[3:0];
    sclk = 1'b0; 
    #(sclk_period_ns/2ns);//TODO add configurable delay here?
    if (burst == 1'b0)
      cs_n = 1;
      mosi = 'z;
  end
  endtask

  task drive_dword(
    input int          num_of_lanes,
    input int          sclk_period_ns,
    input logic [47:0] din,
    input logic        burst = 0,
    //input logic        result_en,
    output reg       [15:0] result
  );
  begin
    if (num_of_lanes == 1)
        spi_mode = 2'b01;
      else if (num_of_lanes == 2)
        spi_mode = 2'b10;
      else if (num_of_lanes == 4)
        spi_mode = 2'b11;    
      else   
        spi_mode = 2'b00;
      cs_n = 0;
    // for (int i=0;i<num_of_lanes;i++)
    //   mosi[i] = din[i];
    $display ("driving %4b on MOSI", mosi);
    #(sclk_period_ns/2ns); //TODO add configurable delay here?
    for (int i=0;i<48;i+=num_of_lanes)
    begin
      sclk = 1;
      for (int j=0;j<num_of_lanes;j++)
        mosi[j] = din[i+j];
      $display ("driving %4b on MOSI", mosi);
      #(sclk_period_ns/2ns);
      sclk = 1'b0; 
      //sample MOSI at negedge
      //if (result_en) begin
      if (i>=32 && i<48 && (num_of_lanes == 1)) 
      begin
        for (int j=0;j<num_of_lanes;j++)
          result[i-32+j] = miso[j];
      end
      if (i>=32 && i<48 && (num_of_lanes == 2)) 
      begin
        for (int j=0;j<num_of_lanes;j++)
          result[i-32+j] = miso[j];
      end
      if (i>=32 && i<48 && (num_of_lanes == 4)) 
      begin
        for (int j=0;j<num_of_lanes;j++)
          result[i-32+j] = miso[j];
      end
      //end
      #(sclk_period_ns/2ns);
    end
    sclk = 1;
    #(sclk_period_ns/2ns);
    // if (num_of_lanes == 1) 
    //   result[15] = miso[0];
    // else if (num_of_lanes == 2)
    //   result[15:14] = miso[1:0];
    // else if (num_of_lanes == 4) 
    //   result[15:12] = miso[3:0];
    sclk = 1'b0; 
    #(sclk_period_ns/2ns);//TODO add configurable delay here?
    if (burst == 1'b0)
      cs_n = 1;
      mosi = 'z;
  end
  endtask

/*
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
*/
endmodule
