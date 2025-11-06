#!/bin/bash
# Test script for Ethereum operator address validation
# This script tests the validation helper function that ensures operator addresses
# are properly formatted to prevent deployment failures.

set -e

CHART_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILURES=0
TESTS_RUN=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "======================================"
echo "Testing Operator Address Validation"
echo "======================================"
echo ""

# Helper function to run a test
run_test() {
    local test_name="$1"
    local address="$2"
    local should_pass="$3"
    local expected_error="$4"

    TESTS_RUN=$((TESTS_RUN + 1))

    # Run helm template and capture both stdout and stderr
    local output
    local exit_code
    output=$(helm template test-validation "$CHART_PATH" \
        --set charon.operatorAddress="$address" \
        --set charon.beaconNodeEndpoints[0]=http://beacon:5051 \
        2>&1) || exit_code=$?

    if [ "$should_pass" = "true" ]; then
        if [ -z "$exit_code" ]; then
            echo -e "${GREEN}✓${NC} PASS: $test_name"
            echo "   Address: $address"
        else
            echo -e "${RED}✗${NC} FAIL: $test_name"
            echo "   Address: $address"
            echo "   Expected: Success"
            echo "   Got: Validation error"
            echo "   Output: $output"
            FAILURES=$((FAILURES + 1))
        fi
    else
        if [ -n "$exit_code" ]; then
            # Check if the error message contains the expected error
            if echo "$output" | grep -q "$expected_error"; then
                echo -e "${GREEN}✓${NC} PASS: $test_name"
                echo "   Address: $address"
                echo "   Expected error: $expected_error"
            else
                echo -e "${RED}✗${NC} FAIL: $test_name"
                echo "   Address: $address"
                echo "   Expected error containing: $expected_error"
                echo "   Got: $output"
                FAILURES=$((FAILURES + 1))
            fi
        else
            echo -e "${RED}✗${NC} FAIL: $test_name"
            echo "   Address: $address"
            echo "   Expected: Validation error"
            echo "   Got: Success (should have failed)"
            FAILURES=$((FAILURES + 1))
        fi
    fi
    echo ""
}

echo "=== Testing Valid Addresses ==="
echo ""

run_test \
    "Valid checksummed address" \
    "0x3D1f0598943239806A251899016EAf4920d4726d" \
    "true" \
    ""

run_test \
    "Valid lowercase address" \
    "0x3d1f0598943239806a251899016eaf4920d4726d" \
    "true" \
    ""

run_test \
    "Valid uppercase address (after 0x)" \
    "0x3D1F0598943239806A251899016EAF4920D4726D" \
    "true" \
    ""

run_test \
    "Valid mixed case address" \
    "0xaBcDeF1234567890123456789012345678901234" \
    "true" \
    ""

run_test \
    "Valid address with zeros" \
    "0x0000000000000000000000000000000000000000" \
    "true" \
    ""

echo "=== Testing Invalid Addresses ==="
echo ""

run_test \
    "Missing 0x prefix" \
    "3D1f0598943239806A251899016EAf4920d4726d" \
    "false" \
    "must start with '0x'"

run_test \
    "Too short (missing 1 char)" \
    "0x3D1f0598943239806A251899016EAf4920d4726" \
    "false" \
    "must be exactly 42 characters"

run_test \
    "Too long (extra char)" \
    "0x3D1f0598943239806A251899016EAf4920d4726dd" \
    "false" \
    "must be exactly 42 characters"

run_test \
    "Invalid hex character (G)" \
    "0x3D1f0598943239806A251899016EAf4920d4726G" \
    "false" \
    "must contain only hexadecimal characters"

run_test \
    "Invalid hex character (Z)" \
    "0x3D1f0598943239806A251899016EAf4920d472Zd" \
    "false" \
    "must contain only hexadecimal characters"

run_test \
    "Contains space" \
    "0x3D1f0598943239806A25 899016EAf4920d4726d" \
    "false" \
    "must contain only hexadecimal characters"

run_test \
    "Empty after 0x" \
    "0x" \
    "false" \
    "must be exactly 42 characters"

run_test \
    "Only 0x prefix (too short)" \
    "0x123" \
    "false" \
    "must be exactly 42 characters"

echo "======================================"
echo "Test Results"
echo "======================================"
echo "Tests run: $TESTS_RUN"
echo "Failures: $FAILURES"
echo ""

if [ $FAILURES -eq 0 ]; then
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    exit 1
fi
