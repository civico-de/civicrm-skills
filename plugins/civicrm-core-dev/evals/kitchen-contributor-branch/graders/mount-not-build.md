---
type: llm
weight: 2
---

PASS if the response says both of the following:
- the build is not the way: the ref it is given has to exist in upstream civicrm-core (and civicrm-packages), such as `master`, an `X.Y` branch or a release tag, and a branch on a contributor's fork does not;
- a contributor's branch that changes files only is tested on the nearest existing image, `standalone-master` for a pull request against master, with the changed directories of a checkout of that branch mounted over `/var/www/html/core/<dir>` (through `ck run --mount` or a compose volume), and core's tests run there with `ckcoretest`.

FAIL if it goes along with building an image from the fork's branch, or gives no mount of the changed directories.
