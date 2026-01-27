#!/usr/bin/env bats
# Behavior-Driven Tests for bash-calc
#
# The orchestrator that combines bash-calc-eval and bash-calc-convert.
# Tests are designed from specification, NOT implementation.
#
# SPECIFICATION:
# - Output flags (-d, -x, -b, -o, -a) -> passed to bash-calc-convert
# - Input flags (-D, -X, -B, -O) -> passed to both tools
# - Eval flags (-f, -i, -p N) -> passed to bash-calc-eval
# - Flow: input -> eval -> convert -> output
# - Smart routing: plain number + output flag = skip eval, just convert
# - Stdin: read from stdin if no expression argument
# - -h: combined help

# =============================================================================
# Test Setup and Helpers
# =============================================================================

setup() {
    # Path to script under test
    SCRIPT="$BATS_TEST_DIRNAME/../bash-calc"

    # Paths to dependencies (for existence checks)
    EVAL_SCRIPT="$BATS_TEST_DIRNAME/../bash-calc-eval"
    CONVERT_SCRIPT="$BATS_TEST_DIRNAME/../bash-calc-convert"
}

# =============================================================================
# Behavior: Script Existence and Executability
# =============================================================================

@test "bash-calc script exists" {
    # Given: the bin directory structure
    # When: we check for the script
    # Then: the file should exist
    [[ -f "$SCRIPT" ]]
}

@test "bash-calc script is executable" {
    # Given: the script file exists
    # When: we check its permissions
    # Then: it should have execute permission
    [[ -x "$SCRIPT" ]]
}

@test "bash-calc-eval dependency exists" {
    # Given: bash-calc requires bash-calc-eval
    # When: we check for the dependency
    # Then: the file should exist and be executable
    [[ -f "$EVAL_SCRIPT" ]]
    [[ -x "$EVAL_SCRIPT" ]]
}

@test "bash-calc-convert dependency exists" {
    # Given: bash-calc requires bash-calc-convert
    # When: we check for the dependency
    # Then: the file should exist and be executable
    [[ -f "$CONVERT_SCRIPT" ]]
    [[ -x "$CONVERT_SCRIPT" ]]
}

# =============================================================================
# Behavior: Help and Usage
# =============================================================================

@test "help flag -h shows combined usage information" {
    # Given: the script exists
    # When: invoked with -h flag
    run "$SCRIPT" -h

    # Then: it should succeed and show usage information
    [[ "$status" -eq 0 ]]
    [[ "$output" =~ [Uu]sage ]] || [[ "$output" =~ [Hh]elp ]]
}

@test "help includes both eval and convert functionality" {
    # Given: the orchestrator combines two tools
    # When: viewing help
    run "$SCRIPT" -h

    # Then: help should mention conversion flags and eval features
    [[ "$status" -eq 0 ]]
    # Should mention output formats (hex, binary, etc.)
    [[ "$output" =~ -x ]] || [[ "$output" =~ hex ]] || [[ "$output" =~ [Hh]exadecimal ]]
}

@test "no arguments shows usage and exits non-zero" {
    # Given: the script exists
    # When: invoked with no arguments and no stdin
    run "$SCRIPT"

    # Then: it should exit non-zero and show usage
    [[ "$status" -ne 0 ]]
    [[ "$output" =~ [Uu]sage ]] || [[ "$output" =~ [Ee]rror ]]
}

# =============================================================================
# Behavior: Basic Eval (No Conversion)
# =============================================================================

@test "basic eval: 4+7 outputs 11" {
    # Given: a simple addition expression with no output flag
    # When: evaluating the expression
    run "$SCRIPT" '4+7'

    # Then: output should be 11 (decimal, default)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11" ]]
}

@test "basic eval: 2^10 outputs 1024" {
    # Given: a power expression
    # When: evaluating the expression
    run "$SCRIPT" '2^10'

    # Then: output should be 1024
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1024" ]]
}

@test "basic eval: 100/3 outputs 33.333333" {
    # Given: a division expression (float mode is default)
    # When: evaluating the expression
    run "$SCRIPT" '100/3'

    # Then: output should be 33.333333 (default 6 decimal places)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.333333" ]]
}

