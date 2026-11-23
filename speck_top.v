// SPECK32/64 encryption: iterative, one round per clock, 22 rounds.
module speck_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [31:0] plaintext,
    input  wire [63:0] key,
    output reg  [31:0] ciphertext,
    output reg         done,
    output reg         busy
);
    localparam IDLE = 2'd0, RUN = 2'd1, DONE = 2'd2;
    reg [1:0]  state;
    reg [15:0] L, R;
    reg [4:0]  round_count;
    wire [15:0] rk, L_next, R_next;

    wire load = (state == IDLE) && start;
    wire step = (state == RUN);

    speck_key_expansion u_key (.clk(clk), .rst_n(rst_n), .load(load), .step(step),
                               .key_in(key), .round_key(rk));
    speck_round u_round (.Lin(L), .Rin(R), .rk(rk), .Lout(L_next), .Rout(R_next));

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE; round_count <= 5'd0; done <= 1'b0; busy <= 1'b0;
            L <= 16'd0; R <= 16'd0; ciphertext <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    if (start) begin
                        L <= plaintext[31:16]; R <= plaintext[15:0];
                        round_count <= 5'd0; busy <= 1'b1; state <= RUN;
                    end
                end
                RUN: begin
                    L <= L_next; R <= R_next;
                    round_count <= round_count + 5'd1;
                    if (round_count == 5'd21) state <= DONE;
                end
                DONE: begin
                    ciphertext <= {L, R};
                    done <= 1'b1; busy <= 1'b0; state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
