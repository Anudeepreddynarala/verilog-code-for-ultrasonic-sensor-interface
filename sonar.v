// Clock frequency 100MHz is assumed 
// Time required for the triggering signal to be on is 10us.
// echo is high until the ECHO reaches the sensor 

module sonar(input send_trig,echo,clk, output reg trig, idle, output reg [15:0]count_echo);
	parameter trig_pd = 1000;//1000 clock cycles at 100MHz
	parameter s_idle      = 2'b00;
	parameter s_trigger   = 2'b01;
	parameter s_wait_echo = 2'b10;

wire w_send_trig;
wire w_echo;

reg r_trig;
reg r_idle;
reg [15:0]r_count_echo;
reg [15:0]r_count_echo_reg;
reg [1:0]r_sm_main = 0;
reg [7:0]r_cm;
reg [9:0]count;

assign w_send_trig      = send_trig;
assign w_echo           = echo;




always @(posedge clk)
	begin
		
		assign trig             = r_trig;
		assign idle             = r_idle;
		assign count_echo       = r_count_echo;
		
//idle state in which all the processes are stopped
//and all the values are reset to 0 when send_trig input is low.	
//procedes to triggering state when send_trig is high.
		case(r_sm_main)
			s_idle:							
			begin							
			if(w_send_trig==0)				
				begin
					r_cm             <= 0;
					r_trig           <= 0;
					count            <= 0;
					r_idle           <= 1;//high only in idle state
					r_count_echo_reg <= 0;
					r_sm_main        <= s_idle;
				end
			else
				begin
					r_sm_main <= s_trigger;
				end
			end
			
		
//sets the trig pin high for 10us and then moves on to the s_wait_echo state		
			s_trigger:							
			begin								
			r_trig <= 1;
			r_idle <= 0;
			if(count<trig_pd)
				begin
					count     <= count + 1;
					r_sm_main <= s_trigger;
				end
			else
				begin
					count <= 0;
					r_trig <= 0;
					r_sm_main <= s_wait_echo;
				end
			end
			
			
//waits for the ECHO to recieve the sensor, till then echo pin is set high in the sensor.
//state changes to s_idle when echo is clear.			
			s_wait_echo:							
			begin									
				if(w_echo == 1)						
					begin
						r_count_echo_reg <= r_count_echo_reg + 1;
						r_sm_main        <= s_wait_echo;
					end
				else
					begin
						r_count_echo     <= r_count_echo_reg;
						r_sm_main        <= s_idle;
					end
			end
			
			
			default:
			begin
				r_sm_main <= s_idle;
			end			
		endcase
	end	
endmodule	 