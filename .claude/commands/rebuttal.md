Write or update a rebuttal response document in the project's `rebuttal/` directory.

---

## Instructions

1. **Determine the target project** from the current working directory or user context (default: QHFlow2).
2. **Determine the question number** — check existing `rebuttal/Q*` folders to find the next available number.
3. **If arguments are provided**, use them as the reviewer question topic:
   - e.g., `/rebuttal DeepH data compatibility` → write about DeepH data compatibility
   - e.g., `/rebuttal Q1 update results` → update existing Q1's report

4. **Create the rebuttal document** following this structure:

```markdown
# QN: Title

**Date:** YYYY-MM-DD

---

## Reviewer Question

> (Original reviewer question — quote or paraphrase)

## Short Answer

(1-2 sentence direct answer)

---

## 상세 분석

### 1. First Point
...

### 2. Second Point
...

## Summary Table

(If applicable — concise comparison table)

## 현실적 대안 / Proposed Response

(What we actually do about it)
```

5. **Save the file** to `<project>/rebuttal/QN_<snake_case_topic>/report.md`
   - N = next available question number
   - If updating, modify existing report.md in place

6. **If experiments are needed**, also create a script in the same directory:
   - `<project>/rebuttal/QN_<topic>/run_<experiment>.py`
   - Save results to `<project>/rebuttal/QN_<topic>/results/`

## Conventions

- Be technically precise — reviewers are domain experts
- Use LaTeX math notation for equations
- Use tables for quantitative comparisons
- Include code references (`file.py:line`) when discussing implementation details
- Korean is fine for analysis/commentary sections
- Keep the tone objective and evidence-based
- If the question requires experiments, plan them first and ask user before running

## Project directory mapping

| Project | Path | Rebuttal Dir |
|---------|------|--------------|
| QHFlow2 | `/home1/irteam/data-vol1/projects/QHFlow2/` | `rebuttal/` |
