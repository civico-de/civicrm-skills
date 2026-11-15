#!/usr/bin/env bash
# Builds a small core checkout with a tag 6.20.0, five commits up to
# origin/master and an uncommitted edit, and puts the stand-in ck beside it.
set -euo pipefail
here="$(dirname "${BASH_SOURCE[0]}")"

git init --quiet --initial-branch=master core
git -C core config user.name Dev
git -C core config user.email dev@example.org
# Fixed dates give every run the same commit ids.
export GIT_AUTHOR_DATE='2026-10-01T12:00:00Z' GIT_COMMITTER_DATE='2026-10-01T12:00:00Z'

# change <subject> <file>...: adds a line to each file and commits.
change() {
  local subject="$1" file
  shift
  for file in "$@"; do
    mkdir -p "core/$(dirname "$file")"
    [ -e "core/$file" ] || printf '<?php\n' > "core/$file"
    printf '// %s\n' "$subject" >> "core/$file"
  done
  git -C core add .
  git -C core commit --quiet -m "$subject"
}

change 'Add the example widget, ledger and greeter' \
  CRM/Example/Widget.php CRM/Example/Ledger.php CRM/Example/Greeter.php \
  tests/phpunit/CRM/Example/WidgetTest.php sql/GenerateData.php ext/example/example.php
git -C core tag 6.20.0
change 'Ledger - round totals per currency' CRM/Example/Ledger.php
change 'Example - add the render cache table' sql/GenerateData.php
change 'Widget - reuse the cached render' CRM/Example/Widget.php
change 'Greeter - fall back to the default locale' CRM/Example/Greeter.php ext/example/example.php
change 'Widget - escape the title' CRM/Example/Widget.php
git -C core update-ref refs/remotes/origin/master master

printf '// TODO greet by household\n' >> core/CRM/Example/Greeter.php

cp "$here/ck" ./ck
chmod +x ./ck
