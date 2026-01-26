#!/usr/bin/env bats
# Behavior-Driven Tests for actions-status
#
# This script checks GitHub Actions status across configured repos and outputs JSON.
# Tests are designed from specification, NOT implementation.

# =============================================================================
# Test Setup and Helpers
# =============================================================================

setup() {
    # Path to script under test
    SCRIPT="$BATS_TEST_DIRNAME/../actions-status"

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

# Helper to skip integration tests when not available
skip_if_no_integration() {
    if [[ -n "${SKIP_INTEGRATION:-}" ]]; then
        skip "Integration tests disabled via SKIP_INTEGRATION"
    fi
    if ! gh auth status &>/dev/null 2>&1; then
        skip "GitHub CLI not authenticated"
    fi
}

# =============================================================================
# Behavior: Script Existence and Executability
# =============================================================================

@test "actions-status script exists" {
    # Given: the bin directory structure
    # When: we check for the script
    # Then: the file should exist
    [[ -f "$SCRIPT" ]]
}

@test "actions-status script is executable" {
    # Given: the script file exists
    # When: we check its permissions
    # Then: it should have execute permission
    [[ -x "$SCRIPT" ]]
}

# =============================================================================
# Behavior: Configuration File Handling
# =============================================================================

@test "repos.yaml config file exists at default location" {
    # Given: the bin directory structure
    # When: we check for the config file
    # Then: repos.yaml should exist
    [[ -f "$DEFAULT_CONFIG" ]]
}

@test "exits non-zero when config file is missing" {
    # Given: ACTIONS_STATUS_CONFIG points to a non-existent file
    local nonexistent_config="$TEST_TEMP_DIR/does-not-exist.yaml"

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$nonexistent_config" "$SCRIPT"

    # Then: it should exit with a non-zero status
    [[ "$status" -ne 0 ]]
}

@test "outputs error message when config file is missing" {
    # Given: ACTIONS_STATUS_CONFIG points to a non-existent file
    local nonexistent_config="$TEST_TEMP_DIR/does-not-exist.yaml"

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$nonexistent_config" "$SCRIPT"

    # Then: stderr or stdout should contain an error message about the config
    # (We check combined output since error could go to either stream)
    [[ "$output" =~ config ]] || [[ "$output" =~ Config ]] || \
    [[ "$output" =~ not\ found ]] || [[ "$output" =~ missing ]] || \
    [[ "$output" =~ does\ not\ exist ]] || [[ "$output" =~ "No such file" ]]
}

@test "uses ACTIONS_STATUS_CONFIG env var when set" {
    # Given: a valid config file at a custom location
    local custom_config="$TEST_TEMP_DIR/custom-repos.yaml"
    cat > "$custom_config" << 'EOF'
repos: []
EOF

    # When: the script is executed with ACTIONS_STATUS_CONFIG set
    run env ACTIONS_STATUS_CONFIG="$custom_config" "$SCRIPT"

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
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

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
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: JSON should have a timestamp key
    [[ "$status" -eq 0 ]]
    local has_timestamp
    has_timestamp=$(echo "$output" | jq 'has("timestamp")')
    [[ "$has_timestamp" == "true" ]]
}

@test "output JSON has 'repos' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: JSON should have a repos key
    [[ "$status" -eq 0 ]]
    local has_repos
    has_repos=$(echo "$output" | jq 'has("repos")')
    [[ "$has_repos" == "true" ]]
}

@test "output JSON has 'summary' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: JSON should have a summary key
    [[ "$status" -eq 0 ]]
    local has_summary
    has_summary=$(echo "$output" | jq 'has("summary")')
    [[ "$has_summary" == "true" ]]
}

@test "repos is an array" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: repos should be an array
    [[ "$status" -eq 0 ]]
    local is_array
    is_array=$(echo "$output" | jq '.repos | type == "array"')
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
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should have total_repos
    [[ "$status" -eq 0 ]]
    local has_key
    has_key=$(echo "$output" | jq '.summary | has("total_repos")')
    [[ "$has_key" == "true" ]]
}

@test "summary has 'total_workflows' key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should have total_workflows
    [[ "$status" -eq 0 ]]
    local has_key
    has_key=$(echo "$output" | jq '.summary | has("total_workflows")')
    [[ "$has_key" == "true" ]]
}

