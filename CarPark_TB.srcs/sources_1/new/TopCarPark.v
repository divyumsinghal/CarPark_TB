module TopCarPark #(
    parameter WIDTH = 4
)(
    input  wire clk,
    input  wire reset,
    input  wire a,          // sensor a
    input  wire b,          // sensor b
    output wire enter,      // enter for fsm
    output wire exit,       // xer for fsm
    output wire [WIDTH-1:0] leds  // occupancy displayed on 4 LEDs (0..15)
);

    wire [WIDTH-1:0] count_value;

    // Instantiate FSM
    FsmCarPark fsmCarPark (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .ENTER(enter),
        .EXIT(exit)
    );

    // Instantiate counter
    CounterCarPark #(.WIDTH(WIDTH)) counterCarPark (
        .clk(clk),
        .reset(reset),
        .inc(enter),
        .dec(exit),
        .count(count_value)
    );
    
    assign leds = count_value;

endmodule
