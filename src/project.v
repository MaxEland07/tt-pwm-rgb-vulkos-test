/*
 * PWM colour mixer: three PWM channels drive the red, green and blue of one LED.
 *
 *   ui_in[1:0]  red level,   0 to 3
 *   ui_in[3:2]  green level, 0 to 3
 *   ui_in[5:4]  blue level,  0 to 3
 *
 *   uo_out[0]   red PWM
 *   uo_out[1]   green PWM
 *   uo_out[2]   blue PWM
 *
 * One PWM period is three clock ticks. A colour's level is the number of those
 * three ticks its output is on for: 0 is off, and 3 is on all the time.
 */

`default_nettype none

module tt_um_maxeland07_pwm_rgb (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // The level for each colour, from its two switches: 0, 1, 2 or 3.
    wire [1:0] red_level   = ui_in[1:0];
    wire [1:0] green_level = ui_in[3:2];
    wire [1:0] blue_level  = ui_in[5:4];

    // One counter, shared by all three channels. It counts 0, 1, 2 and round
    // again, so one PWM period is three clock ticks.
    reg [1:0] counter;
    always @(posedge clk) begin
        
        if (!rst_n)               counter <= 2'd0;
        else if (counter == 2'd2) counter <= 2'd0;
        else                      counter <= counter + 2'd1;
    end

    // Each output is high while the counter is below its level.
    wire red   = (counter < red_level);
    wire green = (counter < green_level);
    wire blue  = (counter < blue_level);

    assign uo_out  = {5'b0, blue, green, red};
    assign uio_out = 8'h00;
    assign uio_oe  = 8'h00;

    wire _unused_ok = &{ena, ui_in[7:6], uio_in};

endmodule
