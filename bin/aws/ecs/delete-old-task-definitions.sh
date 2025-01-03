#!/bin/bash

# Helper script to delete old task definitions from ECS

echo "Retrieving active task definitions..."
ACTIVE_TASK_DEFINITIONS=$(aws ecs list-task-definitions --status ACTIVE --query "taskDefinitionArns[]" --output text)

ACTIVE_TASK_DEFINITIONS_EXCEPT_LATEST_TWO=""

for TASK_FAMILY in $(echo "$ACTIVE_TASK_DEFINITIONS" | sed 's/:.*//g' | uniq); do
  FAMILY_TASK_DEFS=$(echo "$ACTIVE_TASK_DEFINITIONS" | grep "$TASK_FAMILY" | tail -n +3)

  ACTIVE_TASK_DEFINITIONS_EXCEPT_LATEST_TWO="$ACTIVE_TASK_DEFINITIONS_EXCEPT_LATEST_TWO $FAMILY_TASK_DEFS"
done

echo "Active task definitions except the latest two revisions:"
echo "$ACTIVE_TASK_DEFINITIONS_EXCEPT_LATEST_TWO"

echo "Deregistering selected active task definitions (excluding latest revisions)..."
for TASK_DEF in $ACTIVE_TASK_DEFINITIONS_EXCEPT_LATEST_TWO; do
  aws ecs deregister-task-definition --task-definition "$TASK_DEF" >/dev/null 2>&1
done

echo "Deleting all inactive task definitions..."
INACTIVE_TASK_DEFINITIONS=$(aws ecs list-task-definitions --status INACTIVE --query "taskDefinitionArns[]" --output text)
for TASK_DEF in $INACTIVE_TASK_DEFINITIONS; do
  aws ecs delete-task-definitions --task-definition "$TASK_DEF" >/dev/null 2>&1
done

echo "Process completed."
