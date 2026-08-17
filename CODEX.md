# Project instructions

Build a real multi-tenant LLM inference platform and preserve enough evidence for another engineer to reproduce the work.

## Working standard

- Keep every change tied to the current functional milestone.
- Prefer the smallest implementation that can answer the current question.
- Evaluate meaningful alternatives before choosing an architecture or tool.
- Record important decisions as ordered ADRs in `docs/decisions/`.
- Do not mark a milestone complete until the code works and the result is verified.
- Keep experiments repeatable. Record versions, configuration, commands, results, and limits.
- Include deliberate failures when they teach us about reliability or behavior under load.
- Store only sanitized evidence. Never commit credentials or private user data.
- Write documentation in simple, plain, direct English. Explain necessary technical terms near their first use.

## Artifact ownership

This repository is the source of truth for implementation artifacts. tejo.dev is the source of truth for the published learning narrative. Link between them instead of copying large documents into both places.

## Definition of done for a milestone

A milestone is complete when:

1. The functionality works in the target environment.
2. Another engineer can reproduce it from the repository.
3. A relevant failure or difficult case has been tested.
4. Evidence supports the conclusion.
5. The limits of the evidence are stated.
6. Important decisions and rejected alternatives are recorded.
7. The learning is published on tejo.dev when it provides a useful lesson.
