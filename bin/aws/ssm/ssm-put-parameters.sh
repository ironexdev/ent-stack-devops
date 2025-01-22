#!/bin/bash

# Helper to upload secret and non-secret parameters to AWS Parameter Store
#
# FILE should contain name of .json file stored in bin/aws/ssm with an array of objects
#
# Non-secret values
# {
#   "Name": "FOO",
#   "Value": "bar",
#   "Type": "String"
# }
#
# Secret values
# {
#   "Name": "FOO",
#   "Value": "bar",
#   "Type": "SecureString",
#   "KeyId": "alias/aws/ssm"
# }
#
# Example call
#
# FILE=parameters.json REGION=us-east-1 bin/aws/ssm/ssm-put-parameters.sh

if [ -z "$FILE" ]; then
  echo "Error: FILE variable not set. Usage: FILE=parameters.json REGION=your-region ./ssm-put-parameters.sh"
  exit 1
fi

if [ -z "$REGION" ]; then
  echo "Error: REGION variable not set. Usage: FILE=parameters.json REGION=your-region ./ssm-put-parameters.sh"
  exit 1
fi

FILE="bin/aws/ssm/$FILE"

if [ ! -f "$FILE" ]; then
  echo "Error: File not found: $FILE"
  exit 1
fi

# Use a while-read loop to handle JSON objects properly
jq -c '.[]' "$FILE" | while read -r row; do
    name=$(echo "$row" | jq -r '.Name')
    value=$(echo "$row" | jq -r '.Value')
    type=$(echo "$row" | jq -r '.Type')

    # Ensure Name and Type are non-empty
    if [[ -z "$name" || -z "$type" ]]; then
      echo "Error: Name or Type is empty in JSON entry. Skipping entry."
      continue
    fi

    # Assume KeyId is required for SecureString and don't check for its presence
    if [[ "$type" == "SecureString" ]]; then
        key_id=$(echo "$row" | jq -r '.KeyId')
        aws ssm put-parameter --name "$name" --value "$value" --type "$type" --key-id "$key_id" --region "$REGION" --overwrite
    else
        aws ssm put-parameter --name "$name" --value "$value" --type "$type" --region "$REGION" --overwrite
    fi
done

echo "Parameters from $FILE have been added to AWS Parameter Store in region $REGION."
