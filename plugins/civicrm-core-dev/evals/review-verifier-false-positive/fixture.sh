#!/usr/bin/env bash
# Creates a minimal extension/core PHP file with proper SQL parameterization and APIv4 permission checks.
set -euo pipefail
mkdir -p CRM/Example
cat > CRM/Example/Lookup.php <<'PHP'
<?php

class CRM_Example_Lookup {

  /**
   * Fetch non-deleted contact summary for a caller-supplied contact ID.
   */
  public static function getSummary(int $contactId): array {
    $dao = CRM_Core_DAO::executeQuery(
      'SELECT id, display_name FROM civicrm_contact WHERE id = %1 AND is_deleted = 0',
      [1 => [$contactId, 'Integer']]
    );
    $contacts = civicrm_api4('Contact', 'get', [
      'checkPermissions' => TRUE,
      'select' => ['id', 'display_name'],
      'where' => [['id', '=', $contactId]],
    ]);
    return [
      'dao_count' => $dao->N,
      'api_count' => count($contacts),
    ];
  }

}
PHP
