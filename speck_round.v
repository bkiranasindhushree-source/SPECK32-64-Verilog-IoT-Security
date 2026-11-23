// One SPECK32/64 encryption round (combinational)
module speck_round (
    input  wire [15:0] Lin,
    input  wire [15:0] Rin,
    input  wire [15:0] rk,
    output wire [15:0] Lout,
    output wire [15:0] Rout
);
    wire [15:0] rot_L = {Lin[6:0], Lin[15:7]};    // ROR 7
    wire [15:0] rot_R = {Rin[13:0], Rin[15:14]};  // ROL 2
    assign Lout = (rot_L + Rin) ^ rk;
    assign Rout = rot_R ^ Lout;
endmodule
