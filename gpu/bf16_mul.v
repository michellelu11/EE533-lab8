module bf16_mul(
    input  [15:0] a,
    input  [15:0] b,
    output [15:0] out
);

    // BF16 fields
    wire sign_a = a[15];
    wire sign_b = b[15];

    wire [7:0] exp_a  = a[14:7];
    wire [6:0] frac_a = a[6:0];

    wire [7:0] exp_b  = b[14:7];
    wire [6:0] frac_b = b[6:0];

    // zero detect
    wire a_is_zero = (a[14:0] == 15'b0);
    wire b_is_zero = (b[14:0] == 15'b0);

    // result sign
    wire sign_out = sign_a ^ sign_b;

    // ============================
    // 1. mantissa multiply
    // ============================
    wire [7:0] mant_a = {1'b1, frac_a};
    wire [7:0] mant_b = {1'b1, frac_b};

    wire [15:0] mant_mult = mant_a * mant_b;

    // normalization
    wire norm_shift = mant_mult[15];

    wire [6:0] final_frac =
            norm_shift ? mant_mult[14:8] :
                         mant_mult[13:7];

    // ============================
    // 2. exponent calculation
    // ============================

    // exp_a + exp_b - bias
    wire [9:0] exp_sum = exp_a + exp_b - 8'd127;

    // adjust if normalization shift
    wire [9:0] exp_norm = norm_shift ? exp_sum + 1 : exp_sum;

    // overflow / underflow
    wire overflow  = (exp_norm >= 255);
    wire underflow = (exp_norm <= 0);

    wire [7:0] final_exp = exp_norm[7:0];

    // ============================
    // output
    // ============================

    assign out =
        (a_is_zero | b_is_zero | underflow) ? 16'd0 :
        overflow ? {sign_out, 8'hFF, 7'd0} :
        {sign_out, final_exp, final_frac};

endmodule