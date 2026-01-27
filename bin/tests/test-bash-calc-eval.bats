#!/usr/bin/env bats
# Behavior-Driven Tests for bash-calc-eval
#
# An expression evaluator for arithmetic and bitwise operations.
# Tests are designed from specification, NOT implementation.
#
# SPECIFICATION:
# - Division flags: -f (float, default), -i (integer)
# - Precision: -p N (decimal places, default 6, only with -f)
# - Arithmetic: +, -, *, /, ^ (power), % (modulo)
# - Bitwise: &, |, ~ (NOT), <<, >> (integers only, error if -f with bitwise)
# - NOTE: For XOR use 'xor' keyword since ^ is power
# - Parentheses for grouping
# - Stdin: read from stdin if no expression argument
# - -h: show help

# =============================================================================
# Test Setup and Helpers
# =============================================================================

setup() {
    # Path to script under test
    SCRIPT="$BATS_TEST_DIRNAME/../bash-calc-eval"
}

# =============================================================================
# Behavior: Script Existence and Executability
# =============================================================================

@test "bash-calc-eval script exists" {
    # Given: the bin directory structure
    # When: we check for the script
    # Then: the file should exist
    [[ -f "$SCRIPT" ]]
}

@test "bash-calc-eval script is executable" {
    # Given: the script file exists
    # When: we check its permissions
    # Then: it should have execute permission
    [[ -x "$SCRIPT" ]]
}

# =============================================================================
# Behavior: Help and Usage
# =============================================================================

