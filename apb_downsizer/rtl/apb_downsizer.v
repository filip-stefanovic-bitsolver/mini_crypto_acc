module apb_downsizer(
    input pclk,
    input preset_n, 
    input psel_i, 
    input penable_i,
    input pwrite_i, 
    input pready_i,
    input [3:0]pstrb_i,
    input [31:0]paddr_i,
    input [31:0]pwdata_i,
    input [15:0]prdata_i,  

    output psel_o, 
    output penable_o,
    output pwrite_o, 
    output pready_o,
    output [1:0]pstrb_o,
    output [31:0]paddr_o,
    output [15:0]pwdata_o,
    output [31:0]prdata_o

);
    reg psel_o;
    reg penable_o;
    reg pwrite_o; 
    reg pready_o;
    reg [1:0]pstrb_o;
    reg [31:0]paddr_o;
    reg [15:0]pwdata_o;
    reg [31:0]prdata_o;

    reg [3:0] state, next;

    localparam IDLE = 4'h0;
    localparam SETUP_IN = 4'h1;
    localparam ACCESS_IN = 4'h2;
    localparam SETUP_LOW = 4'h3;
    localparam ACCESS_LOW = 4'h4;
    localparam SETUP_HIGH = 4'h5;
    localparam ACCESS_HIGH = 4'h6;
    localparam READY = 4'h7;
    
    always @(posedge pclk or negedge preset_n)
        if(!preset_n) state <= IDLE;
        else state <= next; 
    
    always @(*) begin
        case (state)
            IDLE:
                if((psel_i == 1'b1))
                    next = SETUP_IN;
                else  
                    next = IDLE;
            SETUP_IN: 
                    next = ACCESS_IN;                   
            ACCESS_IN: 
                if(pstrb_i[1:0] == 2'b00) begin
                    if(pstrb_i[3:2] == 2'b00)
                        next = IDLE;
                    else    
                        next = SETUP_HIGH;
                end
                else
                    next = SETUP_LOW;
            SETUP_LOW:
                next = ACCESS_LOW;
            ACCESS_LOW:
                if(pready_i == 1'b1) begin
                    if(pstrb_i[3:2] == 2'b00)
                        next = READY;
                    else
                        next = SETUP_HIGH;
                end
                else
                    next = ACCESS_LOW;
            SETUP_HIGH:
                if(pstrb_i[3:2] == 2'b00) 
                    next = READY;
                else
                    next = ACCESS_HIGH;
            ACCESS_HIGH:
                if(pready_i == 1'b1) 
                    next = READY;
                else
                    next = ACCESS_HIGH;
            READY:
                next = IDLE;
        
               
        endcase
    end
    always @(posedge pclk or negedge preset_n)
        if(!preset_n) begin
                psel_o <= 1'b0;
                paddr_o <= 32'h00000000;
                pwdata_o <= 16'h0000;
                pstrb_o <= 2'b00;
                pready_o <= 1'b0;
                pwrite_o <= 1'b0;
                penable_o <= 1'b0;
        end
        else begin
            case(next) 
                SETUP_LOW: begin
                    psel_o <= psel_i;
                    paddr_o <= paddr_i;
                    pwdata_o <= pwdata_i[15:0];
                    pstrb_o <= pstrb_i[1:0];
                    pready_o <= 1'b0;
                    pwrite_o <= pwrite_i;
                    penable_o <= 1'b0;
                end
                ACCESS_LOW:
                    penable_o <= penable_i;
                SETUP_HIGH: begin
                    psel_o <= psel_i;
                    paddr_o <= paddr_i | 32'h00000002;
                    pwdata_o <= pwdata_i[31:16];
                    pstrb_o <= pstrb_i[3:2];
                    pready_o <= 1'b0;
                    pwrite_o <= pwrite_i;
                    penable_o <= 1'b0;
                    prdata_o[15:0] <= prdata_i;
                end
                ACCESS_HIGH:
                    penable_o <= penable_i;
                READY: begin
                    prdata_o[31:16] <= prdata_i;
                    pready_o <= pready_i;
                    penable_o <= 1'b0;
                    psel_o <= 1'b0;
                end
                default: begin
                    psel_o <= 1'b0;
                    paddr_o <= 32'h00000000;
                    pwdata_o <= 16'h0000;
                    pstrb_o <= 2'b00;
                    pready_o <= 1'b0;
                    pwrite_o <= 1'b0;
                    penable_o <= 1'b0;
                    prdata_o <= 32'h00000000;
                end
                
            endcase
        end
endmodule