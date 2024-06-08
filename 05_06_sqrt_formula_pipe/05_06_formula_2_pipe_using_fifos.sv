// Task

module formula_2_pipe_using_fifos
(
    input         clk,rst, arg_vld,
    
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);


logic [31:0] a_out,b_out;

// fifo for the a input
fifo_template #(32,8) a_fifo(
  .clk(clk), 
  .rst(rst),
  .push(),
  .pop(),
  .write_data(a),
  .read_data(a_out),
  .empty(),
  .full());

//fifo for b input
fifo_template #(32,8) b_fifo(
  .clk(clk), 
  .rst(rst),
  .push(),
  .pop(),
  .write_data(b),
  .read_data(b_out),
  .empty(),
  .full());
//---------STAGE_1---------------------------------------------------------
//---------Stage 1 sqrt fn for a-------------------------------------------
logic cy_vld;
logic [14:0] cy;
logic [31:0] stage_1_sum, stage_1_sum_q;

isqrt #(.n_pipe_stages(1)) _isqrt1           
(                          
    .clk(clk),.rst(rst),.arg_vld(arg_vld),.x(c),.y_vld(cy_vld),.y(cy)       
   );

 assign stage_1_sum = cy + b_out;    // adding 15 and 32 bits ?????
 
 //-------------------stage 1 register--------------
 
 always_ff @(posedge clk)
     if (rst)
         stage_1_sum_q  <= '0;
     else
         stage_1_sum_q  <= stage_1_sum;

//---------STAGE 2-----------------------------------------------------------

logic [14:0] by;
logic by_vld;
logic [31:0] stage_2_sum, stage_2_sum_q;

//---------stage 2 isqrt ---------------------------------------------------
isqrt #(.n_pipe_stages(1)) _isqrt2 
(.clk(clk), .rst(rst), .arg_vld(arg_vld), .x(stage_1_sum_q),
    .y_vld(by_vld), .y(by));

assign stage_2_sum = by + a_out;

//---------stage 2 register-------------------------------------------------

 always_ff @(posedge clk)
     if (rst)
         stage_2_sum_q <= '0;
     else
         stage_2_sum_q <= stage_2_sum;


//--------STAGE 3 ----------------------------------------------------------

isqrt #(.n_pipe_stages(1)) _isqrt3
(.clk(clk), .rst(rst), .arg_vld(arg_vld), .x(stage_2_sum_q),
    .y_vld(res_vld), .y(res));






    // Task:
    // Implement a pipelined module formula_2_pipe_using_fifos that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    // The requirements:
    
    // 1. The module formula_2_pipe has to be pipelined.
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    // 3. Your solution should use FIFOs instead of shift registers
    // which were used in 04_10_formula_2_pipe.sv.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm


endmodule