@test "help flag -h shows usage information" {
    # Given: the script exists
    # When: invoked with -h flag
    run "$SCRIPT" -h

    # Then: it should succeed and show usage information
    [[ "$status" -eq 0 ]]
    [[ "$output" =~ [Uu]sage ]] || [[ "$output" =~ [Hh]elp ]]
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
# Behavior: Basic Arithmetic Operations
# =============================================================================

@test "basic addition: 4+7 outputs 11" {
    # Given: a simple addition expression
    # When: evaluating the expression
    run "$SCRIPT" '4+7'

    # Then: output should be 11
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11" ]]
}

@test "basic subtraction: 10-3 outputs 7" {
    # Given: a simple subtraction expression
    # When: evaluating the expression
    run "$SCRIPT" '10-3'

    # Then: output should be 7
    [[ "$status" -eq 0 ]]
    [[ "$output" == "7" ]]
}

@test "basic multiplication: 6*7 outputs 42" {
    # Given: a simple multiplication expression
    # When: evaluating the expression
    run "$SCRIPT" '6*7'

    # Then: output should be 42
    [[ "$status" -eq 0 ]]
    [[ "$output" == "42" ]]
}

@test "basic division float default: 100/3 outputs 33.333333" {
    # Given: a division expression (float mode is default)
    # When: evaluating the expression
    run "$SCRIPT" '100/3'

    # Then: output should be 33.333333 (default 6 decimal places)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.333333" ]]
}

@test "power operator: 2^10 outputs 1024" {
    # Given: a power expression
    # When: evaluating the expression
    run "$SCRIPT" '2^10'

    # Then: output should be 1024
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1024" ]]
}

@test "modulo operator: 10%3 outputs 1" {
    # Given: a modulo expression
    # When: evaluating the expression
    run "$SCRIPT" '10%3'

    # Then: output should be 1
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1" ]]
}

# =============================================================================
# Behavior: Division Modes (-f and -i)
# =============================================================================

@test "integer division: -i 100/3 outputs 33" {
    # Given: a division expression with integer mode
    # When: evaluating with -i flag
    run "$SCRIPT" -i '100/3'

    # Then: output should be 33 (truncated)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33" ]]
}

@test "explicit float division: -f 100/3 outputs 33.333333" {
    # Given: a division expression with explicit float mode
    # When: evaluating with -f flag
    run "$SCRIPT" -f '100/3'

    # Then: output should be 33.333333
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.333333" ]]
}

@test "integer mode with exact division: -i 100/4 outputs 25" {
    # Given: an exact division in integer mode
    # When: evaluating with -i flag
    run "$SCRIPT" -i '100/4'

    # Then: output should be 25
    [[ "$status" -eq 0 ]]
    [[ "$output" == "25" ]]
}

# =============================================================================
# Behavior: Precision Control (-p)
# =============================================================================

@test "custom precision: -p 2 100/3 outputs 33.33" {
    # Given: a division with custom precision
    # When: evaluating with -p 2 flag
    run "$SCRIPT" -p 2 '100/3'

    # Then: output should be 33.33
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.33" ]]
}

@test "custom precision: -p 0 100/3 outputs 33" {
    # Given: a division with zero precision
    # When: evaluating with -p 0 flag
    run "$SCRIPT" -p 0 '100/3'

    # Then: output should be 33 (no decimal point)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33" ]]
}

@test "custom precision: -p 10 100/3 outputs 10 decimal places" {
    # Given: a division with high precision
    # When: evaluating with -p 10 flag
    run "$SCRIPT" -p 10 '100/3'

    # Then: output should have 10 decimal places
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.3333333333" ]]
}

@test "precision with exact result: -p 4 100/4 outputs 25.0000" {
    # Given: an exact division with precision specified
    # When: evaluating with -p 4 flag
    run "$SCRIPT" -p 4 '100/4'

    # Then: output should be 25.0000 (with trailing zeros)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "25.0000" ]]
}

# =============================================================================
# Behavior: Bitwise Operations (Integer Mode Only)
# =============================================================================

@test "bitwise AND: 255 & 240 outputs 240" {
    # Given: a bitwise AND expression
    # When: evaluating the expression
    run "$SCRIPT" '255 & 240'

    # Then: output should be 240
    [[ "$status" -eq 0 ]]
    [[ "$output" == "240" ]]
}

@test "bitwise OR: 240 | 15 outputs 255" {
    # Given: a bitwise OR expression
    # When: evaluating the expression
    run "$SCRIPT" '240 | 15'

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "bitwise NOT: ~0 outputs -1" {
    # Given: a bitwise NOT expression (two's complement)
    # When: evaluating the expression
    run "$SCRIPT" '~0'

    # Then: output should be -1 (two's complement)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-1" ]]
}

@test "bitwise shift left: 1 << 8 outputs 256" {
    # Given: a left shift expression
    # When: evaluating the expression
    run "$SCRIPT" '1 << 8'

    # Then: output should be 256
    [[ "$status" -eq 0 ]]
    [[ "$output" == "256" ]]
}

@test "bitwise shift right: 256 >> 4 outputs 16" {
    # Given: a right shift expression
    # When: evaluating the expression
    run "$SCRIPT" '256 >> 4'

    # Then: output should be 16
    [[ "$status" -eq 0 ]]
    [[ "$output" == "16" ]]
}

@test "bitwise XOR using xor keyword: 255 xor 15 outputs 240" {
    # Given: a bitwise XOR expression using keyword
    # When: evaluating the expression
    run "$SCRIPT" '255 xor 15'

    # Then: output should be 240
    [[ "$status" -eq 0 ]]
    [[ "$output" == "240" ]]
}

@test "bitwise NOT on non-zero: ~255 outputs -256" {
    # Given: a bitwise NOT on 255
    # When: evaluating the expression
    run "$SCRIPT" '~255'

    # Then: output should be -256 (two's complement)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-256" ]]
}

# =============================================================================
# Behavior: Hex and Binary Input in Expressions
# =============================================================================

@test "hex in expression: 0xff & 0xf0 outputs 240" {
    # Given: hex values in a bitwise expression
    # When: evaluating the expression
    run "$SCRIPT" '0xff & 0xf0'

    # Then: output should be 240
    [[ "$status" -eq 0 ]]
    [[ "$output" == "240" ]]
}

@test "binary in expression: 0b1111 | 0b0001 outputs 15" {
    # Given: binary values in a bitwise expression
    # When: evaluating the expression
    run "$SCRIPT" '0b1111 | 0b0001'

    # Then: output should be 15
    [[ "$status" -eq 0 ]]
    [[ "$output" == "15" ]]
}

@test "mixed hex arithmetic: 0x10 + 0x10 outputs 32" {
    # Given: hex values in an arithmetic expression
    # When: evaluating the expression
    run "$SCRIPT" '0x10 + 0x10'

    # Then: output should be 32
    [[ "$status" -eq 0 ]]
    [[ "$output" == "32" ]]
}

@test "mixed binary arithmetic: 0b1000 * 2 outputs 16" {
    # Given: binary and decimal in an expression
    # When: evaluating the expression
    run "$SCRIPT" '0b1000 * 2'

    # Then: output should be 16
    [[ "$status" -eq 0 ]]
    [[ "$output" == "16" ]]
}

# =============================================================================
# Behavior: Parentheses for Grouping
# =============================================================================

@test "parentheses basic: (2+3)*4 outputs 20" {
    # Given: an expression with parentheses
    # When: evaluating the expression
    run "$SCRIPT" '(2+3)*4'

    # Then: output should be 20
    [[ "$status" -eq 0 ]]
    [[ "$output" == "20" ]]
}

@test "nested parentheses: ((2+3)*4)^2 outputs 400" {
    # Given: an expression with nested parentheses
    # When: evaluating the expression
    run "$SCRIPT" '((2+3)*4)^2'

    # Then: output should be 400
    [[ "$status" -eq 0 ]]
    [[ "$output" == "400" ]]
}

@test "parentheses with spaces: ( 2 + 3 ) * 4 outputs 20" {
    # Given: an expression with spaces around parentheses
    # When: evaluating the expression
    run "$SCRIPT" '( 2 + 3 ) * 4'

    # Then: output should be 20
    [[ "$status" -eq 0 ]]
    [[ "$output" == "20" ]]
}

@test "multiple parentheses groups: (2+3)*(4+5) outputs 45" {
    # Given: an expression with multiple parentheses groups
    # When: evaluating the expression
    run "$SCRIPT" '(2+3)*(4+5)'

    # Then: output should be 45
    [[ "$status" -eq 0 ]]
    [[ "$output" == "45" ]]
}

# =============================================================================
# Behavior: Stdin Input
# =============================================================================

@test "stdin input: echo 4+7 | bash-calc-eval outputs 11" {
    # Given: an expression provided via stdin
    # When: evaluating without argument
    run bash -c "echo '4+7' | '$SCRIPT'"

    # Then: output should be 11
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11" ]]
}

@test "stdin input with flag: echo 100/3 | bash-calc-eval -i outputs 33" {
    # Given: an expression via stdin with integer flag
    # When: evaluating with -i flag
    run bash -c "echo '100/3' | '$SCRIPT' -i"

    # Then: output should be 33
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33" ]]
}

@test "stdin with complex expression: echo (2+3)*4 via stdin" {
    # Given: a complex expression via stdin
    # When: evaluating
    run bash -c "echo '(2+3)*4' | '$SCRIPT'"

    # Then: output should be 20
    [[ "$status" -eq 0 ]]
    [[ "$output" == "20" ]]
}

# =============================================================================
# Behavior: Error Cases
# =============================================================================

@test "error: -f with bitwise AND should fail" {
    # Given: a bitwise expression with explicit float mode
    # When: evaluating with -f flag
    run "$SCRIPT" -f '255 & 240'

    # Then: should exit non-zero with error message
    [[ "$status" -ne 0 ]]
    [[ "$output" =~ [Ee]rror ]] || [[ "$output" =~ [Bb]itwise ]] || [[ "$output" =~ [Ii]nteger ]]
}

@test "error: -f with bitwise OR should fail" {
    # Given: a bitwise OR expression with float mode
    # When: evaluating with -f flag
    run "$SCRIPT" -f '240 | 15'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error: -f with bitwise NOT should fail" {
    # Given: a bitwise NOT expression with float mode
    # When: evaluating with -f flag
    run "$SCRIPT" -f '~0'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error: -f with bitwise shift should fail" {
    # Given: a bitwise shift expression with float mode
    # When: evaluating with -f flag
    run "$SCRIPT" -f '1 << 8'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error: -f with xor should fail" {
    # Given: an xor expression with float mode
    # When: evaluating with -f flag
    run "$SCRIPT" -f '255 xor 15'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error or warning: -p with -i should error or warn" {
    # Given: precision flag with integer mode
    # When: evaluating with both -p and -i flags
    run "$SCRIPT" -i -p 2 '100/3'

    # Then: should either error (non-zero) or produce integer output
    # The spec says "error or warn" so we accept either:
    # - Non-zero exit (error)
    # - Output of 33 (warning issued, precision ignored)
    if [[ "$status" -eq 0 ]]; then
        [[ "$output" == "33" ]]
    else
        [[ "$status" -ne 0 ]]
    fi
}

@test "error: division by zero" {
    # Given: a division by zero expression
    # When: evaluating the expression
    run "$SCRIPT" '10/0'

    # Then: should exit non-zero with error
    [[ "$status" -ne 0 ]]
}

@test "error: invalid expression syntax" {
    # Given: an invalid expression
    # When: evaluating
    run "$SCRIPT" '2++3'

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "error: unbalanced parentheses" {
    # Given: an expression with unbalanced parentheses
    # When: evaluating
    run "$SCRIPT" '(2+3'

    # Then: should exit non-zero
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
# Behavior: Operator Precedence
# =============================================================================

@test "precedence: 2+3*4 outputs 14 (multiplication before addition)" {
    # Given: an expression testing precedence
    # When: evaluating without parentheses
    run "$SCRIPT" '2+3*4'

    # Then: output should be 14 (not 20)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "14" ]]
}

@test "precedence: 10-6/2 outputs 7 (division before subtraction)" {
    # Given: an expression testing precedence
    # When: evaluating without parentheses
    run "$SCRIPT" '10-6/2'

    # Then: output should be 7 (not 2)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "7" ]]
}

@test "precedence: 2^3*2 outputs 16 (power before multiplication)" {
    # Given: an expression with power and multiplication
    # When: evaluating
    run "$SCRIPT" '2^3*2'

    # Then: output should be 16 (2^3=8, 8*2=16)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "16" ]]
}

# =============================================================================
# Behavior: Negative Numbers
# =============================================================================

@test "negative number: -5+10 outputs 5" {
    # Given: an expression with a negative number
    # When: evaluating
    run "$SCRIPT" '-5+10'

    # Then: output should be 5
    [[ "$status" -eq 0 ]]
    [[ "$output" == "5" ]]
}

@test "negative result: 5-10 outputs -5" {
    # Given: an expression resulting in a negative number
    # When: evaluating
    run "$SCRIPT" '5-10'

    # Then: output should be -5
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-5" ]]
}

@test "negative multiplication: -3*4 outputs -12" {
    # Given: an expression with negative multiplication
    # When: evaluating
    run "$SCRIPT" '-3*4'

    # Then: output should be -12
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-12" ]]
}

@test "negative division float: -100/3 outputs -33.333333" {
    # Given: a negative division in float mode
    # When: evaluating
    run "$SCRIPT" '-100/3'

    # Then: output should be -33.333333
    [[ "$status" -eq 0 ]]
    [[ "$output" == "-33.333333" ]]
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

@test "zero multiplication: 1000*0 outputs 0" {
    # Given: multiplication by zero
    # When: evaluating
    run "$SCRIPT" '1000*0'

    # Then: output should be 0
    [[ "$status" -eq 0 ]]
    [[ "$output" == "0" ]]
}

@test "power of zero: 0^5 outputs 0" {
    # Given: zero raised to a power
    # When: evaluating
    run "$SCRIPT" '0^5'

    # Then: output should be 0
    [[ "$status" -eq 0 ]]
    [[ "$output" == "0" ]]
}

@test "anything to power zero: 5^0 outputs 1" {
    # Given: a number raised to zero
    # When: evaluating
    run "$SCRIPT" '5^0'

    # Then: output should be 1
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1" ]]
}

@test "one handling: 1*1 outputs 1" {
    # Given: multiplication of ones
    # When: evaluating
    run "$SCRIPT" '1*1'

    # Then: output should be 1
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1" ]]
}

@test "large numbers: 1000000*1000 outputs 1000000000" {
    # Given: large number multiplication
    # When: evaluating
    run "$SCRIPT" '1000000*1000'

    # Then: output should be 1000000000
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1000000000" ]]
}

# =============================================================================
# Behavior: Whitespace Handling
# =============================================================================

@test "spaces around operators: 4 + 7 outputs 11" {
    # Given: an expression with spaces
    # When: evaluating
    run "$SCRIPT" '4 + 7'

    # Then: output should be 11
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11" ]]
}

@test "no spaces: 4+7 outputs 11" {
    # Given: an expression without spaces
    # When: evaluating
    run "$SCRIPT" '4+7'

    # Then: output should be 11
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11" ]]
}

@test "mixed spacing: 4+ 7 outputs 11" {
    # Given: an expression with inconsistent spacing
    # When: evaluating
    run "$SCRIPT" '4+ 7'

    # Then: output should be 11
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11" ]]
}

# =============================================================================
# Behavior: Flag Order Flexibility
# =============================================================================

@test "expression before flag: 100/3 -i outputs 33" {
    # Given: expression provided before flag
    # When: evaluating
    run "$SCRIPT" '100/3' -i

    # Then: output should be 33
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33" ]]
}

@test "multiple flags: -f -p 4 100/3 outputs 33.3333" {
    # Given: multiple flags specified
    # When: evaluating
    run "$SCRIPT" -f -p 4 '100/3'

    # Then: output should be 33.3333
    [[ "$status" -eq 0 ]]
    [[ "$output" == "33.3333" ]]
}

# =============================================================================
# Behavior: Complex Expressions
# =============================================================================

@test "complex arithmetic: 2+3*4-10/2 outputs 9" {
    # Given: a complex arithmetic expression
    # When: evaluating (3*4=12, 10/2=5, 2+12-5=9)
    run "$SCRIPT" '2+3*4-10/2'

    # Then: output should be 9
    [[ "$status" -eq 0 ]]
    [[ "$output" == "9" ]]
}

@test "complex with parentheses: ((10+5)*2)^2/5 outputs 180" {
    # Given: a complex expression with parentheses and power
    # When: evaluating ((15)*2)^2/5 = 30^2/5 = 900/5 = 180
    run "$SCRIPT" '((10+5)*2)^2/5'

    # Then: output should be 180
    [[ "$status" -eq 0 ]]
    [[ "$output" == "180" ]]
}

@test "complex bitwise: (0xff & 0xf0) | 0x0f outputs 255" {
    # Given: a complex bitwise expression
    # When: evaluating (255 & 240) | 15 = 240 | 15 = 255
    run "$SCRIPT" '(0xff & 0xf0) | 0x0f'

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "complex with xor: (255 xor 15) & 0xf0 outputs 240" {
    # Given: a complex expression with xor
    # When: evaluating (255 xor 15) & 240 = 240 & 240 = 240
    run "$SCRIPT" '(255 xor 15) & 0xf0'

    # Then: output should be 240
    [[ "$status" -eq 0 ]]
    [[ "$output" == "240" ]]
}

# =============================================================================
# Behavior: Integer Mode with Various Operations
# =============================================================================

@test "integer mode addition: -i 4+7 outputs 11" {
    # Given: addition in integer mode
    # When: evaluating
    run "$SCRIPT" -i '4+7'

    # Then: output should be 11
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11" ]]
}

@test "integer mode with bitwise: -i 255 & 240 outputs 240" {
    # Given: bitwise operation in explicit integer mode
    # When: evaluating
    run "$SCRIPT" -i '255 & 240'

    # Then: output should be 240
    [[ "$status" -eq 0 ]]
    [[ "$output" == "240" ]]
}

@test "integer mode modulo: -i 17%5 outputs 2" {
    # Given: modulo in integer mode
    # When: evaluating
    run "$SCRIPT" -i '17%5'

    # Then: output should be 2
    [[ "$status" -eq 0 ]]
    [[ "$output" == "2" ]]
}

# =============================================================================
# Behavior: Idempotency and Consistency
# =============================================================================

@test "consistent results: same expression produces same output" {
    # Given: the same expression evaluated twice
    # When: running the calculation
    run "$SCRIPT" '2^10'
    local first="$output"

    run "$SCRIPT" '2^10'
    local second="$output"

    # Then: both results should be identical
    [[ "$first" == "$second" ]]
    [[ "$first" == "1024" ]]
}

@test "expression via stdin matches argument" {
    # Given: the same expression via stdin and argument
    # When: evaluating both ways
    run "$SCRIPT" '(2+3)*4'
    local arg_result="$output"

    run bash -c "echo '(2+3)*4' | '$SCRIPT'"
    local stdin_result="$output"

    # Then: both results should be identical
    [[ "$arg_result" == "$stdin_result" ]]
    [[ "$arg_result" == "20" ]]
}
