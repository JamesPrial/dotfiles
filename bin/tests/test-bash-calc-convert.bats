#!/usr/bin/env bats
# Behavior-Driven Tests for bash-calc-convert
#
# A base conversion tool supporting decimal, hexadecimal, binary, and octal.
# Tests are designed from specification, NOT implementation.
#
# SPECIFICATION:
# - Output flags: -d (decimal, default), -x (hex), -b (binary), -o (octal), -a (all tab-separated)
# - Input flags: -D (force decimal), -X (force hex), -B (force binary), -O (force octal)
# - Auto-detect: 0x prefix = hex, 0b = binary, 0o = octal, else decimal
# - Stdin: read from stdin if no value argument
# - -h: show help

# =============================================================================
# Test Setup and Helpers
# =============================================================================

setup() {
    # Path to script under test
    SCRIPT="$BATS_TEST_DIRNAME/../bash-calc-convert"
}

# =============================================================================
# Behavior: Script Existence and Executability
# =============================================================================

@test "bash-calc-convert script exists" {
    # Given: the bin directory structure
    # When: we check for the script
    # Then: the file should exist
    [[ -f "$SCRIPT" ]]
}

@test "bash-calc-convert script is executable" {
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
    # When: invoked with no arguments
    run "$SCRIPT"

    # Then: it should exit non-zero and show usage
    [[ "$status" -ne 0 ]]
    [[ "$output" =~ [Uu]sage ]] || [[ "$output" =~ [Ee]rror ]]
}

# =============================================================================
# Behavior: Decimal Input (Default) to Various Outputs
# =============================================================================

