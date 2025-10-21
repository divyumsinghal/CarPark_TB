module StimGen #(
    parameter WIDTH = 4,
    parameter CLK_PERIOD = 10,     // Clock period in ns
    parameter SEED       = 32'h42
)(
    output reg clk,
    output reg reset,
    output reg a,
    output reg b,
    output reg exp_enter,
    output reg exp_exit,
    output reg [WIDTH-1:0] exp_led
);
    // needed temp vars
    localparam MAX = (1<<WIDTH)-1;
    localparam MIN_DELAY = 2 * CLK_PERIOD;         // minimum sensor duration in ns
    localparam MAX_DELAY = 4 * CLK_PERIOD;     // maximum sensor duration in ns
    integer i;
    reg [31:0] rand_val;

    // Clock generation (period = 10ns)
    initial begin
        clk = 0;
        exp_led = 0;
        a = 0; b = 0;
        exp_enter = 0; exp_exit = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Main stimulus process
    initial begin
        reset = 1; a = 0; b = 0;
        exp_enter = 0; exp_exit = 0;
        #(2 * CLK_PERIOD);
         reset = 0;

        // Run different test scenarios
        multiple_cars_enters();
        #(2 * CLK_PERIOD);
        
        multiple_cars_exits();
        #(2 * CLK_PERIOD);
        
        multiple_cars();
        #(2 * CLK_PERIOD);
        
        $display("Stimulus generation complete");
        $finish;
    end
    
    // multiple cars entering and  exiting
    task multiple_cars;
        begin
            $display("[%0t] TEST START", $time);
            
            for (i = 0; i < 50; i = i + 1) begin
                rand_val = $urandom(SEED + $time + i);
                #(CLK_PERIOD * (2 + (rand_val[3:0])));  // random gap between cars
                
                if (rand_val[rand_val % 32] == 0) // 50 % chance
                    car_enters();
                else if (rand_val[(rand_val + $time + i) % 32] == 0) // 25 % chance
                    car_exits();
                else  // 25 % chance
                    bad_case();
            end
            
            $display("[%0t] TEST END", $time);
        end
    endtask

    
    
     // multiple cars entering
    task multiple_cars_enters;
       begin
            $display("[%0t] TEST START", $time);
            repeat (50) begin
                #(CLK_PERIOD * (2 + rand_val[3:0]));  // random gap between cars
                car_enters();
            end
            $display("[%0t] TEST PLAN END", $time);

        end
    endtask
    
    // multiple cars exiting
    task multiple_cars_exits;
       begin
            $display("[%0t] TEST START", $time);
            repeat (50) begin
                #(CLK_PERIOD * (2 + rand_val[3:0]));  // random gap between cars
                car_exits();
            end
            $display("[%0t] TEST PLAN END", $time);

        end
    endtask

    // TASKS FOR TEST SEQUENCES

    // Car entering sequence
    task car_enters;
        begin
            $display("[%0t] TEST: Car Entry Sequence", $time);
            exp_enter = 0; exp_exit = 0;
            
            sensor_pattern(2'b00);
            sensor_pattern(2'b10);
            sensor_pattern(2'b11);
            sensor_pattern(2'b01);
            sensor_pattern(2'b00);

            #(CLK_PERIOD);        
            exp_enter = 1;  // expected enter pulse
            #(CLK_PERIOD);
            exp_led = (exp_led < MAX)? exp_led + 1 : exp_led;
            exp_enter = 0;
        end
    endtask

    // Car exiting sequence
    task car_exits;
        begin
            $display("Running car exit sequence...");
            exp_enter = 0; exp_exit = 0;
            
            sensor_pattern(2'b00);
            sensor_pattern(2'b01);
            sensor_pattern(2'b11);
            sensor_pattern(2'b10);
            sensor_pattern(2'b00);
                              
            #(CLK_PERIOD);
            exp_exit = 1;  // expected exit pulse
            #(CLK_PERIOD);
            exp_led = (exp_led > 0)? exp_led - 1 : exp_led;
            exp_exit = 0;
        end
    endtask
    
    // Edge case that woulod not change anything generates a series of random impulses
    task bad_case;
        begin
            $display("[%0t] TEST: Edge Sequence", $time);   
            
            rand_val = $urandom(SEED + $time);
            if (rand_val[rand_val % 32] == 0)
                sensor_pattern(2'b00);
            
            rand_val = $urandom(SEED + $time);
            if (rand_val[rand_val % 32] == 0)    
                sensor_pattern(2'b11);
                
            rand_val = $urandom(SEED + $time);
            if (rand_val[rand_val % 32] == 0)
                sensor_pattern(2'b10);
            
            rand_val = $urandom(SEED + $time);
            if (rand_val[rand_val % 32] == 0)
                sensor_pattern(2'b01);
                
            rand_val = $urandom(SEED + $time);
            if (rand_val[rand_val % 32] == 0)    
                sensor_pattern(2'b11);
            
            rand_val = $urandom(SEED + $time);
            if (rand_val[rand_val % 32] == 0)
                sensor_pattern(2'b01);
                
            rand_val = $urandom(SEED + $time);
            if (rand_val[rand_val % 32] == 0)
                sensor_pattern(2'b10);

            #(CLK_PERIOD);
        end
    endtask
    
    // sets the sensors to a set input for a random while
    task sensor_pattern(input [1:0] ab_state);
        integer delay_ns;
        begin
            delay_ns = MIN_DELAY + ($urandom(SEED + $time) % (MAX_DELAY - MIN_DELAY));
            $display("delay ns: ", delay_ns);
            #(delay_ns);
            {a, b} = ab_state;
        end
    endtask
    
endmodule
