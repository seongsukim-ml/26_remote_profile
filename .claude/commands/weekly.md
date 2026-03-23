Create or update this week's weekly update note.

---

## Instructions

1. **Determine the current ISO week**: `date +%G-W%V` (e.g., 2026-W12)
2. **Check if the file already exists**: `/home1/irteam/data-vol1/docs/weekly/YYYY-WXX.md`
   - If it exists, read it and **append/update** rather than overwrite
   - If it doesn't exist, create it from the template below

3. **Gather progress** from each active project:
   - Check `git log --since="1 week ago" --oneline` in each project
   - Check `tasks/todo.md` for completed/in-progress items
   - Check `docs/` for any new reports written this week

4. **Fill in the template** with findings:

```markdown
# Weekly Update — YYYY-WXX (MM/DD ~ MM/DD)

## Summary
<!-- 1-3 bullet points: 이번 주 핵심 성과 -->

## QHFlow2
- **Progress:**
- **Blockers:**
- **Next:**

## dft-dataset
- **Progress:**
- **Blockers:**
- **Next:**

## esen
- **Progress:**
- **Blockers:**
- **Next:**

## Notes
<!-- 프로젝트 횡단 메모, 아이디어, 참고사항 -->
```

5. **Save** to `/home1/irteam/data-vol1/docs/weekly/YYYY-WXX.md`

## Conventions
- 한국어로 작성
- 간결하게 — bullet point 위주
- 프로젝트에 진행 없으면 "(변동 없음)" 으로 표기
- Blockers가 없으면 생략 가능
