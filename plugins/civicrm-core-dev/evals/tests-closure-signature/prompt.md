---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

My extension's headless tests set up their database as below. Yesterday I added the second `executeQuery` to the closure, but `myext_log` never appears in the test database: the tests behave as if the closure had not changed. Dropping the test database by hand helps once. What is going on, and what is the proper fix? There is no shell in this session.

```php
public function setUpHeadless(): CiviEnvBuilder {
  return \Civi\Test::headless()
    ->installMe(__DIR__)
    ->callback(function () {
      \CRM_Core_DAO::executeQuery('CREATE TABLE IF NOT EXISTS myext_queue (id INT)');
      \CRM_Core_DAO::executeQuery('CREATE TABLE IF NOT EXISTS myext_log (id INT)');
    })
    ->apply();
}
```