@test "basic eval: 10-3 outputs 7" {
    # Given: a simple subtraction expression
    # When: evaluating the expression
    run "$SCRIPT" '10-3'

    # Then: output should be 7
    [[ "$status" -eq 0 ]]
    [[ "$output" == "7" ]]
}

@test "basic eval: 6*7 outputs 42" {
    # Given: a simple multiplication expression
    # When: evaluating the expression
    run "$SCRIPT" '6*7'

    # Then: output should be 42
    [[ "$status" -eq 0 ]]
    [[ "$output" == "42" ]]
}

@test "basic eval: 17%5 outputs 2" {
    # Given: a modulo expression
    # When: evaluating the expression
    run "$SCRIPT" '17%5'

    # Then: output should be 2
    [[ "$status" -eq 0 ]]
    [[ "$output" == "2" ]]
}

# =============================================================================
# Behavior: Smart Routing - Convert Only (Plain Number + Output Flag)
# =============================================================================

@test "convert only: -x 255 outputs ff" {
    # Given: a plain decimal number with hex output flag
    # When: routing should skip eval and just convert
    run "$SCRIPT" -x 255

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "convert only: -b 255 outputs 11111111" {
    # Given: a plain decimal number with binary output flag
    # When: routing should skip eval and just convert
    run "$SCRIPT" -b 255

    # Then: output should be 11111111
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11111111" ]]
}

@test "convert only: 255 -o outputs 377" {
    # Given: a plain decimal number with octal output flag (flag after value)
    # When: routing should skip eval and just convert
    run "$SCRIPT" 255 -o

    # Then: output should be 377
    [[ "$status" -eq 0 ]]
    [[ "$output" == "377" ]]
}

@test "convert only: -d 255 outputs 255" {
    # Given: a plain decimal number with explicit decimal output flag
    # When: routing should skip eval and just convert
    run "$SCRIPT" -d 255

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "convert only: 0xff -d outputs 255" {
    # Given: a hex input with decimal output flag
    # When: routing should skip eval (no expression) and just convert
    run "$SCRIPT" 0xff -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "convert only: 0b11111111 -x outputs ff" {
    # Given: a binary input with hex output flag
    # When: routing should skip eval and just convert
    run "$SCRIPT" 0b11111111 -x

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

# =============================================================================
# Behavior: Eval + Convert Combined
# =============================================================================

@test "eval+convert: -x 255 & 0xf0 outputs f0" {
    # Given: a bitwise expression with hex output flag
    # When: evaluating then converting
    run "$SCRIPT" -x '255 & 0xf0'

    # Then: output should be f0 (255 & 240 = 240 = 0xf0)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "f0" ]]
}

@test "eval+convert: -b 1 << 8 outputs 100000000" {
    # Given: a left shift expression with binary output flag
    # When: evaluating then converting
    run "$SCRIPT" -b '1 << 8'

    # Then: output should be 100000000 (256 in binary)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "100000000" ]]
}

@test "eval+convert: -x 2^8 - 1 outputs ff" {
    # Given: a power expression minus one with hex output flag
    # When: evaluating then converting
    run "$SCRIPT" -x '2^8 - 1'

    # Then: output should be ff (256 - 1 = 255 = 0xff)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "eval+convert: -o 8*8 outputs 100" {
    # Given: multiplication with octal output flag
    # When: evaluating then converting
    run "$SCRIPT" -o '8*8'

    # Then: output should be 100 (64 in octal)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "100" ]]
}

@test "eval+convert: -b 0xff xor 0x0f outputs 11110000" {
    # Given: a bitwise XOR with binary output flag
    # When: evaluating then converting
    run "$SCRIPT" -b '0xff xor 0x0f'

    # Then: output should be 11110000 (255 xor 15 = 240)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11110000" ]]
}

@test "eval+convert: -x (2+3)*4 outputs 14" {
    # Given: parenthesized expression with hex output flag
    # When: evaluating then converting
    run "$SCRIPT" -x '(2+3)*4'

    # Then: output should be 14 (20 in hex)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "14" ]]
}

# =============================================================================
# Behavior: All Bases Output (-a)
# =============================================================================

@test "all bases: -a 1 << 8 outputs 256 tab 100 tab 100000000 tab 400" {
    # Given: a shift expression with all-formats output flag
    # When: evaluating then converting to all formats
    run "$SCRIPT" -a '1 << 8'

    # Then: output should be tab-separated: decimal, hex, binary, octal
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'256\t100\t100000000\t400' ]]
}

@test "all bases: -a 255 outputs 255 tab ff tab 11111111 tab 377" {
    # Given: a plain number with all-formats output flag
    # When: converting to all formats
    run "$SCRIPT" -a 255

    # Then: output should be tab-separated all formats
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'255\tff\t11111111\t377' ]]
}

