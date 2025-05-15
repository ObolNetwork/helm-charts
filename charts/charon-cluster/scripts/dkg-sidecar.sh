#!/bin/sh
set -e

# Script to poll the Obol API for a cluster definition where this pod's ENR is registered
# by the specified operator address and all operators have signed the definition.
# Once found and validated, it runs DKG.

OPERATOR_ADDRESS="$1"
ENR_FILE_PATH="$2"
OUTPUT_FILE_DEFINITION="/charon-data/cluster-definition.json"
# Ensure API_ENDPOINT_BASE uses the dkgSidecar values path
API_ENDPOINT_BASE="{{ .Values.charon.dkgSidecar.apiEndpoint }}/v1/definition/operator/${OPERATOR_ADDRESS}"
INITIAL_RETRY_DELAY={{ .Values.charon.dkgSidecar.initialRetryDelaySeconds }}
MAX_RETRY_DELAY={{ .Values.charon.dkgSidecar.maxRetryDelaySeconds }}
RETRY_DELAY_FACTOR={{ .Values.charon.dkgSidecar.retryDelayFactor }}
PAGE_LIMIT={{ .Values.charon.dkgSidecar.pageLimit }}

echo "DKG Sidecar Script: Starting..."
echo "Operator Address: $OPERATOR_ADDRESS"
echo "ENR File Path: $ENR_FILE_PATH"
echo "Output Definition File: $OUTPUT_FILE_DEFINITION"
echo "API Endpoint Base: $API_ENDPOINT_BASE"
echo "Initial Retry Delay: $INITIAL_RETRY_DELAY seconds"
echo "Max Retry Delay: $MAX_RETRY_DELAY seconds"
echo "Retry Delay Factor: $RETRY_DELAY_FACTOR"
echo "Page Limit: $PAGE_LIMIT"

if [ -z "$OPERATOR_ADDRESS" ] || [ "$OPERATOR_ADDRESS" = "null" ]; then
  echo "ERROR: Operator address is not set or is invalid. Please set .Values.charon.operatorAddress"
  exit 1
fi

if [ ! -f "$ENR_FILE_PATH" ]; then
  echo "ERROR: ENR file $ENR_FILE_PATH not found."
  exit 1
fi
POD_ENR=$(cat "$ENR_FILE_PATH" | tr -d '[:space:]') # Read and trim whitespace
if [ -z "$POD_ENR" ]; then
  echo "ERROR: ENR file $ENR_FILE_PATH is empty."
  exit 1
fi
echo "Pod ENR to find: $POD_ENR"

CURRENT_RETRY_DELAY=$INITIAL_RETRY_DELAY

