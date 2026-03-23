Write a report document and save it to the project's `docs/` directory.

---

## Instructions

1. **Determine the target project** from the current working directory or user context.
2. **Create the report** with this frontmatter structure at the top:

```markdown
# Title

**Date:** YYYY-MM-DD
**Environment:** (relevant env details — hardware, software versions)
**Method:** (what was measured/analyzed)

## Section 1
...
```

3. **Save the file** to `<project>/docs/YYYY-MM-DD_<snake_case_topic>.md`
   - Date = today's date
   - Topic = concise snake_case description of the report content
   - Create the `docs/` directory if it doesn't exist

4. **If arguments are provided**, use them as the topic/content guidance:
   - e.g., `/report density throughput benchmark` → write about density throughput benchmarking

## Conventions

- Use tables for quantitative results
- Include units in all measurements
- Keep prose minimal — data and interpretation, not filler
- If the report includes timing/benchmarks, specify hardware and methodology
- Korean commentary is fine for interpretation sections

## Project directory mapping

| Project | Path |
|---------|------|
| QHFlow2 | `/home1/irteam/data-vol1/projects/QHFlow2/` |
| dft-dataset | `/home1/irteam/data-vol1/projects/dft-dataset/` |
| esen | `/home1/irteam/data-vol1/projects/esen/` |
