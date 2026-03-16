// freq estimator -> speed calc -> freq calc -> top_module -> tb

// Module1 freq_estimator
module freq_calc(
    input clk,
    input rst,
    input signed [7:0] adc_sample,
    output reg [31:0] freq
);

reg signed [7:0] prev_adc_sample;
reg [31:0] timer;
reg [31:0] edge_count;

parameter window = 50000;

always @(posedge clk)
begin
    if(rst)
    begin
        freq <= 0;
        edge_count <= 0;
        timer <= 0;
        prev_adc_sample <= 0;
    end
    else
    begin
        prev_adc_sample <= adc_sample;

         if((adc_sample > 0 && prev_adc_sample < 0) ||
           (adc_sample < 0 && prev_adc_sample > 0))
             edge_count <= edge_count + 1;
        
        // if(adc_sample[7] != prev_adc_sample[7] && 
        // adc_sample != 0 && prev_adc_sample != 0)
        // edge_count <= edge_count + 1;

        if(timer < window)
        begin
            timer <= timer + 1;

        end
        else
        begin
            freq <= edge_count * 500;
           
            timer <= 0;
            edge_count <= 0;
        end
    end
end

endmodule


// Module 2 Speed calc

module speed_calc(
    input clk,
    input rst,
  //  input valid_in,
    input [31:0] freq,

    output reg [31:0] speed
    //output reg valid_out
);

localparam c = 300;
localparam f = 10000;

always @(posedge clk)
begin
    if(rst)
    begin
        speed <= 0;
    end

    else
    begin
        speed <= (c * freq) / (2 * f);
    end
end

endmodule

// Module 3 Direction

module direction(
    input clk,
    input rst,
    input [31:0] speed,
    output reg [1:0] direction
    
);

reg [31:0] prev_speed;

always @(posedge clk)
begin
    if(rst)
    begin
        direction <= 0;
        prev_speed <= 0;
    
    end

    else 
    begin
        if(prev_speed > speed)
            direction <= 2'b01;   // away

        else if(prev_speed < speed)
            direction <= 2'b10;   // approaching

        prev_speed <= speed;
       
    end
    
end

endmodule

//Module 4 Decison

module missile_decision(
    input clk,
    input rst,
    //input valid_in,
    input [31:0] speed,
    input [1:0] direction,

    output reg alert,
    output reg warning
);

localparam speed_alert = 1000;
localparam speed_warning = 500;

always @(posedge clk)
begin
    if(rst)
    begin
        alert <= 0;
        warning <= 0;
    end

    else
    begin
        if((speed > speed_alert) && (direction == 2'b10))
        begin
            alert <= 1;
            warning <= 1;
        end

        else if((speed > speed_warning) &&
                (speed < speed_alert) &&
                (direction == 2'b10))
        begin
            alert <= 0;
            warning <= 1;
        end

        else
        begin
            alert <= 0;
            warning <= 0;
        end
    end
end

endmodule

// Module 5 Instantiation  

module missile_detector(
    input clk,
    input rst,
    input [7:0] adc_sample,

    output [31:0] freq,
    output [31:0] speed,
    output [1:0] direction,
    output warning,
    output alert
);

wire [31:0] freq_in;

freq_calc dut1(
    .clk(clk),
    .rst(rst),
    .adc_sample(adc_sample),
    .freq(freq_in)
);

speed_calc dut3(
    .clk(clk),
    .rst(rst),
    .freq(freq_in),
    .speed(speed)
);

direction dut4(
    .clk(clk),
    .rst(rst),
  //  .valid_in(speed_valid),
    .speed(speed),
    .direction(direction)
  //  .valid_out(dir_valid)
);

missile_decision dut5(
    .clk(clk),
    .rst(rst),
  //  .valid_in(dir_valid),
    .speed(speed),
    .direction(direction),
    .alert(alert),
    .warning(warning)
);
assign freq = freq_in;
endmodule