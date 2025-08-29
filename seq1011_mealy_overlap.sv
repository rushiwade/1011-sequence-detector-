// -----------------------------------------------------------------------------
// 1011 Sequence Detector (Mealy, overlapping allowed, sync reset)
// det pulses high for 1 cycle on the same clock edge the final '1' arrives.
// -----------------------------------------------------------------------------
module seq1011_mealy_overlap (
    input  logic clk,
    input  logic rst,   // active-high synchronous reset
    input  logic din,   // serial input bit
    output logic det    // 1-cycle pulse when "1011" detected
);

    // State encoding
    typedef enum logic [1:0] {
        S0, // no match
        S1, // matched '1'
        S2, // matched '10'
        S3  // matched '101'
    } state_e;

    state_e state, state_next;
    logic   det_next;

    // Next-state and Mealy output (combinational)
    always_comb begin
        // Safe defaults
        state_next = state;
        // Mealy condition: assert when currently in S3 and next input is '1'
        det_next   = (state == S3) && (din == 1'b1);

        unique case (state)
            S0: begin
                if (din) state_next = S1;
                else     state_next = S0;
            end

            S1: begin
                if (din) state_next = S1; // suffix '1'
                else     state_next = S2; // seen '10'
            end

            S2: begin
                if (din) state_next = S3; // seen '101'
                else     state_next = S0; // reset on '0'
            end

            S3: begin
                if (din) state_next = S1; // detected '1011', suffix '1' enables overlap
                else     state_next = S2; // suffix '10'
            end

            default: state_next = S0;
        endcase
    end

    // Sequential: state and registered pulse output
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= S0;
            det   <= 1'b0;
        end else begin
            state <= state_next;
            det   <= det_next; // one-cycle pulse
        end
    end

endmodule
