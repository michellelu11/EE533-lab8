module gpu(
    input clk, rst,
    input [31:0] tid_value // thread ID input for OP_TID instruction
);

    // 1. IF stage
    wire [31:0] if_inst;
    wire [31:0] if_pc;
    wire [31:0] if_tid_value; // for OP_TID instruction

    assign if_tid_value = tid_value; // Pass thread ID to IF stage for OP_TID instruction

    // 2. IF/ID
    reg [31:0] id_inst;
    reg [31:0] id_pc;
    reg [31:0] id_tid_value; // for OP_TID instruction
    wire [5:0]  id_opcode;
    wire [3:0]  id_rd;
    wire [3:0]  id_rs1_addr;
    wire [3:0]  id_rs2_addr;
    wire [3:0]  id_rs3_addr;
    wire [5:0]  id_func;
    wire [3:0]  id_imm;

    // Control outputs
    wire       id_alu_en;
    wire [2:0] id_alu_op;
    wire       id_tensor_en;
    wire [1:0] id_tensor_op;
    wire       id_mem_read;
    wire       id_mem_write;
    wire       id_branch_valid;
    wire [2:0] id_branch_type;
    wire       id_reg_write_en;
    wire [2:0] id_wb_sel;
    wire       id_stop;  
    wire id_use_imm;   
    wire [31:0] id_imm_out; 

    // Register file outputs
    wire [63:0] id_rs1_data;
    wire [63:0] id_rs2_data;
    wire [63:0] id_rs3_data;


    //ID/EX pipeline register
    reg [63:0] ex_rs1_data;
    reg [63:0] ex_rs2_data;
    reg [63:0] ex_rs3_data;
    reg [3:0]  ex_rd;
    reg [31:0] ex_imm_out;
    reg [31:0] ex_pc;
    reg ex_alu_en;
    reg [2:0]  ex_alu_op;
    reg        ex_tensor_en;
    reg [1:0]  ex_tensor_op;
    reg        ex_mem_read;
    reg        ex_mem_write;
    reg        ex_reg_write_en;
    reg [2:0]  ex_wb_sel;
    reg        ex_branch_valid;
    reg [2:0]  ex_branch_type;
    reg ex_use_imm;
    reg [31:0] ex_tid_value;

    wire [63:0] alu_src_b = ex_use_imm ? {{32{ex_imm_out[31]}}, ex_imm_out} : ex_rs2_data;

    // ALU
    wire [63:0] ex_alu_result;
    wire ex_branch_taken;
    wire [31:0] ex_branch_target;
    //Tensor
    wire [63:0] ex_tensor_out;

    // 6. EX/MEM pipeline register
    reg [63:0] mem_alu_result;
    reg [63:0] mem_tensor_out;
    reg [3:0] mem_rd;       // for writeback register address
    reg [63:0] mem_rs2_data; // for store instruction's write data
    reg [31:0] mem_imm_out;      // for store instruction's immediate offset
    reg        mem_mem_read;
    reg        mem_mem_write;
    reg        mem_reg_write_en;
    reg [2:0]  mem_wb_sel;
    reg [31:0] mem_tid_value;
    reg       mem_branch_taken;
    reg [31:0] mem_branch_target;

    // 7. MEM stage: Data Memory
    wire [63:0] mem_read_data;


    // 8. MEM/WB pipeline register
    reg        wb_reg_write_en;
    reg [63:0] wb_alu_result;
    reg [63:0] wb_tensor_out;
    reg [63:0] wb_read_data;
    reg [31:0] wb_imm_out;
    reg [2:0]  wb_wb_sel;
    reg [31:0] wb_tid_value;

    // WB stage write-back signals (from later)
    reg  [3:0]  wb_rd;
    reg [63:0] wb_data;


    PC u_pc (  
        .clk          (clk),
        .rst          (rst),
        .stop         (id_stop),
        .branch_valid (mem_branch_taken), 
        .branch_target(mem_branch_target),
        .pc_out       (if_pc)
    );

    i_mem u_imem (
        .clk        (clk),
        .pc         (if_pc),
        .instruction(if_inst)
    );


    assign id_opcode  = id_inst[31:26];
    assign id_rd      = id_inst[25:22];
    assign id_rs1_addr = id_inst[21:18];
    assign id_rs2_addr = id_inst[17:14];
    assign id_rs3_addr = id_inst[13:10];
    assign id_func    = id_inst[9:4];
    assign id_imm     = id_inst[3:0];  

    always @(posedge clk) begin
    if (rst) begin
        id_inst <= 32'd0;
        id_pc    <= 32'd0;
        id_tid_value <= 32'd0;
    end else begin
        id_inst <= if_inst;
        id_pc    <= if_pc;
        id_tid_value <= if_tid_value;
    end
    end



    control u_control ( 
        .opcode       (id_opcode),
        .func         (id_func),

        .alu_en       (id_alu_en),
        .alu_op       (id_alu_op),
        .tensor_en    (id_tensor_en),
        .tensor_op    (id_tensor_op),
        .mem_read     (id_mem_read),
        .mem_write    (id_mem_write),
        .branch_valid (id_branch_valid),
        .branch_type  (id_branch_type),
        .reg_write_en (id_reg_write_en),
        .wb_sel       (id_wb_sel),
        .use_imm      (id_use_imm),
        .stop         (id_stop)
    );





    reg_file u_reg_file ( 
        .clk       (clk),
        .rst       (rst),
        .write_en  (wb_reg_write_en),
        .rd        (wb_rd),
        .rd_data   (wb_data),
        .rs1_addr  (id_rs1_addr),
        .rs2_addr  (id_rs2_addr),
        .rs3_addr  (id_rs3_addr),

        .rs1_data  (id_rs1_data),
        .rs2_data  (id_rs2_data),
        .rs3_data  (id_rs3_data)
    );

    imm u_imm_gen ( 
        .instr   (id_inst),
        .opcode  (id_opcode),
        .imm_out (id_imm_out)
    );

    always @(posedge clk) begin
        if (rst) begin
            // Clear all outputs on reset or flush
            ex_alu_en <= 0;
            ex_alu_op <= 3'b0;
            ex_tensor_en <= 0;
            ex_tensor_op <= 2'b0;
            ex_mem_read <= 0;
            ex_mem_write <= 0;
            ex_branch_valid <= 0;
            ex_branch_type <= 3'b0;
            ex_wb_sel <= 3'b0;

            ex_rs1_data <= 64'd0;
            ex_rs2_data <= 64'd0;
            ex_rs3_data <= 64'd0;
            ex_rd <= 4'b0;
            ex_reg_write_en <= 0;
            ex_imm_out <= 32'd0;
            ex_pc <= 32'd0;
            ex_use_imm <= 0;
            ex_tid_value <= 32'd0;
        end else begin
            // Normal operation: pass values from ID to EX
            ex_alu_en <= id_alu_en;
            ex_alu_op <= id_alu_op;
            ex_tensor_en <= id_tensor_en;
            ex_tensor_op <= id_tensor_op;
            ex_mem_read <= id_mem_read;
            ex_mem_write <= id_mem_write;    
            ex_branch_valid <= id_branch_valid;
            ex_branch_type <= id_branch_type;
            ex_wb_sel <= id_wb_sel;

            ex_rs1_data <= id_rs1_data;
            ex_rs2_data <= id_rs2_data;
            ex_rs3_data <= id_rs3_data;
            ex_rd <= id_rd;
            ex_reg_write_en <= id_reg_write_en;
            ex_imm_out <= id_imm_out;
            ex_pc <= id_pc;
            ex_use_imm <= id_use_imm;
            ex_tid_value <= id_tid_value;
        end
    end

    ALU alu(
        .alu_en(ex_alu_en),
        .a     (ex_rs1_data),
        .b     (alu_src_b),
        .alu_op(ex_alu_op),
        .alu_out(ex_alu_result)
    );

    branch BRANCH(
        .branch_valid (ex_branch_valid),
        .branch_type  (ex_branch_type),
        .rs1_data     (ex_rs1_data),
        .rs2_data     (ex_rs2_data), //need to use register value for branch comparison, not immediate
        .pc           (ex_pc),
        .imm          (ex_imm_out), // immediate for branch offset
        .branch_taken (ex_branch_taken), 
        .branch_target(ex_branch_target)
    );

    tensor u_tensor (
        .tensor_en (ex_tensor_en),
        .tensor_op (ex_tensor_op),
        .a         (ex_rs1_data),
        .b         (ex_rs2_data),
        .c         (ex_rs3_data),
        .tensor_out(ex_tensor_out)
    );



   always @(posedge clk) begin
    if (rst) begin
        mem_alu_result <= 64'd0;
        mem_tensor_out <= 64'd0;
        mem_rd <= 4'b0;
        mem_rs2_data <= 64'd0;
        //mem_imm_out <= 32'd0;
        mem_mem_read <= 0;
        mem_mem_write <= 0;
        mem_reg_write_en <= 0;
        mem_wb_sel <= 3'b0;
        mem_tid_value <= 32'd0;
        mem_branch_taken <= 0;
        mem_branch_target <= 32'd0;
    end else begin
        mem_alu_result <= ex_alu_result;
        mem_tensor_out <= ex_tensor_out;
        mem_rd <= ex_rd;
        mem_rs2_data <= ex_rs2_data;
        //mem_imm_out <= ex_imm_out;
        mem_mem_read <= ex_mem_read;
        mem_mem_write <= ex_mem_write;
        mem_reg_write_en <= ex_reg_write_en;
        mem_wb_sel <= ex_wb_sel;
        mem_tid_value <= ex_tid_value;
        mem_branch_taken <= ex_branch_taken;
        mem_branch_target <= ex_branch_target;
    end
   end


    dmem u_dmem (
        .clk        (clk),
        .mem_read   (mem_mem_read),
        .mem_write  (mem_mem_write),
        .addr       (mem_alu_result[7:0]), 
        .write_data (mem_rs2_data),
        .read_data  (mem_read_data)
    );



    always @(posedge clk) begin
    if (rst) begin
        wb_alu_result     <= 64'd0;
        wb_tensor_out     <= 64'd0;
        wb_read_data      <= 64'd0;
        //wb_imm_out        <= 32'd0;
        wb_rd             <= 4'b0;
        wb_reg_write_en   <= 1'b0;
        wb_wb_sel         <= 3'b0;
        wb_tid_value      <= 32'd0;
    end
    else begin
        wb_alu_result     <= mem_alu_result;
        wb_tensor_out     <= mem_tensor_out;
        wb_read_data      <= mem_read_data;
        //wb_imm_out        <= mem_imm_out;
        wb_rd             <= mem_rd;
        wb_reg_write_en   <= mem_reg_write_en;
        wb_wb_sel         <= mem_wb_sel;
        wb_tid_value      <= mem_tid_value;
    end
end



always @(*) begin
    case (wb_wb_sel)
        3'b000: wb_data = wb_alu_result;
        3'b001: wb_data = wb_tensor_out;
        3'b010: wb_data = wb_read_data;
        //3'b011: wb_data = wb_imm_out;
        3'b011: wb_data = {{32{1'b0}}, wb_tid_value};
        default: wb_data = 64'd0;
    endcase
end


endmodule
