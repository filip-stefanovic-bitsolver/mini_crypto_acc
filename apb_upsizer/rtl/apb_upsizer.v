module apb_upsizer (pclk,prst,
                  pwrite_m_i,
                  psel_m_i,
                  penable_m_i,
                  pwdata_m_i,
                  prdata_m_o,
                  paddr_m_i,
                  pstrb_m_i,
                  pready_m_o,
                  pwrite_s_o,
                  psel_s_o,
                  penable_s_o,
                  pwdata_s_o,
                  prdata_s_i,
                  paddr_s_o,
                  pstrb_s_o,
                  pready_s_i
);

output  reg [15:0] prdata_m_o;
output  reg        pready_m_o,
                   pwrite_s_o,
                   psel_s_o,
                   penable_s_o;
output  reg [3:0]  pstrb_s_o;
output  reg [31:0] pwdata_s_o;
output  reg [31:0] paddr_s_o;
input              prst,
                   pclk,
                   psel_m_i,
                   penable_m_i,
                   pready_s_i;
input   [1:0]      pstrb_m_i;        
input   [31:0]     prdata_s_i;
input   [31:0]     paddr_m_i;
input   [15:0]     pwdata_m_i;
input              pwrite_m_i;   

reg [1:0] state,next_state;
reg temp;

localparam strobe_concatenate=2'b00;
localparam data_concatenate=16'h0000;
localparam data_concatenate_8=8'b00000000;

localparam IDLE = 2'b00;     
localparam SETUP = 2'b01;
localparam ACCESS_OUT_W = 2'b10;
localparam ACCESS_OUT_R = 2'b11;

always @(*) 
begin
    case(state)
        IDLE: 
            if(psel_m_i)
                next_state=SETUP;
            else
                next_state=IDLE;

        SETUP: 
            if(pwrite_m_i)
                next_state=ACCESS_OUT_W;
            else
                next_state=ACCESS_OUT_R;

        ACCESS_OUT_W: 
            if(pready_s_i)
                next_state=IDLE;
            else
                next_state=ACCESS_OUT_W;              

        ACCESS_OUT_R: 
            if(pready_s_i)
                next_state=IDLE;
            else
                next_state=ACCESS_OUT_R;             
    endcase
end

always @(posedge pclk or negedge prst)
    if(~prst)
        state <= IDLE;
    else
        state <= next_state;

always @(posedge pclk or negedge prst)
begin
    if(~prst)
        begin
            prdata_m_o<=16'h0000;
            pready_m_o<=1'b0;
            pwrite_s_o<=1'b0;
            psel_s_o<=1'b0;
            penable_s_o<=1'b0;
            pstrb_s_o<=4'b0000;
            pwdata_s_o<=32'h00000000;
            paddr_s_o<=32'h00000000;
        end    
    else
        begin 
        pready_m_o<=1'b0;
        case(state)
            IDLE:
            begin
                pwrite_s_o<=pwrite_m_i;    
                psel_s_o <= psel_m_i;
               
            end
            SETUP:
            begin
                penable_s_o<=penable_m_i;
                if(paddr_m_i[1]==1'b0)
                    begin
                        paddr_s_o <= paddr_m_i;
                        pstrb_s_o <= {strobe_concatenate,pstrb_m_i};
                        case(pstrb_m_i)
                        	2'b00: pwdata_s_o <= {data_concatenate,data_concatenate};
                        	2'b01: pwdata_s_o <= {data_concatenate,data_concatenate_8,pwdata_m_i[7:0]};
                        	2'b10: pwdata_s_o <= {data_concatenate,pwdata_m_i[15:8],data_concatenate_8};
                        	2'b11: pwdata_s_o <= {data_concatenate,pwdata_m_i};
                	endcase
                    end
                else
                    begin
                        paddr_s_o <= {paddr_m_i[31:2], 1'b0, paddr_m_i[0]};
                        pstrb_s_o <= {pstrb_m_i,strobe_concatenate};
                        case(pstrb_m_i)
                        	2'b00: pwdata_s_o <= {data_concatenate,data_concatenate};
                        	2'b01: pwdata_s_o <= {data_concatenate,data_concatenate_8,pwdata_m_i[7:0]};
                        	2'b10: pwdata_s_o <= {data_concatenate,pwdata_m_i[15:8],data_concatenate_8};
                        	2'b11: pwdata_s_o <= {data_concatenate,pwdata_m_i};
                	endcase
                    end
            end

            ACCESS_OUT_W:
            begin
                pready_m_o<=pready_s_i;
                if(pready_s_i)
                begin
                    psel_s_o <=1'b0;
                    penable_s_o<=1'b0;
                end
            end    
              
            ACCESS_OUT_R:   
            begin
                pready_m_o<=pready_s_i;
                if(pready_s_i)
        	begin
                    psel_s_o <=1'b0;
                    penable_s_o<=1'b0;
                end
                if(paddr_m_i[1]==1'b1)
                    prdata_m_o<=prdata_s_i[31:16];
                else
                    prdata_m_o<=prdata_s_i[15:0]; 
            end
        endcase    
        end
    end


endmodule
