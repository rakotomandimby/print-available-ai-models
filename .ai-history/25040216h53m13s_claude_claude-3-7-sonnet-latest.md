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



# This is claude-3-7-sonnet-latest answer (0k in, 1k out)

# Adding Anthropic API Support to the Script

To add support for Anthropic API in the `print-available-ai-models.sh` script, we need to:

1. Add logic to check for the Anthropic API key
2. Fetch the models from Anthropic API
3. Parse the JSON response to extract model names
4. Display the Anthropic models in a third column

Here's how to modify the script:

```bash
#!/bin/bash

# Define the output format for each API
format="%-30s %-30s %-30s\n"

# Print header
printf "$format" "OpenAI Models" "Gemini Models" "Anthropic Models"
printf "$format" "------------" "------------" "---------------"

# Check for OpenAI API key
if [ -z "$OPENAI_API_KEY" ]; then
    openai_models=("API key not set (OPENAI_API_KEY)")
else
    # Fetch OpenAI models
    response=$(curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models)
    
    # Check if the response contains an error
    if echo "$response" | grep -q "error"; then
        error_message=$(echo "$response" | jq -r '.error.message')
        openai_models=("Error: $error_message")
    else
        # Extract model IDs using jq
        readarray -t openai_models < <(echo "$response" | jq -r '.data[].id' | sort)
    fi
fi

# Check for Google AI API key
if [ -z "$GOOGLE_API_KEY" ]; then
    gemini_models=("API key not set (GOOGLE_API_KEY)")
else
    # Fetch Gemini models
    response=$(curl -s -H "x-goog-api-key: $GOOGLE_API_KEY" https://generativelanguage.googleapis.com/v1/models)
    
    # Check if the response contains an error
    if echo "$response" | grep -q "error"; then
        error_message=$(echo "$response" | jq -r '.error.message')
        gemini_models=("Error: $error_message")
    else
        # Extract model names using jq
        readarray -t gemini_models < <(echo "$response" | jq -r '.models[].name' | sed 's/^models\///' | sort)
    fi
fi

# Check for Anthropic API key
if [ -z "$ANTHROPIC_API_KEY" ]; then
    anthropic_models=("API key not set (ANTHROPIC_API_KEY)")
else
    # Fetch Anthropic models
    response=$(curl -s https://api.anthropic.com/v1/models \
     --header "x-api-key: $ANTHROPIC_API_KEY" \
     --header "anthropic-version: 2023-06-01")
    
    # Check if the response contains an error
    if echo "$response" | grep -q "error"; then
        error_message=$(echo "$response" | jq -r '.error.message')
        anthropic_models=("Error: $error_message")
    else
        # Extract model IDs using jq
        readarray -t anthropic_models < <(echo "$response" | jq -r '.data[].id' | sort)
    fi
fi

# Determine the maximum number of models
max_models=$(( $(echo ${#openai_models[@]} ${#gemini_models[@]} ${#anthropic_models[@]} | tr ' ' '\n' | sort -nr | head -n1) ))

# Print models in columns
for ((i=0; i<max_models; i++)); do
    openai_model="${openai_models[$i]:-}"
    gemini_model="${gemini_models[$i]:-}"
    anthropic_model="${anthropic_models[$i]:-}"
    printf "$format" "$openai_model" "$gemini_model" "$anthropic_model"
done
```

This modification:

1. Adds a section to check for the Anthropic API key
2. Uses curl to fetch models from the Anthropic API with the required headers
3. Parses the JSON response to extract model IDs
4. Updates the column format to include the third column for Anthropic models
5. Displays all models in three columns, properly aligned

Make sure to set your `ANTHROPIC_API_KEY` environment variable before running the script to see the available Anthropic models.