while true; do
  echo "Starting new polling cycle... (current delay before next cycle: ${CURRENT_RETRY_DELAY}s)"
  POLLING_SUCCESSFUL_THIS_ATTEMPT=false

  CURRENT_PAGE=1
  while true; do 
    API_URL="${API_ENDPOINT_BASE}?page=${CURRENT_PAGE}&limit=${PAGE_LIMIT}"
    echo "Polling API: $API_URL"

    RESPONSE=$(wget -qO- --header="Accept: application/json" --timeout=15 --tries=3 "$API_URL")
    WGET_EXIT_CODE=$?

    if [ $WGET_EXIT_CODE -ne 0 ]; then
      echo "Warning: wget command failed on page $CURRENT_PAGE with exit code $WGET_EXIT_CODE for API call to $API_URL."
      break 
    fi

    if [ -z "$RESPONSE" ]; then
        echo "Warning: Empty response from API: $API_URL (Page $CURRENT_PAGE)."
        break 
    fi
    
    if ! echo "$RESPONSE" | jq -e . > /dev/null 2>&1; then
        echo "ERROR: Response from API is not valid JSON (Page $CURRENT_PAGE): $RESPONSE"
        break
    fi

    CANDIDATE_DEFINITION=$(echo "$RESPONSE" | jq --arg op_addr "$OPERATOR_ADDRESS" --arg pod_enr "$POD_ENR" -c \
      '.cluster_definitions[]? | select(.operators[]? | .address == $op_addr and .enr == $pod_enr and (.enr_signature | type == "string" and length > 0) and (.config_signature | type == "string" and length > 0)) | first')
    
    if [ -n "$CANDIDATE_DEFINITION" ] && [ "$CANDIDATE_DEFINITION" != "null" ]; then
      echo "Found candidate definition where our operator ($OPERATOR_ADDRESS) has signed our ENR on page $CURRENT_PAGE."
      echo "$CANDIDATE_DEFINITION" | jq .

      TOTAL_OPERATORS_IN_CANDIDATE=$(echo "$CANDIDATE_DEFINITION" | jq '.operators | length')
      SIGNED_OPERATORS_IN_CANDIDATE=$(echo "$CANDIDATE_DEFINITION" | jq '[.operators[] | select((.enr_signature | type == "string" and length > 0) and (.config_signature | type == "string" and length > 0))] | length')

      echo "Total operators in candidate: $TOTAL_OPERATORS_IN_CANDIDATE, Signed: $SIGNED_OPERATORS_IN_CANDIDATE"

      if [ "$TOTAL_OPERATORS_IN_CANDIDATE" -gt 0 ] && [ "$SIGNED_OPERATORS_IN_CANDIDATE" -eq "$TOTAL_OPERATORS_IN_CANDIDATE" ]; then
        echo "All $TOTAL_OPERATORS_IN_CANDIDATE operators have signed. Definition ready for DKG!"
        mkdir -p "$(dirname "$OUTPUT_FILE_DEFINITION")"
        echo "$CANDIDATE_DEFINITION" > "$OUTPUT_FILE_DEFINITION"
        echo "Fully signed cluster definition saved to $OUTPUT_FILE_DEFINITION."

        echo "Proceeding to DKG process..."
        if charon dkg --definition-file="$OUTPUT_FILE_DEFINITION" --data-dir=/charon-data; then
          echo "DKG process completed successfully."
          echo "DKG Sidecar Script: Orchestration complete."
          exit 0 
        else
          DKG_EXIT_CODE=$?
          echo "ERROR: DKG process failed with exit code $DKG_EXIT_CODE."
          rm -f "$OUTPUT_FILE_DEFINITION"
          echo "Removed $OUTPUT_FILE_DEFINITION. Will retry entire process."
          POLLING_SUCCESSFUL_THIS_ATTEMPT=false 
          break 2 
        fi
      else
        echo "Not all operators in candidate have signed. Continuing search or will retry."
      fi
    fi 

    HAS_MORE_PAGES=$(echo "$RESPONSE" | jq '.has_next_page // false')
    if [ "$HAS_MORE_PAGES" = "true" ]; then
      echo "No fully signed definition found for us on page $CURRENT_PAGE. Proceeding to next page."
      CURRENT_PAGE=$((CURRENT_PAGE + 1))
    else
      echo "No fully signed definition for us found on page $CURRENT_PAGE, and no more pages available in this API response batch."
      break 
    fi
  done 
  
  # If loop completes without exiting (DKG success or fatal error), it means we didn't find a fully signed def or DKG failed. Sleep and retry.
  echo "Polling cycle complete. Retrying in $CURRENT_RETRY_DELAY seconds..."
  sleep "$CURRENT_RETRY_DELAY"

  # Apply backoff for the next cycle
  NEW_DELAY=$(echo "$CURRENT_RETRY_DELAY * $RETRY_DELAY_FACTOR" | bc)
  # bc might output float, ensure it's integer for sleep & comparison
  NEW_DELAY_INT=$(printf "%.0f" "$NEW_DELAY")

  if [ "$NEW_DELAY_INT" -gt "$MAX_RETRY_DELAY" ]; then
    CURRENT_RETRY_DELAY=$MAX_RETRY_DELAY
  else
    CURRENT_RETRY_DELAY=$NEW_DELAY_INT
  fi
done 

# Script should now only exit on explicit 'exit 0' after successful DKG, or 'exit 1' for early fatal errors (e.g., no ENR, bad operator address).