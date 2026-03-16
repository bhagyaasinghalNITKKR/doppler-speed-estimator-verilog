module tb_missile_detector();

reg clk , rst;
reg signed [7:0]adc_sample;
wire [31:0]freq;
wire [31:0]speed;
wire [1:0]direction;
wire warning , alert;

integer i;
reg step;

missile_detector dut(.clk(clk) , .rst(rst) , .adc_sample(adc_sample) , .freq(freq) , .speed(speed) , .direction(direction) , .warning(warning) , .alert(alert));

initial
    begin
        {clk , rst , adc_sample , step} = 0;
    end
    
            always #10 clk = ~clk;
    
   initial 
        begin
            rst = 1;
            #100;
            rst = 0;
            
        
            
            for(i = 0 ; i < 50000 ; i = i + 1) // here if i take more cycles then no. of zeros wouldnt increase?
            begin                                 // No bcz we are observing adc sample for a fixed window    
                adc_sample = 50 * $sin(6.28 * i / 300);   
                #20;
            end
            #100;
            $display("time=%0t freq=%0d speed=%0d direction=%b alert=%b warning=%b",$time, freq, speed, direction , alert , warning);
            

            
            for(i = 0 ; i < 50000 ; i = i + 1) // here if i take more cycles then no. of zeros wouldnt increase?
            begin                                 // No bcz we are observing adc sample for a fixed window    
                adc_sample = 50 * $sin(6.28 * i / 250);   
                #20;
            end
            #100;
            $display("time=%0t freq=%0d speed=%0d direction=%b alert=%b warning=%b",$time, freq, speed, direction , alert , warning);
            
            
            
            for(i = 0 ; i < 50000 ; i = i + 1) // here if i take more cycles then no. of zeros wouldnt increase?
            begin                                 // No bcz we are observing adc sample for a fixed window    
                adc_sample = 50 * $sin(6.28 * i / 200);   
                #20;
            end
            #100;
            $display("time=%0t freq=%0d speed=%0d direction=%b alert=%b warning=%b",$time, freq, speed, direction , alert , warning);
        end
endmodule