@test "summary has 'success' count key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should have success count
    [[ "$status" -eq 0 ]]
    local has_key
    has_key=$(echo "$output" | jq '.summary | has("success")')
    [[ "$has_key" == "true" ]]
}

@test "summary has 'failure' count key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should have failure count
    [[ "$status" -eq 0 ]]
    local has_key
    has_key=$(echo "$output" | jq '.summary | has("failure")')
    [[ "$has_key" == "true" ]]
}

@test "summary has 'in_progress' count key" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should have in_progress count
    [[ "$status" -eq 0 ]]
    local has_key
    has_key=$(echo "$output" | jq '.summary | has("in_progress")')
    [[ "$has_key" == "true" ]]
}

@test "summary values are numbers" {
    # Given: a valid config
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: all summary values should be numbers
    [[ "$status" -eq 0 ]]
    local total_repos_type total_workflows_type success_type failure_type in_progress_type
    total_repos_type=$(echo "$output" | jq '.summary.total_repos | type')
    total_workflows_type=$(echo "$output" | jq '.summary.total_workflows | type')
    success_type=$(echo "$output" | jq '.summary.success | type')
    failure_type=$(echo "$output" | jq '.summary.failure | type')
    in_progress_type=$(echo "$output" | jq '.summary.in_progress | type')

    [[ "$total_repos_type" == '"number"' ]]
    [[ "$total_workflows_type" == '"number"' ]]
    [[ "$success_type" == '"number"' ]]
    [[ "$failure_type" == '"number"' ]]
    [[ "$in_progress_type" == '"number"' ]]
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
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

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
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: summary should show zeros
    [[ "$status" -eq 0 ]]
    local total_repos total_workflows success failure in_progress
    total_repos=$(echo "$output" | jq '.summary.total_repos')
    total_workflows=$(echo "$output" | jq '.summary.total_workflows')
    success=$(echo "$output" | jq '.summary.success')
    failure=$(echo "$output" | jq '.summary.failure')
    in_progress=$(echo "$output" | jq '.summary.in_progress')

    [[ "$total_repos" -eq 0 ]]
    [[ "$total_workflows" -eq 0 ]]
    [[ "$success" -eq 0 ]]
    [[ "$failure" -eq 0 ]]
    [[ "$in_progress" -eq 0 ]]
}

@test "empty repos array produces empty repos array" {
    # Given: a config with empty repos array
    local test_config="$TEST_TEMP_DIR/test-repos.yaml"
    cat > "$test_config" << 'EOF'
repos: []
EOF

    # When: the script is executed
    run env ACTIONS_STATUS_CONFIG="$test_config" "$SCRIPT"

    # Then: repos array should be empty
    [[ "$status" -eq 0 ]]
    local repos_count
    repos_count=$(echo "$output" | jq '.repos | length')
    [[ "$repos_count" -eq 0 ]]
}

# =============================================================================
# Behavior: Integration Tests (require GitHub CLI authentication)
# =============================================================================

# Helper to run script and capture only stdout (stderr may contain warnings)
run_script_stdout_only() {
    local config="$1"
    env ACTIONS_STATUS_CONFIG="$config" "$SCRIPT" 2>/dev/null
}

@test "integration: fetches real repo and produces valid structure" {
    skip_if_no_integration

    # Given: a config with a real repository
    local test_config="$TEST_TEMP_DIR/integration-repos.yaml"
    cat > "$test_config" << 'EOF'
repos:
  - JamesPrial/dotfiles
EOF

    # When: the script is executed (capturing only stdout to avoid stderr warnings)
    local json_output
    json_output=$(run_script_stdout_only "$test_config")
    local exit_status=$?

    # Then: should exit successfully and output valid JSON with expected structure
    [[ "$exit_status" -eq 0 ]]
    echo "$json_output" | jq . > /dev/null 2>&1

    # Verify required top-level keys exist
    local has_timestamp has_repos has_summary
    has_timestamp=$(echo "$json_output" | jq 'has("timestamp")')
    has_repos=$(echo "$json_output" | jq 'has("repos")')
    has_summary=$(echo "$json_output" | jq 'has("summary")')

    [[ "$has_timestamp" == "true" ]]
    [[ "$has_repos" == "true" ]]
    [[ "$has_summary" == "true" ]]
}

