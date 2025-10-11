module CounterCarPark #(
    parameter WIDTH = 4
)(
    input  wire clk,
    input  wire reset, // syncronos active-high reset
    input  wire inc,
    input  wire dec,
    output reg [WIDTH-1:0] count
);
    localparam MAX = (1<<WIDTH)-1;
    
    always @(posedge clk) begin
        if (reset) begin
            count <= {WIDTH{1'b0}};
        end else begin
            if (inc && !dec) begin
                if (count < MAX) count <= count + 1'b1;
                else count <= count; // stop the overflow at MAX more cars wont be registered
            end else if (dec && !inc) begin
                if (count > 0) count <= count - 1'b1;
                else count <= count; // saturate at 0 Negetive Cars shoulod not be possible (Except for Die Hard 3)
            end else begin
                count <= count; // no diff
            end
        end
    end

endmodule
