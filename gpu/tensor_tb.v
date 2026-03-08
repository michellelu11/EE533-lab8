`timescale 1ns/1ps

module tensor_tb;

reg tensor_en;
reg [1:0] tensor_op;

reg [63:0] a;
reg [63:0] b;
reg [63:0] c;

wire [63:0] tensor_out;

// Instantiate DUT
tensor uut(
    .tensor_en(tensor_en),
    .tensor_op(tensor_op),
    .a(a),
    .b(b),
    .c(c),
    .tensor_out(tensor_out)
);

// operation constants
localparam TS_MUL  = 2'b00;
localparam TS_FMA  = 2'b01;
localparam TS_RELU = 2'b10;

initial begin

    $display("===== Tensor Unit Test Start =====");

    tensor_en = 0;
    tensor_op = 0;
    a = 0;
    b = 0;
    c = 0;

    #10;

    // =================================================
    // Test 1 : MUL
    // =================================================
    tensor_en = 1;
    tensor_op = TS_MUL;

    a = {16'h4080,16'h4040,16'h4000,16'h3F80}; //4.0 3.0 2.0 1.0
    b = {16'h4080,16'h4040,16'h4000,16'h3F80};

    #10;

    $display("MUL Test");
    $display("a = %h", a);
    $display("b = %h", b);
    $display("out = %h", tensor_out);
    $display("--------------------------");

    // =================================================
    // Test 2 : FMA
    // =================================================
    tensor_op = TS_FMA;

    a = {16'h4080,16'h4040,16'h4000,16'h3F80}; // 4 3 2 1
    b = {16'h4000,16'h4000,16'h4000,16'h4000}; // 2 2 2 2
    c = {16'h3F80,16'h3F80,16'h3F80,16'h3F80}; // 1 1 1 1

    #10;

    $display("FMA Test (a*b + c)");
    $display("a = %h", a);
    $display("b = %h", b);
    $display("c = %h", c);
    $display("out = %h", tensor_out);
    $display("--------------------------");

    // =================================================
    // Test 3 : RELU
    // =================================================
    tensor_op = TS_RELU;

    // negative numbers (sign bit = 1)
    a = {16'h8001,16'd5,16'h8002,16'd3};

    #10;

    $display("RELU Test");
    $display("a = %h", a);
    $display("out = %h", tensor_out);
    $display("--------------------------");

    // =================================================
    // Test 4 : tensor_en off
    // =================================================
    tensor_en = 0;

    #10;

    $display("Tensor disabled");
    $display("out = %h", tensor_out);

    $display("===== Tensor Unit Test End =====");

    #20;
    $finish;

end

endmodule
