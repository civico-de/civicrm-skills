---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

This civicrm-core test passes, but afterwards the next test class finds two stray contacts, and `CIVICRM_SLOPPY_TEST` points at this method. Why do they survive the transaction, and how do I fix the test? There is no shell in this session.

```php
public function setUp(): void {
  parent::setUp();
  $this->useTransaction();
}

public function testCustomValueSurvivesMerge(): void {
  $main = $this->individualCreate([], 'main');
  $other = $this->individualCreate([], 'other');
  $group = $this->createTestEntity('CustomGroup', ['title' => 'Badges', 'extends' => 'Contact']);
  $this->createTestEntity('CustomField', ['custom_group_id' => $group['id'], 'label' => 'Badge', 'html_type' => 'Text']);
  // merge and assertions follow
}
```