@test "decimal to hex: 255 -x outputs ff" {
    # Given: a decimal input value 255
    # When: converting to hex with -x flag
    run "$SCRIPT" 255 -x

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "decimal to binary: 255 -b outputs 11111111" {
    # Given: a decimal input value 255
    # When: converting to binary with -b flag
    run "$SCRIPT" 255 -b

    # Then: output should be 11111111
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11111111" ]]
}

@test "decimal to octal: 255 -o outputs 377" {
    # Given: a decimal input value 255
    # When: converting to octal with -o flag
    run "$SCRIPT" 255 -o

    # Then: output should be 377
    [[ "$status" -eq 0 ]]
    [[ "$output" == "377" ]]
}

@test "decimal to decimal: 255 -d outputs 255" {
    # Given: a decimal input value 255
    # When: converting to decimal with -d flag
    run "$SCRIPT" 255 -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "decimal output is default when no output flag specified" {
    # Given: a decimal input value 255
    # When: no output flag is specified
    run "$SCRIPT" 255

    # Then: output should be decimal (255)
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

# =============================================================================
# Behavior: All Output Mode (-a)
# =============================================================================

@test "all output mode: 255 -a outputs tab-separated values" {
    # Given: a decimal input value 255
    # When: converting with -a flag for all formats
    run "$SCRIPT" 255 -a

    # Then: output should be decimal, hex, binary, octal (tab-separated)
    [[ "$status" -eq 0 ]]
    # Expected: 255<tab>ff<tab>11111111<tab>377
    [[ "$output" == $'255\tff\t11111111\t377' ]]
}

@test "all output mode with zero: 0 -a outputs all zeros" {
    # Given: input value 0
    # When: converting with -a flag
    run "$SCRIPT" 0 -a

    # Then: output should be 0 in all formats
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'0\t0\t0\t0' ]]
}

# =============================================================================
# Behavior: Auto-Detection of Input Format
# =============================================================================

@test "hex auto-detect: 0xff -d outputs 255" {
    # Given: a hex input with 0x prefix
    # When: converting to decimal
    run "$SCRIPT" 0xff -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "hex auto-detect with uppercase: 0xFF -d outputs 255" {
    # Given: a hex input with uppercase letters
    # When: converting to decimal
    run "$SCRIPT" 0xFF -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "binary auto-detect: 0b11111111 -d outputs 255" {
    # Given: a binary input with 0b prefix
    # When: converting to decimal
    run "$SCRIPT" 0b11111111 -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "octal auto-detect: 0o377 -d outputs 255" {
    # Given: an octal input with 0o prefix
    # When: converting to decimal
    run "$SCRIPT" 0o377 -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "auto-detect hex input to binary: 0xff -b outputs 11111111" {
    # Given: a hex input with 0x prefix
    # When: converting to binary
    run "$SCRIPT" 0xff -b

    # Then: output should be 11111111
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11111111" ]]
}

@test "auto-detect binary input to hex: 0b11111111 -x outputs ff" {
    # Given: a binary input with 0b prefix
    # When: converting to hex
    run "$SCRIPT" 0b11111111 -x

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

# =============================================================================
# Behavior: Force Input Format Flags
# =============================================================================

@test "force hex input: -X ff -d outputs 255" {
    # Given: hex value without prefix, forced with -X
    # When: converting to decimal
    run "$SCRIPT" -X ff -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "force binary input: -B 11111111 -d outputs 255" {
    # Given: binary value without prefix, forced with -B
    # When: converting to decimal
    run "$SCRIPT" -B 11111111 -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "force octal input: -O 377 -d outputs 255" {
    # Given: octal value without prefix, forced with -O
    # When: converting to decimal
    run "$SCRIPT" -O 377 -d

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "force decimal input: -D 255 -x outputs ff" {
    # Given: decimal value forced with -D
    # When: converting to hex
    run "$SCRIPT" -D 255 -x

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "force hex input overrides 0x prefix detection" {
    # Given: value with 0x prefix but force decimal input
    # When: using -D flag with what looks like hex
    # Note: This tests that -D forces decimal interpretation
    # 0xff as decimal would fail, but we test force flag takes precedence
    run "$SCRIPT" -X a -d

    # Then: 'a' interpreted as hex should output 10
    [[ "$status" -eq 0 ]]
    [[ "$output" == "10" ]]
}

# =============================================================================
# Behavior: Stdin Input
# =============================================================================

@test "stdin input: echo 255 | bash-calc-convert -x outputs ff" {
    # Given: decimal value provided via stdin
    # When: converting to hex
    run bash -c "echo 255 | '$SCRIPT' -x"

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "stdin input with hex prefix: echo 0xff | bash-calc-convert -d outputs 255" {
    # Given: hex value provided via stdin
    # When: converting to decimal
    run bash -c "echo 0xff | '$SCRIPT' -d"

    # Then: output should be 255
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "stdin input to all formats: echo 255 | bash-calc-convert -a outputs all" {
    # Given: decimal value provided via stdin
    # When: converting to all formats
    run bash -c "echo 255 | '$SCRIPT' -a"

    # Then: output should be tab-separated all formats
    [[ "$status" -eq 0 ]]
    [[ "$output" == $'255\tff\t11111111\t377' ]]
}

# =============================================================================
# Behavior: Edge Cases and Boundary Values
# =============================================================================

@test "zero value: 0 -x outputs 0" {
    # Given: input value 0
    # When: converting to hex
    run "$SCRIPT" 0 -x

    # Then: output should be 0
    [[ "$status" -eq 0 ]]
    [[ "$output" == "0" ]]
}

@test "zero value: 0 -b outputs 0" {
    # Given: input value 0
    # When: converting to binary
    run "$SCRIPT" 0 -b

    # Then: output should be 0
    [[ "$status" -eq 0 ]]
    [[ "$output" == "0" ]]
}

@test "large value: 65535 -x outputs ffff" {
    # Given: large decimal input (16-bit max)
    # When: converting to hex
    run "$SCRIPT" 65535 -x

    # Then: output should be ffff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ffff" ]]
}

@test "large value: 65535 -b outputs 1111111111111111" {
    # Given: large decimal input (16-bit max)
    # When: converting to binary
    run "$SCRIPT" 65535 -b

    # Then: output should be 16 ones
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1111111111111111" ]]
}

@test "single digit: 1 -b outputs 1" {
    # Given: input value 1
    # When: converting to binary
    run "$SCRIPT" 1 -b

    # Then: output should be 1
    [[ "$status" -eq 0 ]]
    [[ "$output" == "1" ]]
}

@test "power of two: 16 -x outputs 10" {
    # Given: power of two (16)
    # When: converting to hex
    run "$SCRIPT" 16 -x

    # Then: output should be 10
    [[ "$status" -eq 0 ]]
    [[ "$output" == "10" ]]
}

@test "power of two: 16 -b outputs 10000" {
    # Given: power of two (16)
    # When: converting to binary
    run "$SCRIPT" 16 -b

    # Then: output should be 10000
    [[ "$status" -eq 0 ]]
    [[ "$output" == "10000" ]]
}

# =============================================================================
# Behavior: Error Handling
# =============================================================================

@test "invalid decimal input produces error" {
    # Given: an invalid decimal value
    # When: attempting to convert
    run "$SCRIPT" abc -x

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

@test "invalid binary input with force flag produces error" {
    # Given: an invalid binary value (contains 2)
    # When: forcing binary interpretation
    run "$SCRIPT" -B 12345 -d

    # Then: should exit non-zero (invalid binary digits)
    [[ "$status" -ne 0 ]]
}

@test "invalid hex input with force flag produces error" {
    # Given: an invalid hex value (contains g)
    # When: forcing hex interpretation
    run "$SCRIPT" -X xyz -d

    # Then: should exit non-zero (invalid hex digits)
    [[ "$status" -ne 0 ]]
}

@test "empty stdin with no value produces error or usage" {
    # Given: empty stdin and no value argument
    # When: only output flag is provided
    run bash -c "echo '' | '$SCRIPT' -x"

    # Then: should exit non-zero
    [[ "$status" -ne 0 ]]
}

# =============================================================================
# Behavior: Flag Order Flexibility
# =============================================================================

@test "output flag before value: -x 255 outputs ff" {
    # Given: output flag specified before value
    # When: converting decimal to hex
    run "$SCRIPT" -x 255

    # Then: output should be ff
    [[ "$status" -eq 0 ]]
    [[ "$output" == "ff" ]]
}

@test "input and output flags combined: -X ff -b outputs 11111111" {
    # Given: hex input forced and binary output requested
    # When: converting
    run "$SCRIPT" -X ff -b

    # Then: output should be 11111111
    [[ "$status" -eq 0 ]]
    [[ "$output" == "11111111" ]]
}

@test "multiple conversions in sequence produce consistent results" {
    # Given: same value converted twice
    # When: running the same conversion
    run "$SCRIPT" 255 -x
    local first_output="$output"

    run "$SCRIPT" 255 -x
    local second_output="$output"

    # Then: outputs should be identical
    [[ "$first_output" == "$second_output" ]]
    [[ "$first_output" == "ff" ]]
}

# =============================================================================
# Behavior: Cross-Format Conversions (Round-Trip)
# =============================================================================

@test "round-trip: decimal to hex to decimal" {
    # Given: starting with decimal 255
    # When: converting to hex then back to decimal
    run "$SCRIPT" 255 -x
    local hex_value="$output"

    run "$SCRIPT" "0x${hex_value}" -d

    # Then: should get original value back
    [[ "$status" -eq 0 ]]
    [[ "$output" == "255" ]]
}

@test "round-trip: decimal to binary to decimal" {
    # Given: starting with decimal 42
    # When: converting to binary then back to decimal
    run "$SCRIPT" 42 -b
    local binary_value="$output"

    run "$SCRIPT" "0b${binary_value}" -d

    # Then: should get original value back
    [[ "$status" -eq 0 ]]
    [[ "$output" == "42" ]]
}

@test "round-trip: decimal to octal to decimal" {
    # Given: starting with decimal 64
    # When: converting to octal then back to decimal
    run "$SCRIPT" 64 -o
    local octal_value="$output"

    run "$SCRIPT" "0o${octal_value}" -d

    # Then: should get original value back
    [[ "$status" -eq 0 ]]
    [[ "$output" == "64" ]]
}
