`timescale 1ns/1ns
`include "sonar.v"

module sonar_tb();
	reg send_trig;
	reg echo ;
	reg clk = 0 ;
	wire trig;
	wire idle;
	wire [15:0]count_echo;
	
	sonar UUT (send_trig,echo,clk,trig,idle,count_echo);
	
	//clock with 10ns timeperiod
	always
		begin
			#5; 
			clk = ~clk; //100MHz frequency clock 1
		end
		
	//verifies the design with two different scenarios in which time taken for the echo is different 	
	initial
	begin
	assign send_trig = 0;
	#1000;
	assign echo = 1;
	assign send_trig = 1;
	#10000;//time for the sensor to send trigger
	#1000;//time taken for the echo to reach 
	assign echo = 0;
	
	
	
	assign send_trig = 0;
	#1000;
	assign echo = 1;
	assign send_trig = 1;
	#10000;//time for the sensor to send trigger
	#2000;//time taken for the echo to reach 
	assign echo = 0;
	
	//after this since the send_trig is high it keeps sending the triggering pulses
	
	end
endmodule