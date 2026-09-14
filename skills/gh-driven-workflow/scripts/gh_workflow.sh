#!/bin/bash

# GitHub-Driven Workflow Helper Script

COMMAND=$1
TITLE=$2
BODY=$3
ISSUE_ID=$4

case $COMMAND in
  create)
    if [ -z "$TITLE" ]; then
      echo "Error: Title is required for creating an issue."
      exit 1
    fi
    # Create issue and capture ID
    ISSUE_URL=$(gh issue create --title "$TITLE" --body "$BODY" --label "enhancement")
    ISSUE_ID=$(echo $ISSUE_URL | grep -oE '[0-9]+$')
    echo "SUCCESS: Created Issue #$ISSUE_ID"
    echo "ISSUE_ID=$ISSUE_ID"
    ;;
  
  close)
    if [ -z "$ISSUE_ID" ]; then
      echo "Error: Issue ID is required for closing an issue."
      exit 1
    fi
    gh issue close "$ISSUE_ID" --comment "$BODY"
    echo "SUCCESS: Closed Issue #$ISSUE_ID"
    ;;

  *)
    echo "Usage: $0 {create|close} [args...]"
    exit 1
    ;;
esac
