#!/usr/bin/env bash

get_openai_models() {
  curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models | jq -r '.data[]  | .id' | sort
}

get_gemini_models() {
  curl -s -H "x-goog-api-key: ${GEMINI_API_KEY}"  https://generativelanguage.googleapis.com/v1beta/models | jq -r '.models[].name' | sort
}

openai_models=$(get_openai_models)
gemini_models=$(get_gemini_models)

max_length=$(( $(echo "$openai_models" | wc -l) > $(echo "$gemini_models" | wc -l) ? $(echo "$openai_models" | wc -l) : $(echo "$gemini_models" | wc -l) ))

printf " %-50s | %s\n" "Available OpenAI Models" "Available Gemini Models"
printf " %-50s | %s\n" "                        " "                        "

for i in $(seq 1 $max_length); do
  openai_model=$(echo "$openai_models" | sed -n "${i}p" 2>/dev/null || echo "")
  gemini_model=$(echo "$gemini_models" | sed -n "${i}p" 2>/dev/null || echo "")
  printf " %-50s | %s\n" "$openai_model" "$gemini_model"
done
