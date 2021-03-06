/* 同步 FIFO 4*128  */

// 一种4bit 128深度的 同步FIFO设计
// @`13
// 2017年6月6日
// 哈尔滨工业大学（威海） EDA课程设计

module fifo(clock,reset,read,write,fifo_in,fifo_out,fifo_empty,fifo_full);

    parameter DEPTH = 128;  						// 128 深
	 parameter DEPTH_BINARY = 7;  				// 深度的二进制位数
	 parameter WIDTH = 4;							// 4bit宽
	 parameter MAX_CONT = 7'b1111111;			// 计数器最大值127 [0~127]
	 
	 // LED 灯的二进制表示
	 parameter 
		 reg0=7'b0000001,
		 reg1=7'b1001111,
		 reg2=7'b0010010,
		 reg3=7'b0000110,
		 reg4=7'b1001100,
		 reg5=7'b0100100,
		 reg6=7'b0100000,
		 reg7=7'b0001101,
		 reg8=7'b0000000,
		 reg9=7'b0000100,
		 rega=7'b0001000,
		 regb=7'b1100000,
		 regc=7'b0110001,
		 regd=7'b1000010,
		 rege=7'b0110000,
		 regf=7'b0111000;
	 
	 
    input clock,reset,read,write;       			// 时钟，重置，读开关，写开关
    input [WIDTH-1:0]fifo_in;    					// FIFO 数据输入 
    output[WIDTH-1:0]fifo_out;            	   // FIFO 数据输出
    output fifo_empty,fifo_full;        			// 空标志,满标志

    reg [WIDTH-1:0]fifo_out;                    // 数据输出寄存器
    reg [WIDTH-1:0]ram[DEPTH-1:0];              // 128深度 8宽度的 RAM 寄存器
    reg [DEPTH_BINARY-1:0]read_ptr,write_ptr,counter;        // 读指针，写指针，计数器 长度为2^7

    wire fifo_empty,fifo_full;          			// 空标志,满标志
	 
	 initial                                                
	 begin             
		counter = 0;
		read_ptr = 0;
		write_ptr = 0;
		fifo_out = 0;
	 end              
	 
	 assign fifo_empty = (counter == 0);    		//标志位赋值 
    assign fifo_full = (counter == DEPTH-1);
    
	 always@(posedge clock)    						// 时钟同步驱动
        if(reset)   										// Reset 重置FIFO
            begin
                read_ptr = 0; 
                write_ptr = 0;
                counter = 0;
                fifo_out = 0;                    
            end
        else
            case({read,write})  // 相应读写开关
            2'b00:;  //没有读写指令     
            2'b01:  //写指令，数据输入FIFO                           
            begin
					 if (counter < DEPTH - 1)	// 判断是否可写
						 begin
						 ram[write_ptr] = fifo_in;
						 counter = counter + 1;
						 write_ptr = (write_ptr == DEPTH-1)?0:write_ptr + 1;
						 end
            end
            2'b10: //读指令，数据读出FIFO
            begin
					 if (counter > 0)	// 判断是否可读
						 begin
						 fifo_out = ram[read_ptr];
						 counter = counter - 1;
						 read_ptr = (read_ptr == DEPTH-1)?0:read_ptr + 1;
						 end
						 
            end
            2'b11: //读写指令同时，数据可以直接输出
            begin
                if(counter == 0)
                    fifo_out = fifo_in;	// 直接输出
                else
                begin
                    ram[write_ptr]=fifo_in;
                    fifo_out=ram[read_ptr];
                    write_ptr=(write_ptr==DEPTH-1)?0:write_ptr+1;
                    read_ptr=(read_ptr==DEPTH-1)?0:write_ptr+1;
                end
            end
        endcase
        
endmodule

//module debouncing(
//BJ_CLK,         //采集时钟，40Hz
//RESET,          //系统复位信号低电平有效
//BUTTON_IN,      //按键输入信号
//BUTTON_OUT      //消抖后的输出信号
//);
//
//    input BJ_CLK;
//    input RESET;
//    input BUTTON_IN;
//    
//    output BUTTON_OUT;
//
//    reg BUTTON_IN_Q, BUTTON_IN_2Q, BUTTON_IN_3Q;
//    always @(posedge BJ_CLK or negedge RESET)
//    begin
//        if(~RESET)
//            begin
//            BUTTON_IN_Q <= 1'b1;
//            BUTTON_IN_2Q <= 1'b1;
//            BUTTON_IN_3Q <= 1'b1;
//            end
//        else
//            begin   
//            BUTTON_IN_Q <= BUTTON_IN;
//            BUTTON_IN_2Q <= BUTTON_IN_Q;
//            BUTTON_IN_3Q <= BUTTON_IN_2Q;
//            end
//    end
//
//    wire BUTTON_OUT = BUTTON_IN_2Q | BUTTON_IN_3Q;
//
//endmodule
