# Architect Memory

## Architecture Decisions

- 2026-03-03: Identified publish extraction and default scope removal as the two highest-value remaining architecture tasks. Posted to shared board for PM prioritization.

## Open Questions

- Awaiting PM input on sequencing: publish extraction vs default scope removal vs new feature work
- `published` column: restore or delete dead guards? Need PM decision on whether publishing workflow is coming back.
- SolutionsController broadcast extraction — medium priority, worth bundling with any solutions work

## Patterns in Use

- Service objects: `NytPuzzleImporter`, `NytPuzzleFetcher`, `NytGithubRecorder` in `app/services/` — established pattern for the publish extraction to follow
- Model-level auth: `Solution#accessible_by?` — pattern for pushing authorization into models
- Admin::BaseController — shared CRUD inheritance for admin controllers