@test "all bases: -a 4+7 outputs 11 tab b tab 1011 tab 13" {
    # Given: a simple expression with all-formats output flag
    # When: evaluating then converting to all formats
    run "$SCRIPT" -a '4+7'

    # Then: output should be tab-separated all formats
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'11\tb\t1011\t13' ]]
}

@test "all bases: -a 0 outputs all zeros" {
    # Given: zero value with all-formats output flag
    # When: converting to all formats
    run "$SCRIPT" -a 0

    # Then: output should be 0 in all formats
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'0\t0\t0\t0' ]]
}

# =============================================================================
# Behavior: Combined Eval Flags with Conversion
# =============================================================================

@test "integer mode with hex output: -i -x 100/3 outputs 21" {
    # Given: integer division with hex output
    # When: evaluating in integer mode then converting to hex
    run "$SCRIPT" -i -x '100/3'

    # Then: 100/3 = 33 (integer), 33 in hex = 21
    [[ "$status" -eq 0 ]]
    [[ "$output" == "21" ]]
}

@test "precision with no conversion: -p 2 100/3 outputs 33.33" {
    # Given: division with custom precision, no output conversion
    # When: evaluating with precision flag
    run "$SCRIPT" -p 2 '100/3'

    # Then: output should be 33.33
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.33" ]]
}

@test "integer mode with binary output: -i -b 100/3 outputs 100001" {
    # Given: integer division with binary output
    # When: evaluating in integer mode then converting to binary
    run "$SCRIPT" -i -b '100/3'

    # Then: 100/3 = 33 (integer), 33 in binary = 100001
    [[ "$status" -eq 0 ]]
    [[ "$output" == "100001" ]]
}

@test "float mode explicit with no conversion: -f 100/3 outputs 33.333333" {
    # Given: explicit float mode division
    # When: evaluating
    run "$SCRIPT" -f '100/3'

    # Then: output should be 33.333333
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.333333" ]]
}

@test "precision with all bases: -p 0 -a 100/3 outputs integer in all bases" {
    # Given: zero precision (integer result) with all-formats output
    # When: evaluating then converting to all formats
    run "$SCRIPT" -p 0 -a '100/3'

    # Then: 100/3 with precision 0 = 33, shown in all bases
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'33\t21\t100001\t41' ]]
}

# =============================================================================
# Behavior: Input Flags Passed to Both Tools
# =============================================================================

@test "input flag -X with expression: -X ff + 1 outputs 256" {
    # Given: hex input flag with addition
    # When: forcing hex interpretation of input
    run "$SCRIPT" -X 'ff + 1'

    # Then: ff (255) + 1 = 256
    [[ "$status" -eq 0 ]]
    [[ "$output" == "256" ]]
}

@test "input flag -B with expression: -B 1111 + 1 outputs 16" {
    # Given: binary input flag with addition
    # When: forcing binary interpretation of input
    run "$SCRIPT" -B '1111 + 1'

    # Then: 1111 (15) + 1 = 16
    [[ "$status" -eq 0 ]]
    [[ "$output" == "16" ]]
}

