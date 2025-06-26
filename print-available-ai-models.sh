#!/bin/bash
set -e
set -o pipefail

if ! command -v curl &> /dev/null; then
    echo "Error: curl is not installed. Please install it." >&2
    exit 1
fi
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install it (e.g., 'sudo apt install jq' or 'brew install jq')." >&2
    exit 1
fi

# --- Fetch OpenAI Models ---
openai_models=""
if [[ -n "$OPENAI_API_KEY" ]]; then
    echo "Fetching OpenAI models..." >&2
    # Use v1/models endpoint
    openai_response=$(curl --silent --show-error -X GET "https://api.openai.com/v1/models" \
      -H "Authorization: Bearer $OPENAI_API_KEY")

    # Check if curl command was successful and response is valid JSON
    if [[ $? -eq 0 ]] && jq -e . >/dev/null 2>&1 <<<"$openai_response"; then
        openai_models=$(echo "$openai_response" | jq -r '.data[] | .id' | sort)
    else
        echo "Warning: Failed to fetch or parse OpenAI models. Check API key or network." >&2
        # Optionally add specific error details from openai_response if it contains error messages
        # echo "OpenAI Response: $openai_response" >&2
    fi
else
    echo "Info: OPENAI_API_KEY not set. Skipping OpenAI models." >&2
fi

# --- Fetch Google AI Models ---
googleai_models=""
if [[ -n "$GOOGLEAI_API_KEY" ]]; then
    echo "Fetching Google AI models..." >&2
    # Use v1beta/models endpoint
    googleai_response=$(curl --silent --show-error -H 'Content-Type: application/json' \
        "https://generativelanguage.googleapis.com/v1beta/models?key=${GOOGLEAI_API_KEY}")

    # Check if curl command was successful and response is valid JSON
    if [[ $? -eq 0 ]] && jq -e . >/dev/null 2>&1 <<<"$googleai_response"; then
        # Filter for models supporting 'generateContent' and extract name (remove 'models/')
        googleai_models=$(echo "$googleai_response" | jq -r '.models[] | select(.supportedGenerationMethods[] | contains("generateContent")) | .name' | sed 's/^models\///' | sort)
    else
        echo "Warning: Failed to fetch or parse Google AI models. Check API key or network." >&2
    fi
else
    echo "Info: GOOGLEAI_API_KEY not set. Skipping GoogleAI models." >&2
fi

# --- Fetch Anthropic Models ---
anthropic_models=""
if [[ -n "$ANTHROPIC_API_KEY" ]]; then
    echo "Fetching Anthropic models..." >&2
    anthropic_response=$(curl --silent --show-error "https://api.anthropic.com/v1/models" \
         --header "x-api-key: $ANTHROPIC_API_KEY" \
         --header "anthropic-version: 2023-06-01")

    # Check if curl command was successful and response is valid JSON
    if [[ $? -eq 0 ]] && jq -e . >/dev/null 2>&1 <<<"$anthropic_response"; then
        anthropic_models=$(echo "$anthropic_response" | jq -r '.data[].id' | sort)
    else
        echo "Warning: Failed to fetch or parse Anthropic models. Check API key or network." >&2
        # echo "Anthropic Response: $anthropic_response" >&2
    fi
else
    echo "Info: ANTHROPIC_API_KEY not set. Skipping Anthropic models." >&2
fi


# --- Display Models ---
echo # Add a newline for better separation

# Print header
printf "%-40s %-40s %-40s\n" "OpenAI Models" "GoogleAI Models" "Anthropic Models"
printf "%-40s %-40s %-40s\n" "----------------------------------------" "----------------------------------------" "----------------------------------------"

# Use paste to combine the model lists side-by-side
# Process substitution <(...) is used to treat the command output as a file
paste <(echo "$openai_models") <(echo "$googleai_models") <(echo "$anthropic_models") | while IFS=$'\t' read -r openai googleai anthropic; do
  printf "%-40s %-40s %-40s\n" "$openai" "$googleai" "$anthropic"
done

echo # Add a final newline

exit 0

