# Add Anthropic

Currently, the code can display the list of available models from OpenAI and Gemini APIs. We need to add support for Anthropic API.
Given the Anthrpic documentation, the curl command to list the available models is:

```bash
curl https://api.anthropic.com/v1/models \
     --header "x-api-key: $ANTHROPIC_API_KEY" \
     --header "anthropic-version: 2023-06-01"
```

The response is a JSON object like this:

```json
{
  "data": [
    {
      "type": "model",
      "id": "claude-3-7-sonnet-20250219",
      "display_name": "Claude 3.7 Sonnet",
      "created_at": "2025-02-19T00:00:00Z"
    }
  ],
  "has_more": true,
  "first_id": "<string>",
  "last_id": "<string>"
}
```

Tell me how to modify the `./print-available-ai-models.sh` script to add support for the Anthropic API and get the list of available Anthropic models displayed on a 3rd column.



# This is gemini-2.5-pro-exp-03-25 answer (0k in, 2k out)

Okay, here's how you can modify your script to include Anthropic models in a third column.

This revised script assumes your original script fetched OpenAI and Gemini models into variables (e.g., `openai_models` and `gemini_models`). It adds a similar section for Anthropic and then uses `paste` to combine the outputs.

**Modified `print-available-ai-models.sh`:**

```bash
#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Treat unset variables as an error when substituting.
# set -u # Optional: uncomment if you want to ensure all keys are set
# Pipe commands should fail if any command in the pipe fails, not just the last one.
set -o pipefail

# --- Configuration ---
# Ensure API keys are set as environment variables:
# export OPENAI_API_KEY="your_openai_key"
# export GEMINI_API_KEY="your_gemini_key"
# export ANTHROPIC_API_KEY="your_anthropic_key"

# --- Check Dependencies ---
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

# --- Fetch Gemini Models ---
gemini_models=""
if [[ -n "$GEMINI_API_KEY" ]]; then
    echo "Fetching Gemini models..." >&2
    # Use v1beta/models endpoint
    gemini_response=$(curl --silent --show-error -H 'Content-Type: application/json' \
        "https://generativelanguage.googleapis.com/v1beta/models?key=${GEMINI_API_KEY}")

    # Check if curl command was successful and response is valid JSON
    if [[ $? -eq 0 ]] && jq -e . >/dev/null 2>&1 <<<"$gemini_response"; then
        # Filter for models supporting 'generateContent' and extract name (remove 'models/')
        gemini_models=$(echo "$gemini_response" | jq -r '.models[] | select(.supportedGenerationMethods[] | contains("generateContent")) | .name' | sed 's/^models\///' | sort)
    else
        echo "Warning: Failed to fetch or parse Gemini models. Check API key or network." >&2
        # echo "Gemini Response: $gemini_response" >&2
    fi
else
    echo "Info: GEMINI_API_KEY not set. Skipping Gemini models." >&2
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
printf "%-40s %-40s %-40s\n" "OpenAI Models" "Gemini Models" "Anthropic Models"
printf "%-40s %-40s %-40s\n" "----------------------------------------" "----------------------------------------" "----------------------------------------"

# Use paste to combine the model lists side-by-side
# Process substitution <(...) is used to treat the command output as a file
paste <(echo "$openai_models") <(echo "$gemini_models") <(echo "$anthropic_models") | while IFS=$'\t' read -r openai gemini anthropic; do
  printf "%-40s %-40s %-40s\n" "$openai" "$gemini" "$anthropic"
done

echo # Add a final newline

exit 0
```

**Explanation of Changes:**

1.  **Anthropic API Key Check:** Added a check `if [[ -n "$ANTHROPIC_API_KEY" ]]; then ... fi` to only attempt fetching Anthropic models if the `ANTHROPIC_API_KEY` environment variable is set.
2.  **Fetch Anthropic Models Section:**
    *   A new section similar to the OpenAI and Gemini ones was added.
    *   It uses the `curl` command provided in the Anthropic documentation.
    *   `--silent` is added to `curl` for cleaner script output. `--show-error` is added to show curl errors if `--silent` is used.
    *   It includes basic error checking for the `curl` command and JSON parsing using `jq -e`.
    *   `jq -r '.data[].id'` extracts the model IDs from the `data` array in the JSON response.
    *   The extracted models are sorted and stored in the `anthropic_models` variable.
3.  **Modified Display Section:**
    *   The `printf` commands for the header and separator line were updated to include a third column for "Anthropic Models". The `%-40s` format specifier ensures each column is left-aligned and padded to a width of 40 characters. Adjust the width `40` if needed.
    *   The core change is the use of `paste <(echo "$openai_models") <(echo "$gemini_models") <(echo "$anthropic_models")`.
        *   `paste` merges lines from files (or file-like inputs) side-by-side, separated by tabs by default.
        *   `<(echo "$variable")` is process substitution. It runs `echo "$variable"` and makes its output available as if it were a file, which `paste` can then read line by line.
    *   The output of `paste` is piped to a `while read` loop.
        *   `IFS=$'\t'` sets the Internal Field Separator to a tab, so `read` correctly splits the line provided by `paste` into the three variables (`openai`, `gemini`, `anthropic`).
        *   `printf "%-40s %-40s %-40s\n" "$openai" "$gemini" "$anthropic"` formats and prints each row with aligned columns. This loop handles cases where one list is longer than the others more gracefully than just `paste` alone (though `paste` handles it, the formatting loop ensures consistent padding).

**How to Use:**

1.  **Save:** Save the code above as `./print-available-ai-models.sh`.
2.  **Make Executable:** Run `chmod +x ./print-available-ai-models.sh`.
3.  **Set API Keys:** Make sure you have exported your API keys as environment variables:
    ```bash
    export OPENAI_API_KEY="your_openai_key"
    export GEMINI_API_KEY="your_gemini_key"
    export ANTHROPIC_API_KEY="your_anthropic_key"
    ```
    *(Replace `"your_..._key"` with your actual keys)*. You can add these lines to your `.bashrc` or `.zshrc` for persistence, or just run them in your current terminal session.
4.  **Run:** Execute the script: `./print-available-ai-models.sh`.

The script will now fetch models from all three providers (if their respective API keys are set) and display them in three neat columns.