@test "integration: workflow objects have required fields" {
    skip_if_no_integration

    # Given: a config with a real repository that has workflows
    local test_config="$TEST_TEMP_DIR/integration-repos.yaml"
    cat > "$test_config" << 'EOF'
repos:
  - JamesPrial/dotfiles
EOF

    # When: the script is executed
    local json_output
    json_output=$(run_script_stdout_only "$test_config")
    local exit_status=$?

    # Then: if there are workflows, they should have required fields
    [[ "$exit_status" -eq 0 ]]

    local workflow_count
    workflow_count=$(echo "$json_output" | jq '[.repos[].workflows[]] | length')

    if [[ "$workflow_count" -gt 0 ]]; then
        # Check first workflow has required fields
        local has_name has_status has_url has_run_id
        has_name=$(echo "$json_output" | jq '.repos[0].workflows[0] | has("name")')
        has_status=$(echo "$json_output" | jq '.repos[0].workflows[0] | has("status")')
        has_url=$(echo "$json_output" | jq '.repos[0].workflows[0] | has("url")')
        has_run_id=$(echo "$json_output" | jq '.repos[0].workflows[0] | has("run_id")')

        [[ "$has_name" == "true" ]]
        [[ "$has_status" == "true" ]]
        [[ "$has_url" == "true" ]]
        [[ "$has_run_id" == "true" ]]
    fi
}

@test "integration: status values are valid" {
    skip_if_no_integration

    # Given: a config with a real repository
    local test_config="$TEST_TEMP_DIR/integration-repos.yaml"
    cat > "$test_config" << 'EOF'
repos:
  - JamesPrial/dotfiles
EOF

    # When: the script is executed
    local json_output
    json_output=$(run_script_stdout_only "$test_config")
    local exit_status=$?

    # Then: all status values should be one of the valid statuses
    [[ "$exit_status" -eq 0 ]]

    local workflow_count
    workflow_count=$(echo "$json_output" | jq '[.repos[].workflows[]] | length')

    if [[ "$workflow_count" -gt 0 ]]; then
        # Extract all unique status values and verify they are valid
        local statuses
        statuses=$(echo "$json_output" | jq -r '[.repos[].workflows[].status] | unique | .[]')

        for s in $statuses; do
            case "$s" in
                success|failure|in_progress|cancelled|skipped)
                    # Valid status
                    ;;
                *)
                    # Invalid status found
                    echo "Invalid status found: $s"
                    return 1
                    ;;
            esac
        done
    fi
}

@test "integration: summary counts match actual data" {
    skip_if_no_integration

    # Given: a config with a real repository
    local test_config="$TEST_TEMP_DIR/integration-repos.yaml"
    cat > "$test_config" << 'EOF'
repos:
  - JamesPrial/dotfiles
EOF

    # When: the script is executed
    local json_output
    json_output=$(run_script_stdout_only "$test_config")
    local exit_status=$?

    # Then: summary counts should match the actual workflow data
    [[ "$exit_status" -eq 0 ]]

    # Count workflows in repos array
    local actual_workflow_count
    actual_workflow_count=$(echo "$json_output" | jq '[.repos[].workflows[]] | length')

    # Get reported total_workflows from summary
    local reported_total
    reported_total=$(echo "$json_output" | jq '.summary.total_workflows')

    [[ "$actual_workflow_count" -eq "$reported_total" ]]

    # Verify status counts add up
    local success failure in_progress cancelled skipped total_counted
    success=$(echo "$json_output" | jq '.summary.success')
    failure=$(echo "$json_output" | jq '.summary.failure')
    in_progress=$(echo "$json_output" | jq '.summary.in_progress')
    cancelled=$(echo "$json_output" | jq '.summary.cancelled // 0')
    skipped=$(echo "$json_output" | jq '.summary.skipped // 0')

    total_counted=$((success + failure + in_progress + cancelled + skipped))

    [[ "$total_counted" -eq "$reported_total" ]]
}
