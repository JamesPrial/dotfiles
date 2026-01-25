#!/usr/bin/env bats
# Behavior-Driven Tests for actions-fails
#
# This script checks GitHub Actions for failed runs across configured repos.
# Tests are designed from specification, NOT implementation.

# =============================================================================
# Test Setup and Helpers
# =============================================================================

setup() {
    # Path to script under test
    SCRIPT="$BATS_TEST_DIRNAME/../actions-fails"

    # Default config path
    DEFAULT_CONFIG="$BATS_TEST_DIRNAME/../repos.yaml"

    # Create temp directory for test fixtures
    TEST_TEMP_DIR="$(mktemp -d)"
}

teardown() {
    # Clean up temp directory
    if [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# =============================================================================
# Behavior: Script Existence and Executability
# =============================================================================

@test "actions-fails script exists" {
    # Given: the claudescripts directory structure
    # When: we check for the script
    # Then: the file should exist
    [[ -f "$SCRIPT" ]]
}

@test "actions-fails script is executable" {
    # Given: the script file exists
    # When: we check its permissions
    # Then: it should have execute permission
    [[ -x "$SCRIPT" ]]
}

# =============================================================================
# Behavior: Configuration File Handling
# =============================================================================

@test "repos.yaml config file exists at default location" {
    # Given: the claudescripts directory structure
    # When: we check for the config file
    # Then: repos.yaml should exist
    [[ -f "$DEFAULT_CONFIG" ]]
}

@test "exits non-zero when config file is missing" {
    # Given: ACTIONS_FAILS_CONFIG points to a non-existent file
    local nonexistent_config="$TEST_TEMP_DIR/does-not-exist.yaml"

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$nonexistent_config" "$SCRIPT"

    # Then: it should exit with a non-zero status
    [[ "$status" -ne 0 ]]
}

@test "outputs error message when config file is missing" {
    # Given: ACTIONS_FAILS_CONFIG points to a non-existent file
    local nonexistent_config="$TEST_TEMP_DIR/does-not-exist.yaml"

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$nonexistent_config" "$SCRIPT"

    # Then: stderr or stdout should contain an error message about the config
    # (We check combined output since error could go to either stream)
    [[ "$output" =~ config ]] || [[ "$output" =~ Config ]] || \
    [[ "$output" =~ not\ found ]] || [[ "$output" =~ missing ]] || \
    [[ "$output" =~ does\ not\ exist ]] || [[ "$output" =~ "No such file" ]]
}

@test "uses ACTIONS_FAILS_CONFIG env var when set" {
    # Given: a valid config file at a custom location
    local custom_config="$TEST_TEMP_DIR/custom-repos.yaml"
    cat > "$custom_config" << 'EOF'
repos: []
EOF

    # When: the script is executed with ACTIONS_FAILS_CONFIG set
    run env ACTIONS_FAILS_CONFIG="$custom_config" "$SCRIPT"

    # Then: it should succeed (exit 0) since config exists
    # Note: Empty repos array should still produce valid output
    [[ "$status" -eq 0 ]]
}

# =============================================================================
# Behavior: Output Format - Valid JSON
# =============================================================================

@test "output is valid JSON" {
    # Given: a valid config with empty repos (to avoid network calls in basic test)
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: output should be valid JSON
    [[ "$status" -eq 0 ]]
    echo "$output" | jq . > /dev/null 2>&1
}

@test "output JSON has 'timestamp' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: JSON should have a timestamp key
    [[ "$status" -eq 0 ]]
    local has_timestamp
    has_timestamp=$(echo "$output" | jq 'has("timestamp")')
    [[ "$has_timestamp" == "true" ]]
}

@test "output JSON has 'failures' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: JSON should have a failures key
    [[ "$status" -eq 0 ]]
    local has_failures
    has_failures=$(echo "$output" | jq 'has("failures")')
    [[ "$has_failures" == "true" ]]
}

@test "output JSON has 'summary' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: JSON should have a summary key
    [[ "$status" -eq 0 ]]
    local has_summary
    has_summary=$(echo "$output" | jq 'has("summary")')
    [[ "$has_summary" == "true" ]]
}

@test "failures is an array" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: failures should be an array
    [[ "$status" -eq 0 ]]
    local is_array
    is_array=$(echo "$output" | jq '.failures | type == "array"')
    [[ "$is_array" == "true" ]]
}

# =============================================================================
# Behavior: Summary Structure
# =============================================================================

@test "summary has 'total_repos' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should have total_repos
    [[ "$status" -eq 0 ]]
    local has_key
    has_key=$(echo "$output" | jq '.summary | has("total_repos")')
    [[ "$has_key" == "true" ]]
}

@test "summary has 'repos_with_failures' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should have repos_with_failures
    [[ "$status" -eq 0 ]]
    local has_key
    has_key=$(echo "$output" | jq '.summary | has("repos_with_failures")')
    [[ "$has_key" == "true" ]]
}

@test "summary has 'total_failures' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should have total_failures
    [[ "$status" -eq 0 ]]
    local has_key
    has_key=$(echo "$output" | jq '.summary | has("total_failures")')
    [[ "$has_key" == "true" ]]
}

@test "summary values are numbers" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: all summary values should be numbers
    [[ "$status" -eq 0 ]]
    local total_repos_type repos_with_failures_type total_failures_type
    total_repos_type=$(echo "$output" | jq '.summary.total_repos | type')
    repos_with_failures_type=$(echo "$output" | jq '.summary.repos_with_failures | type')
    total_failures_type=$(echo "$output" | jq '.summary.total_failures | type')

    [[ "$total_repos_type" == '"number"' ]]
    [[ "$repos_with_failures_type" == '"number"' ]]
    [[ "$total_failures_type" == '"number"' ]]
}

# =============================================================================
# Behavior: Timestamp Format
# =============================================================================

@test "timestamp is in ISO-8601 format" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: timestamp should match ISO-8601 pattern (YYYY-MM-DDTHH:MM:SSZ or with timezone)
    [[ "$status" -eq 0 ]]
    local timestamp
    timestamp=$(echo "$output" | jq -r '.timestamp')

    # ISO-8601 patterns: 2024-01-15T10:30:00Z or 2024-01-15T10:30:00+00:00
    [[ "$timestamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2} ]]
}

# =============================================================================
# Behavior: Empty Repos Array
# =============================================================================

@test "empty repos array produces zero counts in summary" {
    # Given: a config with empty repos array
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should show zeros
    [[ "$status" -eq 0 ]]
    local total_repos repos_with_failures total_failures
    total_repos=$(echo "$output" | jq '.summary.total_repos')
    repos_with_failures=$(echo "$output" | jq '.summary.repos_with_failures')
    total_failures=$(echo "$output" | jq '.summary.total_failures')

    [[ "$total_repos" -eq 0 ]]
    [[ "$repos_with_failures" -eq 0 ]]
    [[ "$total_failures" -eq 0 ]]
}

@test "empty repos array produces empty failures array" {
    # Given: a config with empty repos array
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_FAILS_CONFIG="$test_config" "$SCRIPT"

    # Then: failures array should be empty
    [[ "$status" -eq 0 ]]
    local failures_count
    failures_count=$(echo "$output" | jq '.failures | length')
    [[ "$failures_count" -eq 0 ]]
}
