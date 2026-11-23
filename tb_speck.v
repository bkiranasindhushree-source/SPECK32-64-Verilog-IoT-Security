`timescale 1ns/1ps
// Self-checking testbench: published SPECK32/64 vector + encrypt/decrypt round trip.
module tb_speck;
    reg clk = 1'b0;
    always #5 clk = ~clk;

    reg         rst_n, start_e, start_d;
    reg  [31:0] pt, ct_in;
    reg  [63:0] key;
    wire [31:0] ct, dec;
    wire        done_e, busy_e, done_d, busy_d;
    integer     errors;

    localparam [63:0] KEY    = 64'h1918111009080100;
    localparam [31:0] PT     = 32'h6574694C;
    localparam [31:0] CT_REF = 32'hA86842F2;

    speck_top     u_enc (.clk(clk), .rst_n(rst_n), .start(start_e), .plaintext(pt),
                         .key(key), .ciphertext(ct), .done(done_e), .busy(busy_e));
    speck_decrypt u_dec (.clk(clk), .rst_n(rst_n), .start(start_d), .ciphertext(ct_in),
                         .key(key), .plaintext(dec), .done(done_d), .busy(busy_d));

    initial begin
        errors = 0; rst_n = 1'b0; start_e = 1'b0; start_d = 1'b0;
        pt = PT; key = KEY; ct_in = 32'd0;
        #25 rst_n = 1'b1;

        @(posedge clk); #1 start_e = 1'b1;
        @(posedge clk); #1 start_e = 1'b0;
        @(posedge done_e); #1;
        $display("Ciphertext = %h (expected %h)", ct, CT_REF);
        if (ct !== CT_REF) begin errors = errors + 1; $display("FAIL: ciphertext mismatch"); end

        ct_in = ct;
        @(posedge clk); #1 start_d = 1'b1;
        @(posedge clk); #1 start_d = 1'b0;
        @(posedge done_d); #1;
        $display("Decrypted  = %h (expected %h)", dec, PT);
        if (dec !== PT) begin errors = errors + 1; $display("FAIL: decrypt mismatch"); end

        if (errors == 0) $display("VERIFY: PASS");
        else             $display("VERIFY: FAIL (%0d errors)", errors);
        $finish;
    end

    initial begin #5000; $display("FAIL: timeout"); $finish; end

    initial begin $dumpfile("speck.vcd"); $dumpvars(0, tb_speck); end
endmodule
