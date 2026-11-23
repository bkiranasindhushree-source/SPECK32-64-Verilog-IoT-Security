// SPECK32/64 decryption: 22 cycles of key generation (stored), then 22 inverse rounds.
module speck_decrypt (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [31:0] ciphertext,
    input  wire [63:0] key,
    output reg  [31:0] plaintext,
    output reg         done,
    output reg         busy
);
    localparam IDLE = 2'd0, KEYGEN = 2'd1, RUN = 2'd2, DONE = 2'd3;
    reg [1:0]  state;
    reg [15:0] L, R;
    reg [4:0]  idx;
    reg [15:0] keys [0:21];
    wire [15:0] rk;

    wire load = (state == IDLE) && start;
    wire step = (state == KEYGEN);

    speck_key_expansion u_key (.clk(clk), .rst_n(rst_n), .load(load), .step(step),
                               .key_in(key), .round_key(rk));

    // inverse round
    wire [15:0] x    = R ^ L;
    wire [15:0] Rp   = {x[1:0], x[15:2]};                 // ROR 2
    wire [15:0] y    = (L ^ keys[idx]) - Rp;
    wire [15:0] Lp   = {y[8:0], y[15:9]};                 // ROL 7

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; idx <= 5'd0; done <= 1'b0; busy <= 1'b0;
            L <= 16'd0; R <= 16'd0; plaintext <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        L <= ciphertext[31:16]; R <= ciphertext[15:0];
                        idx <= 5'd0; busy <= 1'b1; state <= KEYGEN;
                    end
                end
                KEYGEN: begin
                    keys[idx] <= rk;
                    if (idx == 5'd21) state <= RUN;
                    else idx <= idx + 5'd1;
                end
                RUN: begin
                    L <= Lp; R <= Rp;
                    if (idx == 5'd0) state <= DONE;
                    else idx <= idx - 5'd1;
                end
                DONE: begin
                    plaintext <= {L, R};
                    done <= 1'b1; busy <= 1'b0; state <= IDLE;
                end
            endcase
        end
    end
endmodule
