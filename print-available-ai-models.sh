#!/usr/bin/env bash

# Function to fetch and format OpenAI models
get_openai_models() {
  curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models | jq -r '.data[] | select(.id | contains("gpt")) | .id'
}

# Function to fetch and format Gemini models
get_gemini_models() {
  curl -s -H "x-goog-api-key: ${GEMINI_API_KEY}"  https://generativelanguage.googleapis.com/v1/models | jq -r '.models[].name'
}

# Get the models
openai_models=$(get_openai_models)
gemini_models=$(get_gemini_models)

# Get the maximum length of both lists
max_length=$(( $(echo "$openai_models" | wc -l) > $(echo "$gemini_models" | wc -l) ? $(echo "$openai_models" | wc -l) : $(echo "$gemini_models" | wc -l) ))

# Print the headers
printf " %-30s | %s\n" "Available OpenAI Models" "Available Gemini Models"
printf " %-30s | %s\n" "                        " "                        "

# Iterate through the models and print them side by side
for i in $(seq 1 $max_length); do
  # Get the i-th element from each list, or print an empty string if the index is out of bounds
  openai_model=$(echo "$openai_models" | sed -n "${i}p" 2>/dev/null || echo "")
  gemini_model=$(echo "$gemini_models" | sed -n "${i}p" 2>/dev/null || echo "")

  # Print the models side by side
  printf " %-30s | %s\n" "$openai_model" "$gemini_model"
done
