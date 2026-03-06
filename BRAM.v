`timescale 1ns / 1ps

// ???????? Port ?????? IP Core ???????
module BRAM (
    input wire clka,
    input wire ena,
    input wire [0:0] wea,
    input wire [7:0] addra,
    input wire [71:0] dina,
    output reg [71:0] douta,

    input wire clkb,
    input wire enb,
    input wire [0:0] web,
    input wire [7:0] addrb,
    input wire [71:0] dinb,
    output reg [71:0] doutb
);

    // ?????? 256??? 72 bits ??????
    reg [71:0] ram [255:0];

    // Port A (?? FIFO ???)
    always @(posedge clka) begin
        if (ena) begin
            if (wea) begin
                ram[addra] <= dina;
            end
            douta <= ram[addra];
        end
    end

    // Port B (?? FIFO ??? / ??????)
    always @(posedge clkb) begin
        if (enb) begin
            if (web) begin
                ram[addrb] <= dinb;
            end
            doutb <= ram[addrb];
        end
    end

endmodule