@test "input and output flags combined: -X ff -x outputs ff" {
    # Given: hex input and hex output
    # When: converting (no eval needed - plain number)
    run "$SCRIPT" -X ff -x

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "input and output flags with expression: -X ff -b & f0 outputs 11110000" {
    # Given: hex input, bitwise AND, binary output
    # When: evaluating then converting
    run "$SCRIPT" -X 'ff & f0' -b

    # Then: 255 & 240 = 240, 240 in binary = 11110000
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11110000" ]]
}

# =============================================================================
# Behavior: Stdin Input
# =============================================================================

@test "stdin eval: echo 4+7 | calc outputs 11" {
    # Given: an expression provided via stdin
    # When: evaluating without argument
    run bash -c "echo '4+7' | '$SCRIPT'"

    # Then: output should be 11
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11" ]]
}

@test "stdin convert: echo 255 | calc -x outputs ff" {
    # Given: a plain number via stdin with hex output flag
    # When: converting to hex
    run bash -c "echo 255 | '$SCRIPT' -x"

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "stdin eval+convert: echo 255 & 240 | calc -x outputs f0" {
    # Given: a bitwise expression via stdin with hex output flag
    # When: evaluating then converting
    run bash -c "echo '255 & 240' | '$SCRIPT' -x"

    # Then: output should be f0
    [[ "$status" -eq 0 ]]
    [[ "$output" == "f0" ]]
}

@test "stdin with all bases: echo 2^8 | calc -a outputs all formats" {
    # Given: an expression via stdin with all-formats flag
    # When: evaluating then converting
    run bash -c "echo '2^8' | '$SCRIPT' -a"

    # Then: 256 in all formats
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'256\t100\t100000000\t400' ]]
}

@test "stdin with integer mode: echo 100/3 | calc -i outputs 33" {
    # Given: division via stdin in integer mode
    # When: evaluating with -i flag
    run bash -c "echo '100/3' | '$SCRIPT' -i"

    # Then: output should be 33
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33" ]]
}

@test "stdin with precision: echo 100/3 | calc -p 2 outputs 33.33" {
    # Given: division via stdin with custom precision
    # When: evaluating with -p 2 flag
    run bash -c "echo '100/3' | '$SCRIPT' -p 2"

    # Then: output should be 33.33
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.33" ]]
}

# =============================================================================
# Behavior: Error Propagation from bash-calc-eval
# =============================================================================

@test "error: invalid expression syntax propagates" {
    # Given: an invalid expression
    # When: evaluating
    run "$SCRIPT" '2++3'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error: division by zero propagates" {
    # Given: a division by zero expression
    # When: evaluating
    run "$SCRIPT" '10/0'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error: unbalanced parentheses propagates" {
    # Given: an expression with unbalanced parentheses
    # When: evaluating
    run "$SCRIPT" '(2+3'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error: float mode with bitwise propagates" {
    # Given: a bitwise expression with explicit float mode
    # When: evaluating with -f flag
    run "$SCRIPT" -f '255 & 240'

    # Then: should exit non-zero (bitwise requires integer mode)
    [[ "$status" -ne 0 ]]
}

