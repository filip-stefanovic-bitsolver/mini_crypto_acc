module spi_data_path (input clk,
                      input reset_n,
                      input sclk,
                      input cs_n,
                      input [3:0]  mosi,
                      input [1:0]  spi_mode,
                      input [15:0] rdata,
                      output reg address_ready,
                      output reg data_ready, 
                      output reg [3:0]  miso,
                      output reg [19:0] addr,
                      output reg [3:0]  status,
                      output reg [15:0] wdata,
                      output reg cs_n_o,
                      output reg miso_start,
                      output reg status_ready

);
//aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa

reg posedge_sclk;
reg negedge_sclk;
reg [15:0] d;
reg sclk_syn_1;
reg sclk_syn_2;  
reg sclk_syn_3;
reg cs_n_syn_1;
reg cs_n_syn_2;
reg [2:0] cnt_selection_1;
reg integer cnt;
reg mod_1;
reg mod_2;
reg mod_4;
reg integer i_addr;
reg integer i_status;
reg integer i_wdata;
reg integer i_miso;
reg [3:0]  mosi_syn_1;
reg [3:0]  mosi_syn_2;

always @(*) 
  begin
    mod_1 = spi_mode[0] && (~spi_mode[1]);
    mod_2 = ~spi_mode[0] && spi_mode[1];
    mod_4 = spi_mode[0] && spi_mode[1];
    cs_n_o = cs_n;
  end

//detection positive and negative edge of sclk
always @(posedge clk or negedge reset_n)
  if (~reset_n)
    begin
      posedge_sclk <= 1'b0;
      negedge_sclk <= 1'b0;
      sclk_syn_1 <= 1'b0;
      sclk_syn_2 <= 1'b0;
      sclk_syn_3 <= 1'b0;
      cs_n_syn_1 <= 1'b0;
      cs_n_syn_2 <= 1'b0;
      mosi_syn_1 <= 4'b0000;
      mosi_syn_2 <= 4'b0000;
    end
  else
    begin
      sclk_syn_1 <= sclk;
      sclk_syn_2 <= sclk_syn_1;
      sclk_syn_3 <= sclk_syn_2;
      cs_n_syn_1 <= cs_n;
      cs_n_syn_2 <= cs_n_syn_1;
      mosi_syn_1 <= mosi;
      mosi_syn_2 <= mosi_syn_1;
      posedge_sclk <= sclk_syn_2 && (~sclk_syn_3);
      negedge_sclk <= ~sclk_syn_2 && (sclk_syn_3);
    end

