// SPECK32/64 key schedule: one 16-bit round key per step.
// load: capture the 64-bit key (k0 = key[15:0], l0..l2 = key[31:16], [47:32], [63:48]).
// step: output round_key (= k_i) is consumed this cycle; state advances to k_(i+1).
module speck_key_expansion (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        load,
    input  wire        step,
    input  wire [63:0] key_in,
    output wire [15:0] round_key
);
    reg [15:0] l0, l1, l2, k;
    reg [4:0]  cnt;
    reg [15:0] new_l;                      // temporary (blocking) for l_(i+3)

    assign round_key = k;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            l0 <= 16'd0; l1 <= 16'd0; l2 <= 16'd0; k <= 16'd0; cnt <= 5'd0;
        end else if (load) begin
            k   <= key_in[15:0];
            l0  <= key_in[31:16];
            l1  <= key_in[47:32];
            l2  <= key_in[63:48];
            cnt <= 5'd0;
        end else if (step) begin
            new_l = ({l0[6:0], l0[15:7]} + k) ^ {11'd0, cnt};  // (ROR(l_i,7)+k_i) ^ i
            l0  <= l1;
            l1  <= l2;
            l2  <= new_l;
            k   <= {k[13:0], k[15:14]} ^ new_l;                // ROL(k_i,2) ^ l_(i+3)
            cnt <= cnt + 5'd1;
        end
    end
endmodule