@test "error: empty expression" {
    # Given: an empty string expression
    # When: evaluating
    run "$SCRIPT" ''

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

# =============================================================================
# Behavior: Error Propagation from bash-calc-convert
# =============================================================================

@test "error: float result cannot be converted to hex" {
    # Given: a division with float result and hex output requested
    # When: attempting to convert a float to hex
    run "$SCRIPT" -x '100/3'

    # Then: should exit non-zero (cannot convert 33.333333 to hex)
    [[ "$status" -ne 0 ]]
}

@test "error: float result cannot be converted to binary" {
    # Given: a division with float result and binary output requested
    # When: attempting to convert a float to binary
    run "$SCRIPT" -b '100/3'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error: float result cannot be converted to octal" {
    # Given: a division with float result and octal output requested
    # When: attempting to convert a float to octal
    run "$SCRIPT" -o '100/3'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

# =============================================================================
# Behavior: Integer Mode Enables Base Conversion
# =============================================================================

@test "integer mode enables hex conversion: -i -x 100/3 works" {
    # Given: integer division should produce integer output
    # When: converting to hex
    run "$SCRIPT" -i -x '100/3'

    # Then: 33 in hex = 21
    [[ "$status" -eq 0 ]]
    [[ "$output" == "21" ]]
}

@test "precision 0 enables hex conversion: -p 0 -x 100/3 works" {
    # Given: zero precision should produce integer output
    # When: converting to hex
    run "$SCRIPT" -p 0 -x '100/3'

    # Then: 33 in hex = 21
    [[ "$status" -eq 0 ]]
    [[ "$output" == "21" ]]
}

# =============================================================================
# Behavior: Complex Expressions with Conversion
# =============================================================================

@test "complex bitwise to hex: -x (0xff & 0xf0) | 0x0f outputs ff" {
    # Given: a complex bitwise expression with hex output
    # When: evaluating then converting
    run "$SCRIPT" -x '(0xff & 0xf0) | 0x0f'

    # Then: (255 & 240) | 15 = 240 | 15 = 255 = 0xff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "complex arithmetic to binary: -b 2^4 - 1 outputs 1111" {
    # Given: power minus one to binary
    # When: evaluating then converting
    run "$SCRIPT" -b '2^4 - 1'

    # Then: 16 - 1 = 15 = 1111 in binary
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1111" ]]
}

@test "complex with parentheses to all: -a ((10+5)*2) outputs all formats" {
    # Given: complex expression with all-formats output
    # When: evaluating then converting
    run "$SCRIPT" -a '((10+5)*2)'

    # Then: (15)*2 = 30 in all formats
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'30\t1e\t11110\t36' ]]
}

# =============================================================================
# Behavior: Edge Cases and Boundary Values
# =============================================================================

@test "zero handling: 0+0 outputs 0" {
    # Given: an expression with zeros
    # When: evaluating
    run "$SCRIPT" '0+0'

    # Then: output should be 0
    [[ "$status" -eq 0 ]]
    [[ "$output" == "0" ]]
}

@test "zero to all bases: -a 0 outputs all zeros" {
    # Given: zero with all-formats flag
    # When: converting
    run "$SCRIPT" -a 0

    # Then: all formats should be 0
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'0\t0\t0\t0' ]]
}

@test "large number: 2^16 - 1 outputs 65535" {
    # Given: 16-bit max value expression
    # When: evaluating
    run "$SCRIPT" '2^16 - 1'

    # Then: output should be 65535
    [[ "$status" -eq 0 ]]
    [[ "$output" == "65535" ]]
}

@test "large number to hex: -x 2^16 - 1 outputs ffff" {
    # Given: 16-bit max value to hex
    # When: evaluating then converting
    run "$SCRIPT" -x '2^16 - 1'

    # Then: 65535 = ffff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ffff" ]]
}

@test "negative number with no conversion: -5+10 outputs 5" {
    # Given: expression with negative number
    # When: evaluating
    run "$SCRIPT" '-5+10'

    # Then: output should be 5
    [[ "$status" -eq 0 ]]
    [[ "$output" == "5" ]]
}

# =============================================================================
# Behavior: Flag Order Flexibility
# =============================================================================

@test "flags can be before expression: -i -x 100/3 outputs 21" {
    # Given: flags before expression
    # When: evaluating
    run "$SCRIPT" -i -x '100/3'

    # Then: should work correctly
    [[ "$status" -eq 0 ]]
    [[ "$output" == "21" ]]
}