//definition of cnt 
always @(posedge clk or negedge reset_n)
  if (~reset_n)
      cnt <= 0;
  else
    begin
      if (cs_n_syn_2 == 1'b1)
        cnt <= 0;
      else if ((cnt > 48) && (status[1]== 1'b1))
        cnt <= 32;
      else if ((cnt > 48) && (status[1]== 1'b0))
        cnt <= 0;
      else  
        begin
          if (posedge_sclk) 
            begin
              if (spi_mode == 2'b01)
                cnt <= cnt + 1;
              else if (spi_mode == 2'b10)
                cnt <= cnt + 2;
              else if (spi_mode == 2'b11)
                cnt <= cnt + 4;
              else
                cnt <= cnt;
            end
          else 
           cnt <= cnt;
        end
    end

//description of addr register
  always @(posedge clk or negedge reset_n)
  if (~reset_n)
    begin
      addr <= 20'h00000;
      i_addr <= 1'b0;
    end
  else
    begin
      if ((cnt <= 20) && (cnt > 0))
        begin
          if ((mod_1 && negedge_sclk ) &&
             (~(  mod_2 && negedge_sclk  )) &&
             (~(  mod_4 && negedge_sclk  )))
            begin
              addr[i_addr] <= mosi_syn_2[0]; 
              i_addr <= i_addr + 1; 
             end
          else if (~(mod_1 && negedge_sclk ) &&
             (~(  mod_2 && negedge_sclk  )) &&
             ((  mod_4 && negedge_sclk  )))
            begin
              addr[i_addr] <= mosi_syn_2[0];
              addr[i_addr + 1] <= mosi_syn_2[1]; 
              addr[i_addr + 2] <= mosi_syn_2[2];
              addr[i_addr + 3] <= mosi_syn_2[3];
              i_addr <= i_addr + 4; 
            end
          else if (~(mod_1 && negedge_sclk ) &&
             (( mod_2 && negedge_sclk )) &&
             (~(  mod_4 && negedge_sclk  )))
            begin
              addr[i_addr] <= mosi_syn_2[0];
              addr[i_addr + 1] <= mosi_syn_2[1]; 
              i_addr <= i_addr + 2; 
            end
          else
            addr <= addr; 
        end
      else
        begin
          addr <= addr; 
          i_addr <= 0; 
        end
    end

//description of status register
always @(posedge clk or negedge reset_n)
  if(~reset_n)
    begin
      status <= 4'b0000;
      i_status <= 0;
    end  
  else
    begin
      if ((cnt <= 24) && (cnt > 20))
        begin
          if ((mod_1 && negedge_sclk ) &&
             (~(  mod_2 && negedge_sclk  )) &&
             (~(  mod_4 && negedge_sclk  )))
            begin
              status[i_status] <= mosi_syn_2[0]; 
              i_status <= i_status + 1; 
             end
          else if (~(mod_1 && negedge_sclk ) &&
             (~(  mod_2 && negedge_sclk  )) &&
             ((  mod_4 && negedge_sclk  )))
            begin
              status[i_status] <= mosi_syn_2[0];
              status[i_status + 1] <= mosi_syn_2[1]; 
              status[i_status + 2] <= mosi_syn_2[2];
              status[i_status + 3] <= mosi_syn_2[3];
              i_status <= i_status + 4; 
            end
          else if (~(mod_1 && negedge_sclk ) &&
             (( mod_2 && negedge_sclk )) &&
             (~(  mod_4 && negedge_sclk  )))
            begin
              status[i_status] <= mosi_syn_2[0];
              status[i_status + 1] <= mosi_syn_2[1]; 
              i_status <= i_status + 2; 
            end
          else
            status <= status; 
        end
      else
        begin
          status <= status; 
          i_status <= 0; 
        end
    end

//description of wdata register
always @(posedge clk or negedge reset_n)
  if(~reset_n)
    begin
      wdata <= 16'h0000;
      i_wdata <= 0;
    end
  else
    begin
      if ((cnt <= 48) && (cnt > 32))
        begin
          if ((mod_1 && negedge_sclk && status[2] ) &&
             (~(  mod_2 && negedge_sclk && status[2]  )) &&
             (~(  mod_4 && negedge_sclk && status[2]  )))
            begin
              wdata[i_wdata] <= mosi_syn_2[0]; 
              i_wdata <= i_wdata + 1; 
            end
          else if (~(mod_1 && negedge_sclk && status[2] ) &&
             (~(  mod_2 && negedge_sclk && status[2]  )) &&
             ((  mod_4 && negedge_sclk && status[2]  )))
            begin
              wdata[i_wdata] <= mosi_syn_2[0];
              wdata[i_wdata + 1] <= mosi_syn_2[1]; 
              wdata[i_wdata + 2] <= mosi_syn_2[2];
              wdata[i_wdata + 3] <= mosi_syn_2[3];
              i_wdata <= i_wdata + 4; 
            end
          else if (~(mod_1 && negedge_sclk && status[2] ) &&
             (( mod_2 && negedge_sclk && status[2] )) &&
             (~(  mod_4 && negedge_sclk && status[2]  )))
            begin
              wdata[i_wdata] <= mosi_syn_2[0];
              wdata[i_wdata + 1] <= mosi_syn_2[1]; 
              i_wdata <= i_wdata + 2; 
            end
          else
            wdata <= wdata; 
        end
      else
        begin
          wdata <= wdata; 
          i_wdata <= 0;
        end
    end

//description of rdata register
always @(posedge clk or negedge reset_n)
  if (~reset_n)
      d <= 16'h0000;
  else if (((cnt == 32)) && negedge_sclk)
        d <= rdata; 

//description of miso register
always @(posedge clk or negedge reset_n)
  if(~reset_n)
    begin
      miso <= 4'b0000;
      i_miso <= 0;
    end
  else
    begin
      if ((cnt < 48) && (cnt >= 32))
        begin
          if ((cnt == (i_miso + 32) && mod_1 && posedge_sclk ) &&
             (~(  mod_2 && posedge_sclk  )) &&
             (~(  mod_4 && posedge_sclk  )))
            begin
              miso[0] <= d[i_miso]; 
              i_miso <= i_miso + 1; 
            end
          else if (~(mod_1 && posedge_sclk ) &&
             (~(  mod_2 && posedge_sclk  )) &&
             (( cnt == (i_miso + 32) && mod_4 && posedge_sclk  )))
            begin
              miso[0] <= d[i_miso];
              miso[1] <= d[i_miso + 1]; 
              miso[2] <= d[i_miso + 2];
              miso[3] <= d[i_miso + 3];
              i_miso <= i_miso + 4; 
            end
          else if (~(mod_1 && posedge_sclk ) &&
             (( cnt == (i_miso + 32) && mod_2 && posedge_sclk )) &&
             (~(  mod_4 && posedge_sclk  )))
            begin
              miso[0] <= d[i_miso];
              miso[1] <= d[i_miso + 1]; 
              i_miso <= i_miso + 2; 
            end
          else
            miso <= miso;  
        end
      else
        begin
          miso <= miso; 
          i_miso <= 0; 
        end
    end

//data_ready, addres_ready and miso_ready 
always @(posedge clk or negedge reset_n)
  if (~reset_n)
    begin
      data_ready    <= 1'b0;
      address_ready <= 1'b0;
      miso_start    <= 1'b0;
      status_ready    <= 1'b0;
    end  
  else
    begin
      data_ready    <= (cnt == 48 && posedge_sclk);
      address_ready <= (cnt == 20 && posedge_sclk);
      miso_start    <= ((cnt == 31 && posedge_sclk && mod_1)||
                        (cnt == 30 && posedge_sclk && mod_2)||
                        (cnt == 28 && posedge_sclk && mod_4));
      status_ready <= (cnt == 24 && posedge_sclk);
    end

endmodule
