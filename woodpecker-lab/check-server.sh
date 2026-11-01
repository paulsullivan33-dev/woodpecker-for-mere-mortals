#!/bin/bash
# check-server.sh — ask a running Woodpecker server three questions.
# Usage: ./check-server.sh [base-url]   (default http://127.0.0.1:18082)
base="${1:-http://127.0.0.1:18082}"
echo "GET $base/ (web UI)"
curl -s -o /dev/null -w "  status=%{http_code} content_type=%{content_type}\n" "$base/"
echo "GET $base/healthz (health endpoint)"
curl -s -o /dev/null -w "  status=%{http_code} (204 means healthy)\n" "$base/healthz"
echo "GET $base/api/version"
curl -s "$base/api/version"; echo
echo "GET $base/api/user without a token (must refuse)"
curl -s -o /dev/null -w "  status=%{http_code} (401 means the door is locked)\n" "$base/api/user"
