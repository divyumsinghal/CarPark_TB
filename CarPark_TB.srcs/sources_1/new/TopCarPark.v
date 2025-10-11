module TopCarPark #(
    parameter WIDTH = 4
)(
    input  wire clk,
    input  wire reset,
    input  wire a,  // sensor a
    input  wire b,  // sensor b
    output wire [WIDTH-1:0] leds  // occupancy displayed on 4 LEDs (0..15)
);

    // Instantiate FSM
    FsmCarPark fsmCarPark (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .enter(enter),
        .exit(exit)
    );

    // Instantiate counter
    CounterCarPark #(.WIDTH(WIDTH)) counterCarPark (
        .clk(clk),
        .reset(reset),
        .inc(enter),
        .dec(exit),
        .count(leds)
    );

endmodule