@test "output flag can be after expression: 255 -x outputs ff" {
    # Given: output flag after value
    # When: converting
    run "$SCRIPT" 255 -x

    # Then: should work correctly
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "expression can be between flags: -i 100/3 -x outputs 21" {
    # Given: expression between eval and output flags
    # When: evaluating
    run "$SCRIPT" -i '100/3' -x

    # Then: should work correctly
    [[ "$status" -eq 0 ]]
    [[ "$output" == "21" ]]
}

@test "multiple eval flags work together: -f -p 4 100/3 outputs 33.3333" {
    # Given: multiple eval flags
    # When: evaluating
    run "$SCRIPT" -f -p 4 '100/3'

    # Then: should respect both flags
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.3333" ]]
}

# =============================================================================
# Behavior: Idempotency and Consistency
# =============================================================================

@test "consistent results: same expression produces same output" {
    # Given: the same expression evaluated twice
    # When: running the calculation
    run "$SCRIPT" -x '2^8 - 1'
    local first="$output"

    run "$SCRIPT" -x '2^8 - 1'
    local second="$output"

    # Then: both results should be identical
    [[ "$first" == "$second" ]]
    [[ "$first" == "ff" ]]
}

@test "stdin matches argument: same result both ways" {
    # Given: the same expression via stdin and argument
    # When: evaluating both ways
    run "$SCRIPT" -x '255 & 0xf0'
    local arg_result="$output"

    run bash -c "echo '255 & 0xf0' | '$SCRIPT' -x"
    local stdin_result="$output"

    # Then: both results should be identical
    [[ "$arg_result" == "$stdin_result" ]]
    [[ "$arg_result" == "f0" ]]
}

# =============================================================================
# Behavior: Smart Routing Detects Expressions vs Plain Numbers
# =============================================================================

@test "smart routing: expression with operators goes through eval" {
    # Given: an expression with an operator
    # When: evaluating
    run "$SCRIPT" -x '1+254'

    # Then: should evaluate then convert (1+254 = 255 = ff)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "smart routing: plain decimal skips eval" {
    # Given: a plain decimal number (no operators)
    # When: converting with output flag
    run "$SCRIPT" -x 255

    # Then: should convert directly to ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "smart routing: plain hex skips eval" {
    # Given: a plain hex number with 0x prefix
    # When: converting with output flag
    run "$SCRIPT" -d 0xff

    # Then: should convert directly to 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "smart routing: whitespace-only padding is plain number" {
    # Given: a number with surrounding whitespace
    # When: converting
    run "$SCRIPT" -x ' 255 '

    # Then: should treat as plain number and convert
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

# =============================================================================
# Behavior: Bitwise Operations with Conversion
# =============================================================================

@test "bitwise AND to hex: -x 0xff & 0x0f outputs f" {
    # Given: bitwise AND with hex output
    # When: evaluating then converting
    run "$SCRIPT" -x '0xff & 0x0f'

    # Then: 255 & 15 = 15 = f
    [[ "$status" -eq 0 ]]
    [[ "$output" == "f" ]]
}

@test "bitwise OR to binary: -b 0xf0 | 0x0f outputs 11111111" {
    # Given: bitwise OR with binary output
    # When: evaluating then converting
    run "$SCRIPT" -b '0xf0 | 0x0f'

    # Then: 240 | 15 = 255 = 11111111
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11111111" ]]
}

@test "bitwise shift left to all: -a 1 << 4 outputs all formats" {
    # Given: left shift with all-formats output
    # When: evaluating then converting
    run "$SCRIPT" -a '1 << 4'

    # Then: 16 in all formats
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'16\t10\t10000\t20' ]]
}

@test "bitwise shift right to hex: -x 256 >> 4 outputs 10" {
    # Given: right shift with hex output
    # When: evaluating then converting
    run "$SCRIPT" -x '256 >> 4'

    # Then: 256 >> 4 = 16 = 10 in hex
    [[ "$status" -eq 0 ]]
    [[ "$output" == "10" ]]
}

@test "bitwise NOT to hex: -x ~0xffffff00 outputs ff" {
    # Given: bitwise NOT with hex output (masking to 8 bits conceptually)
    # When: evaluating then converting
    # Note: ~0 = -1 in two's complement, result depends on word size
    # This tests that bitwise NOT works through the pipeline
    run "$SCRIPT" -x '~0 & 0xff'

    # Then: ~0 = all 1s, & 0xff = 255 = ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "bitwise XOR to octal: -o 255 xor 170 outputs 125" {
    # Given: bitwise XOR with octal output
    # When: evaluating then converting
    run "$SCRIPT" -o '255 xor 170'

    # Then: 255 xor 170 = 85 = 125 in octal
    [[ "$status" -eq 0 ]]
    [[ "$output" == "125" ]]
}
