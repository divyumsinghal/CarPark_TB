`timescale 1ns / 1ps

module Scoreboard #(
    parameter WIDTH = 4
)(
    input  wire              clk,
    input  wire              reset,
    input  wire              dut_enter,
    input  wire              dut_exit,
    input  wire              exp_enter,
    input  wire              exp_exit,
    input  wire [WIDTH-1:0]  dut_led,
    input  wire [WIDTH-1:0]  exp_led
);

    integer logfile;

    // Open log file
    initial begin
        logfile = $fopen("results.log", "w");
        if (logfile == 0) begin
            $display("[%0t] Error: Could not open results.log", $time);
            $finish;
        end
        $fwrite(logfile, "Time\t\tCASE\tdut_enter\texp_enter\tdut_exit\texp_exit\tdut_led\texp_led\n");
    end

    // Scoreboard comparison
    always @(posedge clk) begin
        if ((dut_enter === exp_enter) &&
            (dut_exit  === exp_exit)  &&
            (dut_led   === exp_led)) begin
            $fwrite(logfile, "[%0t]\t\tPASS:\t%b\t%b\t%b\t%b\t%b\t%b\n", $time, dut_enter, exp_enter, dut_exit, exp_exit, dut_led, exp_led);
        end else begin
            $fwrite(logfile, "[%0t]\t\tFAIL:\t%b\t%b\t%b\t%b\t%b\t%b\n", $time, dut_enter, exp_enter, dut_exit, exp_exit, dut_led, exp_led);
        end
    end

endmodule