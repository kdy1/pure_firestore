#!/usr/bin/env bash
set -eu

firebase emulators:exec --only firestore ./scripts/flutter-test.sh