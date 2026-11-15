#!/usr/bin/env bash
# Builds a small core checkout with an uncommitted fix, other unfinished work and
# an untracked reproducer, and the image's copy of the code for the stand-in ck.
set -euo pipefail
here="$(dirname "${BASH_SOURCE[0]}")"

git init --quiet --initial-branch=master core
git -C core config user.name Dev
git -C core config user.email dev@example.org
mkdir -p core/CRM/Example core/tests/phpunit/CRM/Example

widget() {
  cat > core/CRM/Example/Widget.php <<EOF
<?php

class CRM_Example_Widget {

  public static function title(array \$widget): ?string {
    return \$widget['title'] ?? $1;
  }

}
EOF
}

ledger() {
  cat > core/CRM/Example/Ledger.php <<EOF
<?php

class CRM_Example_Ledger {

  public static function total(array \$postings): float {
$1    return array_sum(array_column(\$postings, 'amount'));
  }

}
EOF
}

fixture() {
  cat > core/tests/phpunit/CRM/Example/WidgetFixture.php <<EOF
<?php

class CRM_Example_WidgetFixture {

  public static function withTitle(): array {
    return ['id' => 1, 'title' => 'Annual report'];
  }
$1
}
EOF
}

widget NULL
ledger ''
fixture ''
git -C core add .
git -C core commit --quiet -m 'Add the example widget and ledger'

# The image holds the committed code.
mkdir .ck-image
git -C core archive HEAD | tar -x -C .ck-image

widget "'Untitled'"
ledger '    // TODO round per currency
'
fixture '
  public static function withoutTitle(): array {
    return ['"'id'"' => 2];
  }
'
cat > core/tests/phpunit/CRM/Example/WidgetTitleTest.php <<'EOF'
<?php

/**
 * @group headless
 */
class CRM_Example_WidgetTitleTest extends CiviUnitTestCase {

  public function testTitleFallback(): void {
    $this->assertSame('Untitled', CRM_Example_Widget::title(CRM_Example_WidgetFixture::withoutTitle()));
  }

}
EOF

cp "$here/ck" ./ck
chmod +x ./ck
