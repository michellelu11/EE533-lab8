`timescale 1ns / 1ps

module gpu_tb();

    // ==========================================
    // 1. ????
    // ==========================================
    reg clk;
    reg rst;
    reg [31:0] tid_value;

    // ==========================================
    // 2. ??? GPU (Device Under Test)
    // ==========================================
    // ?? ???????? port ???? gpu.v ?????
    gpu uut (
        .clk(clk),
        .rst(rst),
        .tid_value(tid_value)
    );

    // ==========================================
    // 3. ?? Clock (?? = 10ns)
    // ==========================================
    always #5 clk = ~clk;

    // ==========================================
    // 4. ???????
    // ==========================================
    initial begin
        // ????????? GTKWave ? ModelSim ??
        $dumpfile("gpu_wave_v2.vcd"); 
        $dumpvars(0, gpu_tb);
        $dumpvars(0, uut);

        $display("==================================================");
        $display("(Simulation Started)");
        $display("==================================================");

        // ?????
        clk = 0;
        rst = 1;             // ?? Reset
        tid_value = 32'd7;   // ?? Thread ID = 7

        // ?? 15ns ??? Reset?? PC ????
        #15;
        rst = 0; 

        // ? GPU ?????? (??? 300ns???? 30 ? Clock)
        // ??????????????????? (?? #1000)
        #1000;

        $display("\n==================================================");
        $display("Simulation Finished)");
        $display("==================================================");

        // ==========================================
        // ?? ?? Debug ?????????????
        // ==========================================
        // ?? ??????????
        // ???? gpu.v ???? register_file ????? "rf_inst"
        // ??????????? "registers" (???????????)
        // ????? uut.rf_inst ???????????
        
        $display("--- ?? Register File (????? Load?) ---");
        // ?? %rd1, %rd2, %rd3 (?? index 1, 2, 3???? ISA ????)
        $display("Reg[1] (suppopsed to be 10) = %d", uut.u_reg_file.regs[1]);
        $display("Reg[2] (supposed to be  4)  = %d", uut.u_reg_file.regs[2]);
        $display("Reg[3] (suppesed to be 6)  = %d", uut.u_reg_file.regs[3]);
        $display("Reg[0] = %d", uut.u_reg_file.regs[0]);

       
        
        // ????? mov.u32 %r1, %tid.x; 
        // ?? %r1 ????????? index 11 (?????????)??????? Thread ID ?????
        // $display("Reg[11] (?? Thread ID ? 7) = %d", uut.rf_inst.registers[11]);

        // ==========================================
        // ?? ?? Data Memory ?????? (Store ????)
        // ==========================================
        // ???? gpu.v ???? dmem ????? "dmem_inst"
        // ??????????? "mem"
        /*$display("\n--- ?? Data Memory ---");
        $display("Mem[0]  = %d", uut.u_dmem.mem[0]);
        $display("Mem[1]  = %d", uut.u_dmem.mem[1]);
        $display("Mem[2]  = %d", uut.u_dmem.mem[2]);
        $display("Mem[10] = %d", uut.u_dmem.mem[10]);
        $display("Mem[11] = %d", uut.u_dmem.mem[11]);*/

        $display("==================================================");

	// ==========================================
    // ?? ??????????
    // ==========================================
    
        $finish; // ????
    end
	always @(posedge clk) begin
        if (!rst) begin
             #1;
            // ?? ???? u_reg_file ??? "????", "????", "????" ????
            $display("Time: %4t | WB_EN: %b | WB_Addr (rd): %d | WB_Data: %d", 
                     $time, 
                     uut.u_reg_file.write_en,         // Register File ? write enable ?
                     uut.u_reg_file.rd,     // Register File ? write address ?
                     uut.u_reg_file.rd_data);    // Register File ? write data ?
            $display("T=%0t PC=%h IF_INST=%b | ID_INST=%b",
      $time, uut.if_pc, uut.if_inst, uut.id_inst);
	 $display("Mem[0]=%d Mem[1]=%d Mem[2]=%d Mem[3]=%d",
  uut.u_dmem.mem[0], uut.u_dmem.mem[1], uut.u_dmem.mem[2], uut.u_dmem.mem[3]);
        end
    end

endmodule
