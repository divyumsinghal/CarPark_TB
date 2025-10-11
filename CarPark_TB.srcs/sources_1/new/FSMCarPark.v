module FsmCarPark (
    input  wire clk,    // Clock signal
    input  wire rst,    // Synchronous active hight reset signal
    input  wire a,      // Input bit a to compare against the pattern
    input  wire b,      // Input bit b to compare against the pattern
    output reg  ENTER,  // Output signal indicating if Car has Entered
    output reg  EXIT    // Output signal indicating if Car has Exited
);
    // State encoding (using 4 bits for 9 states)
    localparam S        = 4'd0; // Base Start State
    localparam SA       = 4'd1;
    localparam SB       = 4'd2;
    localparam SC       = 4'd3;
    localparam SENTER   = 4'd4; // enter registered, same as S
    localparam TA       = 4'd5;
    localparam TB       = 4'd6;
    localparam TC       = 4'd7;
    localparam TEXIT    = 4'd8; // enter EXIT, same as S

    reg [3:0] current_state, next_state;

    // Sequential logic - state register
    always @(posedge clk) begin
        if (rst) begin
            current_state <= S;
        end
        else begin
            current_state <= next_state;
        end
    end

    // Combinational logic - next state logic
    always @(*) begin
        case (current_state)

            S, SENTER, TEXIT: begin
                case ({a, b})
                    2'b01:   next_state = SA;
                    2'b10:   next_state = TA;
                    default: next_state = S;
                endcase
            end

            SA: begin
                case ({a, b})
                    2'b01:   next_state = SA;
                    2'b11:   next_state = SB;
                    default: next_state = S;
                endcase
            end

            SB: begin
                case ({a, b})
                    2'b11:   next_state = SB;
                    2'b10:   next_state = SC;
                    default: next_state = S;
                endcase
            end

            SC: begin
                case ({a, b})
                    2'b10:   next_state = SC;
                    2'b00:   next_state = SENTER;
                    default: next_state = S;
                endcase
            end

            TA: begin
                case ({a, b})
                    2'b10:   next_state = TA;
                    2'b11:   next_state = TB;
                    default: next_state = S;
                endcase
            end

            TB: begin
                case ({a, b})
                    2'b11:   next_state = TB;
                    2'b01:   next_state = TC;
                    default: next_state = S;
                endcase
            end

            TC: begin
                case ({a, b})
                    2'b01:   next_state = TC;
                    2'b00:   next_state = SEXIT;
                    default: next_state = S;
                endcase
            end

            default: next_state = S;

        endcase
    end

    // Output logic (Moore - depends only on current state)
    always @(*) begin
        ENTER = (current_state == SENTER);
        EXIT  = (current_state == TEXIT);
    end

endmodule