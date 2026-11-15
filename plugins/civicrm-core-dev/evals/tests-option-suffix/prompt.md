---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

This fixture from my new civicrm-core test misbehaves. The activity ends up with `activity_type_id` 0 and nothing complains; the address call does not do what I want either. What is wrong with each, and how should the two calls read? There is no shell in this session.

```php
$activity = $this->createTestEntity('Activity', [
  'source_contact_id' => $contactID,
  'activity_type_id' => 'Meeting',
  'subject' => 'Kick-off',
]);
$address = $this->createTestEntity('Address', [
  'contact_id' => $contactID,
  'country_id:name' => 'Germany',
], 'home');
```
