`timescale 1ns / 1ps

// Top-Level Self-Checking Testbench for Carpark FSM
module TbTopCarPark;

    localparam WIDTH = 4;

    // DUT signals
    wire clk;
    wire reset;
    wire a, b;
    wire exp_enter, exp_exit;
    wire dut_enter, dut_exit;
    wire [WIDTH -1 : 0] exp_led;
    wire [WIDTH -1 : 0] dut_led;

    // Instantiate Stimulus Generator
    StimGen #(.WIDTH(WIDTH)) stimGen (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .exp_enter(exp_enter),
        .exp_exit (exp_exit),
        .exp_led  (exp_led)
    );

    // Instantiate DUT (Carpark FSM + Counter)
    TopCarPark #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .reset (reset),
        .a     (a),
        .b     (b),
        .enter (dut_enter),
        .exit  (dut_exit),
        .leds  (dut_led)
    );


    // Instantiate Scoreboard
    Scoreboard #(.WIDTH(WIDTH)) scoreboard (
        .clk(clk),
        .reset(reset),
        .dut_enter(dut_enter),
        .dut_exit(dut_exit),
        .exp_enter(exp_enter),
        .exp_exit(exp_exit),
        .dut_led (dut_led),
        .exp_led (exp_led)
    );

endmodule


/*
module top_tb;

    localparam WIDTH = 4;
    localparam NUMCASES = 4;

    // Testbench signals
    reg clk_tb;
    reg reset_tb;
    reg a_tb;
    reg b_tb;
    wire [WIDTH - 1 : 0] leds_tb;

    // DUT instantiation
    TopCarPark #(.WIDTH(WIDTH)) uut (
        .clk   (clk_tb),
        .reset (reset_tb),
        .a     (a_tb),
        .b     (b_tb),
        .leds  (leds_tb)
    );

    // Clock generation: 10 ns period
    initial begin
        clk_tb = 0;
        forever #5 clk_tb = ~clk_tb;
    end

    // Test vector memory
    reg [WIDTH + 2 : 0] test_data [0 : NUMCASES - 1];
    reg [WIDTH - 1 : 0] leds_expected;
    integer i;

    initial begin
        $display("STARTING SIMULATION");

        // Load test vectors from file
        $readmemb("testbench.txt", test_data);

        // Initialize
        reset_tb = 1;
        a_tb = 0;
        b_tb = 0;
        #20;

        // Deassert reset
        reset_tb = 0;

        // Test loop
        for (i = 0; i < NUMCASES; i = i + 1) begin
            @(posedge clk_tb);

            // Assign inputs from test data
            a_tb          = test_data[i][0];
            b_tb          = test_data[i][1];
            reset_tb      = test_data[i][2];
            leds_expected = test_data[i][WIDTH + 2 : 3];

            // Wait one cycle for output to settle
            @(posedge clk_tb);

            // Compare
            if (leds_tb === leds_expected)
                $display("PASS: Case %0d | a=%b b=%b reset=%b | leds=%b",
                          i, a_tb, b_tb, reset_tb, leds_tb);
            else
                $display("FAIL: Case %0d | a=%b b=%b reset=%b | leds=%b (Expected %b)",
                          i, a_tb, b_tb, reset_tb, leds_tb, leds_expected);
        end

        $display("SIMULATION COMPLETE");
        $stop;
    end

endmodule
*/