# ADR 0001: Keep the implementation in a separate repository

- **Status:** Accepted
- **Date:** 2026-08-16

## Context

The project has two outputs. It produces a working inference platform and a set of publications that explain what we learned. The tejo.dev repository already owns the website and published content. Mixing platform code, cloud infrastructure, test workloads, and experimental results into that repository would make both projects harder to understand.

## Alternatives

### Keep everything in the tejo.dev repository

This would place the code beside the articles. It would require only one repository, but website changes and platform changes would share history, automation, permissions, and dependencies.

### Keep the implementation in a separate repository

The platform repository would own executable artifacts and evidence. tejo.dev would own the learning narrative and link to the exact artifact behind each claim.

### Split the platform into several repositories now

Infrastructure, services, experiments, and documentation could each have a repository. This would create clear ownership boundaries later, but it would add coordination before those boundaries are needed.

## Comparison criteria

We compared the options using:

- ease of reproducing the platform
- clarity for a reader
- independence of build and deployment workflows
- ability to link a claim to its evidence
- maintenance cost while the project is small

## Decision

Use one separate public repository for all platform artifacts. It will contain code, infrastructure, examples, tests, experiments, sanitized evidence, runbooks, diagrams, and ADRs.

tejo.dev will contain concise project status and the published learning narrative. Publications will link to the relevant repository version, file, or result instead of copying the implementation.

## Consequences

- Platform work can use its own checks and release history.
- Readers can clone the implementation without cloning the website.
- A publication and its evidence live in different repositories, so links must be kept accurate.
- We must avoid duplicating long documents because copies will drift.

## Evidence

The initial repository can represent the full artifact lifecycle with one structure and one commit history. The website already supports a repository link on a project page, so no new website service is required.

## Limits

This decision does not prove that one platform repository will remain suitable as the system grows. It also does not decide how services will be packaged or released.

## Revisit when

Revisit this decision if independent teams own parts of the platform, release cycles conflict, repository checks become too slow, access rules differ, or a component becomes useful as a standalone project.
