
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
                      output reg [15:0] wdata
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
//reg integer i_miso_prvi;



always @(*) 
  begin
    mod_1 = spi_mode[0] && (~spi_mode[1]);
    mod_2 = ~spi_mode[0] && spi_mode[1];
    mod_4 = spi_mode[0] && spi_mode[1];
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
    end
  else
    begin
      sclk_syn_1 <= sclk;
      sclk_syn_2 <= sclk_syn_1;
      sclk_syn_3 <= sclk_syn_2;
      cs_n_syn_1 <= cs_n;
      cs_n_syn_2 <= cs_n_syn_1;
      negedge_sclk <= sclk_syn_2 && (~sclk_syn_3);
      posedge_sclk <= ~sclk_syn_2 && (sclk_syn_3);
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
        cnt <= 33;
      else if ((cnt > 48) && (status[1]== 1'b0))
        cnt <= 0;
      else  
        begin
          cnt_selection_1 <= {posedge_sclk,spi_mode};
          case (cnt_selection_1)
            3'b101: cnt <= cnt + 1;
            3'b110: cnt <= cnt + 2;
            3'b111: cnt <= cnt + 4;
            default: cnt <= cnt;
          endcase
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
            addr[i_addr] <= mosi[0]; 
            i_addr <= i_addr + 1; 
             end
          else if (~(mod_1 && negedge_sclk ) &&
             (~(  mod_2 && negedge_sclk  )) &&
             ((  mod_4 && negedge_sclk  )))
            begin
            addr[i_addr] <= mosi[0];
            addr[i_addr + 1] <= mosi[1]; 
            addr[i_addr + 2] <= mosi[2];
            addr[i_addr + 3] <= mosi[3];
            i_addr <= i_addr + 4; 
            end
          else if (~(mod_1 && negedge_sclk ) &&
             (( mod_2 && negedge_sclk )) &&
             (~(  mod_4 && negedge_sclk  )))
            begin
            addr[i_addr] <= mosi[0];
            addr[i_addr + 1] <= mosi[1]; 
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
              status[i_status] <= mosi[0]; 
              i_status <= i_status + 1; 
             end
          else if (~(mod_1 && negedge_sclk ) &&
             (~(  mod_2 && negedge_sclk  )) &&
             ((  mod_4 && negedge_sclk  )))
            begin
              status[i_status] <= mosi[0];
              status[i_status + 1] <= mosi[1]; 
              status[i_status + 2] <= mosi[2];
              status[i_status + 3] <= mosi[3];
              i_status <= i_status + 4; 
            end
          else if (~(mod_1 && negedge_sclk ) &&
             (( mod_2 && negedge_sclk )) &&
             (~(  mod_4 && negedge_sclk  )))
            begin
              status[i_status] <= mosi[0];
              addr[i_addr + 1] <= mosi[1]; 
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
              wdata[i_wdata] <= mosi[0]; 
              i_wdata <= i_wdata + 1; 
            end
          else if (~(mod_1 && negedge_sclk && status[2] ) &&
             (~(  mod_2 && negedge_sclk && status[2]  )) &&
             ((  mod_4 && negedge_sclk && status[2]  )))
            begin
              wdata[i_wdata] <= mosi[0];
              wdata[i_wdata + 1] <= mosi[1]; 
              wdata[i_wdata + 2] <= mosi[2];
              wdata[i_wdata + 3] <= mosi[3];
              i_wdata <= i_wdata + 4; 
            end
          else if (~(mod_1 && negedge_sclk && status[2] ) &&
             (( mod_2 && negedge_sclk && status[2] )) &&
             (~(  mod_4 && negedge_sclk && status[2]  )))
            begin
              wdata[i_wdata] <= mosi[0];
              wdata[i_wdata + 1] <= mosi[1]; 
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
  if(~reset_n)
      d <= 16'h0000;
  else
    begin
      if (((cnt == 30)) && negedge_sclk && ~status[2])
        d <= rdata;
      else
        d <= d;     
    end


//description of miso register
always @(posedge clk or negedge reset_n)
  if(~reset_n)
    begin
      miso <= 4'b0000;
      i_miso <= 0;
    end
  else
    begin
      if ((cnt <= 48) && (cnt > 32))
        begin
          if ((cnt == (i_miso + 33) && mod_1 && posedge_sclk ) &&
             (~(  mod_2 && posedge_sclk  )) &&
             (~(  mod_4 && posedge_sclk  )))
            begin
              miso[0] <= d[i_miso]; 
            
              i_miso <= i_miso + 1; 
            end
          else if (~(mod_1 && posedge_sclk ) &&
             (~(  mod_2 && posedge_sclk  )) &&
             (( cnt == (i_miso + 36) && mod_4 && posedge_sclk  )))
            begin
              miso[0] <= d[i_miso];
              miso[1] <= d[i_miso + 1]; 
              miso[2] <= d[i_miso + 2];
              miso[3] <= d[i_miso + 3];
              i_miso <= i_miso + 4; 
            end
          else if (~(mod_1 && posedge_sclk ) &&
             (( cnt == (i_miso + 34) && mod_2 && posedge_sclk )) &&
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

//data_ready and addres_ready 
always @(posedge clk or negedge reset_n)
  if (~reset_n)
    begin
      data_ready <= 1'b0;
      address_ready <= 1'b0;
    end  
  else
    begin
      if (cnt > 48)
        data_ready <= 1'b1;
      else 
        data_ready <= 1'b0;

      if ((cnt > 24) && (~status[1]))
        address_ready <= 1'b1;
      else 
        address_ready <= 1'b0;
    end

endmodule
