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



# This is o1-mini answer (0k in, 1k out)

Sure! Below is the updated `./print-available-ai-models.sh` script with added support for the Anthropic API. This script fetches available models from OpenAI, Gemini, and Anthropic APIs and displays them in three separate columns.

### Prerequisites

1. **API Keys**: Ensure you have the necessary API keys for OpenAI, Gemini, and Anthropic set as environment variables:
    ```bash
    export OPENAI_API_KEY="your_openai_api_key"
    export GEMINI_API_KEY="your_gemini_api_key"
    export ANTHROPIC_API_KEY="your_anthropic_api_key"
    ```

2. **`jq` Installation**: This script uses `jq` for JSON parsing. If you don't have `jq` installed, you can install it using:
    - **Ubuntu/Debian**:
        ```bash
        sudo apt-get update
        sudo apt-get install jq
        ```
    - **macOS (using Homebrew)**:
        ```bash
        brew install jq
        ```

### Updated Script: `print-available-ai-models.sh`

```bash
#!/bin/bash

# Ensure API keys are set
if [ -z "$OPENAI_API_KEY" ]; then
    echo "Error: OPENAI_API_KEY is not set."
    exit 1
fi

if [ -z "$GEMINI_API_KEY" ]; then
    echo "Error: GEMINI_API_KEY is not set."
    exit 1
fi

if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "Error: ANTHROPIC_API_KEY is not set."
    exit 1
fi

# Function to fetch OpenAI models
fetch_openai_models() {
    curl -s https://api.openai.com/v1/models \
        -H "Authorization: Bearer $OPENAI_API_KEY" | \
    jq -r '.data[] | .id'
}

# Function to fetch Gemini models
fetch_gemini_models() {
    # Replace the URL and headers with actual Gemini API details
    curl -s https://api.gemini.com/v1/models \
        -H "Authorization: Bearer $GEMINI_API_KEY" | \
    jq -r '.models[] | .name'
}

# Function to fetch Anthropic models
fetch_anthropic_models() {
    curl -s https://api.anthropic.com/v1/models \
        --header "x-api-key: $ANTHROPIC_API_KEY" \
        --header "anthropic-version: 2023-06-01" | \
    jq -r '.data[] | .display_name'
}

# Fetch models from each API
OPENAI_MODELS=($(fetch_openai_models))
GEMINI_MODELS=($(fetch_gemini_models))
ANTHROPIC_MODELS=($(fetch_anthropic_models))

# Determine the maximum number of models among the APIs
MAX_MODELS=${#OPENAI_MODELS[@]}
if [ ${#GEMINI_MODELS[@]} -gt $MAX_MODELS ]; then
    MAX_MODELS=${#GEMINI_MODELS[@]}
fi
if [ ${#ANTHROPIC_MODELS[@]} -gt $MAX_MODELS ]; then
    MAX_MODELS=${#ANTHROPIC_MODELS[@]}
fi

# Print header
printf "%-30s %-30s %-30s\n" "OpenAI Models" "Gemini Models" "Anthropic Models"
printf "%-30s %-30s %-30s\n" "-------------" "-------------" "---------------"

# Print models row by row
for ((i=0; i<MAX_MODELS; i++)); do
    OPENAI_MODEL=${OPENAI_MODELS[i]:-}
    GEMINI_MODEL=${GEMINI_MODELS[i]:-}
    ANTHROPIC_MODEL=${ANTHROPIC_MODELS[i]:-}
    printf "%-30s %-30s %-30s\n" "$OPENAI_MODEL" "$GEMINI_MODEL" "$ANTHROPIC_MODEL"
done
```

### Explanation of the Script

1. **API Key Checks**:
    - The script first checks if the necessary API keys (`OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`) are set. If any are missing, it exits with an error message.

2. **Fetching Models**:
    - **OpenAI**:
        - Makes a `GET` request to OpenAI's `/v1/models` endpoint with the appropriate authorization header.
        - Parses the JSON response to extract the `id` of each model.
    - **Gemini**:
        - Placeholder for Gemini API. Replace the URL and headers with actual Gemini API details.
        - Parses the JSON response to extract the `name` of each model.
    - **Anthropic**:
        - Makes a `GET` request to Anthropic's `/v1/models` endpoint with the required headers (`x-api-key` and `anthropic-version`).
        - Parses the JSON response to extract the `display_name` of each model.

3. **Storing Models**:
    - The models fetched from each API are stored in separate arrays: `OPENAI_MODELS`, `GEMINI_MODELS`, and `ANTHROPIC_MODELS`.

4. **Determining Maximum Rows**:
    - The script calculates the maximum number of models among the three APIs to ensure all models are displayed.

5. **Displaying Models**:
    - Prints a header row with columns for OpenAI, Gemini, and Anthropic models.
    - Iterates through each array and prints the models row by row, ensuring alignment using `printf` with fixed column widths.

### Usage

1. **Make the Script Executable**:
    ```bash
    chmod +x print-available-ai-models.sh
    ```

2. **Run the Script**:
    ```bash
    ./print-available-ai-models.sh
    ```

### Sample Output

```
OpenAI Models                 Gemini Models                Anthropic Models             
-------------                 -------------                ---------------             
gpt-4                         gemini-model-1               Claude 3.7 Sonnet            
gpt-3.5-turbo                 gemini-model-2               
                              
```

*Note*: The actual model names will vary based on the APIs' responses.

### Notes

- **Error Handling**: This script includes basic error handling for missing API keys. Depending on your requirements, you might want to add more robust error handling for API request failures or malformed JSON responses.
  
- **Gemini API Placeholder**: Ensure you replace the Gemini API URL and parsing logic with the actual details from Gemini's API documentation.

- **Performance Considerations**: For a large number of models, fetching and storing all models before displaying might consume more memory. Adjust the script accordingly if you encounter performance issues.

Feel free to customize the script further based on your specific needs!

