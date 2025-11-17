#!/bin/bash

TOKEN="Bearer my-secret-token-123"

curl -X POST "http://localhost:4000/v1/chat/completions" \
 -H "Accept: application/json" \
 -H "Content-Type: application/json" \
 -H "Authorization: $TOKEN" \
 -d '{"model":"velvet-14b","messages":[{"role":"user","content":"Test: 2 + 2 ?"}]}' \

