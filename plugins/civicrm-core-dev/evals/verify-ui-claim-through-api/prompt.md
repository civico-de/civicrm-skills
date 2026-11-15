---
tags: [skill]
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
---

A user reports for CiviCRM 6.20 Standalone: someone with "edit event participants" but without "edit all events" opens a participant, changes the status and clicks Save; the form closes without an error and the status is unchanged.

I tried to reproduce it in a fresh `standalone-6.20` stack: I created event and participant with `Participant::create(FALSE)`, then ran `Participant::update(FALSE)->addWhere('id', '=', $id)->addValue('status_id:name', 'Attended')->execute()`. The status changed as it should. I would answer "cannot reproduce, works for me". Agreed? There is no browser and no shell in this session.
