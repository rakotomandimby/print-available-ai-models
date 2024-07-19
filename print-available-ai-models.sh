#!/usr/bin/env bash

# I have the GEMINI_API_KEY environment variable set.
# I have the OPENAI_API_KEY environment variable set.
# I want the list of available AI models from OpenAI and Gemini.

echo "Available AI models from OpenAI:"
# curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models | jq '.data[].id'

curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models | jq '.data[] | select(.id | contains("gpt")) | .id'

echo "Available AI models from Gemini:"
curl -s -H "x-goog-api-key: ${GEMINI_API_KEY}"  https://generativelanguage.googleapis.com/v1/models | jq '.models[].name'

