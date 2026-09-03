# Decision Log

## DEC-001

Decision: Native iPhone application using Swift and SwiftUI.
Reason: Matches the requested platform and keeps the shell Apple-native.
Status: Accepted
Date: 2026-09-03

## DEC-002

Decision: Repository architecture favors centralized domain logic and feature-separated UI.
Reason: Prevents duplicated behavior and keeps future implementation boundaries clear.
Status: Accepted
Date: 2026-09-03

## DEC-003

Decision: Repository structure remains shallow and minimal.
Reason: Reduces navigation overhead and avoids nested helper sprawl.
Status: Accepted
Date: 2026-09-03

## DEC-004

Decision: No unnecessary generated outputs or duplicate historical code are committed.
Reason: Git history should remain the record of superseded work.
Status: Accepted
Date: 2026-09-03

## DEC-005

Decision: Tests are risk-based rather than exhaustive UI duplication.
Reason: Task 00 only needs to prove the shell and canonical terminology can initialize.
Status: Accepted
Date: 2026-09-03

## DEC-006

Decision: Backend and persistence technology remain intentionally undecided after Task 00.
Reason: Prevents premature infrastructure lock-in before product behavior is defined.
Status: Accepted
Date: 2026-09-03

## DEC-007

Decision: GitHub Actions on a standard macOS runner is the canonical native iOS build/test verification path for development environments that do not provide Xcode.
Reason: The primary development environment may be Windows/VS Code, while native iOS compilation and XCTest require the Apple toolchain.
Status: Accepted
Date: 2026-09-03
