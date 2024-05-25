module fcvt (
    input       [31:0]  uart_input,
    input       [3:0]   test_case,
    output  reg [31:0]  real_input
);
    parameter EXPONENT_BIAS = 15;
    parameter EXPONENT_LENGTH = 5;
    parameter MANTISSA_LENGTH = 10;

    reg     [31:0]  mantissa;
    reg     [7:0]   exponent;
    reg             sign;
    reg     [31:0]  shifted_mantissa;
    reg     [31:0]  adjustment;

    wire    [15:0]  fp;
    reg     [1:0]   rounding_mode;
    assign fp = uart_input[15:0];

    always @(test_case) begin
        case (test_case)
            4'b1001: rounding_mode = 2'b00; // ceil
            4'b1010: rounding_mode = 2'b01; // floor
            4'b1011: rounding_mode = 2'b10; // round to nearest
            default: rounding_mode = 2'b11; // default, no rounding
        endcase
    end

    always @(fp or rounding_mode) begin
        // Extract sign, exponent, and mantissa
        sign = fp[15];
        exponent = fp[14:10];
        mantissa = {1'b1, fp[MANTISSA_LENGTH-1:0]}; // Implicit leading 1 for normalized numbers

        // Calculate actual exponent value by subtracting bias and adjusting for the mantissa bits
        if (exponent >= EXPONENT_BIAS + MANTISSA_LENGTH) begin
            shifted_mantissa = mantissa << (exponent - (EXPONENT_BIAS + MANTISSA_LENGTH));
        end else begin
            shifted_mantissa = mantissa >> ((EXPONENT_BIAS + MANTISSA_LENGTH) - exponent);
        end

        // Initialize adjustment based on rounding mode
        adjustment = 0;

        case(rounding_mode)
            2'b00: begin // ceil
                if (sign) begin
                    real_input = -shifted_mantissa;
                end else begin
                    if (exponent < EXPONENT_BIAS + MANTISSA_LENGTH && (mantissa & ((1 << ((EXPONENT_BIAS + MANTISSA_LENGTH) - exponent)) - 1)) != 0) begin
                        adjustment = 1;
                    end
                    real_input = shifted_mantissa + adjustment;
                end
            end
            2'b01: begin // floor
                if (sign) begin
                    if (exponent < EXPONENT_BIAS + MANTISSA_LENGTH && (mantissa & ((1 << ((EXPONENT_BIAS + MANTISSA_LENGTH) - exponent)) - 1)) != 0) begin
                        adjustment = 1;
                    end
                    real_input = -(shifted_mantissa + adjustment);
                end else begin
                    real_input = shifted_mantissa;
                end
            end
            2'b10: begin // round to nearest
                if (exponent < EXPONENT_BIAS + MANTISSA_LENGTH) begin
                    // Check the bits that would be shifted out
                    if ((mantissa & (1 << ((EXPONENT_BIAS + MANTISSA_LENGTH) - exponent - 1))) != 0) begin
                        // If exactly in the middle, round to even (banker's rounding)
                        if ((mantissa & ((1 << ((EXPONENT_BIAS + MANTISSA_LENGTH) - exponent)) - 1)) != 0 || (shifted_mantissa[0] != 0)) begin
                            adjustment = 1;
                        end
                    end
                end
                real_input = sign ? -(shifted_mantissa + adjustment) : (shifted_mantissa + adjustment);
            end
            default: real_input = uart_input;
        endcase
    end
endmodule
