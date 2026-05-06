# ANF / IHRN Coverage Gap Analysis
**Source A (outline):** SQ-IHRN (ANF) Outline — Confluence page by Alexander Villaquiran  
**Source B (protocol):** ANF1-030 Verification Protocol, Version 0 — Sky Zhang  
**Analyst:** QA Agent — 2026-04-24

---

## 1. Summary

| Dimension | Count |
|-----------|-------|
| Outline test cases (original) | 29 |
| ANF1-030 mobile test cases (in scope for mobile QA) | ~35 |
| Outline cases with full coverage of ANF1-030 | 13 |
| Outline cases with partial coverage | 6 |
| ANF1-030 mobile cases **missing** from outline | 15 |
| Outline cases **beyond** ANF1-030 scope (additional coverage) | 6 |
| Language tests (explicitly out of scope in ANF1-030 §2) | 5 |
| Cloud/infra tests (out of scope for mobile QA outline) | ~20+ |
| **Net-new scenarios proposed** | **15** |

---

## 2. Coverage Matrix — ANF1-030 vs SQ-IHRN Outline

### Mobile Test Suites

| ANF1-030 Test ID | Description | Outline ID | Status |
|---|---|---|---|
| ST-Mobile-001-001 | Module level — feature flags active | Context_01 | Covered |
| ST-Mobile-002-001 | Onboarding — intro screen displayed | IHRN_ONB_01 | Covered |
| ST-Mobile-002-002 | Onboarding — terms/consent | IHRN_ONB_02 | Covered |
| ST-Mobile-002-003 | Onboarding — Enable AFib Detection toggle | IHRN_ONB_03 | Covered |
| ST-Mobile-002-004 | Onboarding — Enable Notifications toggle | IHRN_ONB_04 | Covered |
| ST-Mobile-002-005 | Onboarding — complete flow | IHRN_ONB_05 | Covered |
| ST-Mobile-002-006 | Onboarding — already-onboarded state | IHRN_ONB_07 | Covered |
| ST-Mobile-002-007 | Onboarding — cancel/back navigation | IHRN_ONB_06 | Covered |
| ST-Mobile-002-008 | Onboarding — entry point from Heart screen | IHRN_EP_HS_01 | Covered |
| **ST-Mobile-002-009** | **App killed mid-onboarding → both toggles revert to disabled** | — | **MISSING** |
| ST-Mobile-003-001 | Push notification displayed on phone | IHRN_OVERV_09, IHRN_OVERV_10 | Partial (toggle tested, not delivery) |
| **ST-Mobile-003-002** | **Push notification received after `notification_sent_at` reset (~10 min wait)** | — | **MISSING** |
| ST-Mobile-004-001 | Detection history list view | IHRN_OVERV_05, IHRN_OVERV_06 | Partial (tile + history list, not detail) |
| **ST-Mobile-004-002** | **Detection history detail view — classifications and time periods per tile** | — | **MISSING** |
| **ST-Mobile-004-003** | **Clear all detection history flow** | — | **MISSING** |
| **ST-Mobile-004-004** | **Detection history tile metadata** | — | **MISSING** |
| **ST-Mobile-004-005** | **Clear all history detailed confirmation dialog** | — | **MISSING** |
| **ST-Mobile-004-006** | **Detection history time periods display** | — | **MISSING** |
| ST-Mobile-005-001 | Offboarding — disable AFib detection | IHRN_OVERV_07 | Covered |
| ST-Mobile-005-002 | Offboarding — re-enable AFib detection | IHRN_OVERV_08 | Covered |
| **ST-Mobile-005-003** | **AFib history preserved and visible after detection toggle is turned off** | — | **MISSING** |
| **ST-Mobile-006-001** | **Security — user can only access their own data** | — | **MISSING** |
| **ST-Mobile-006-002** | **Security — user cannot access other users' AFib data** | — | **MISSING** |
| **ST-Mobile-006-003** | **User data isolation across accounts** | — | **MISSING** |
| ST-Mobile-007-001 | Installation — Android app/strap firmware version check | Context_03 | Partial (version check, not install steps) |
| ST-Mobile-007-002 | Installation — iOS app/strap firmware version check | Context_03 | Partial (version check, not install steps) |
| ST-Mobile-008-001 | Entry points — Heart screen | IHRN_EP_HS_01 | Covered |
| **ST-Mobile-008-002** | **IFU link → https://support.whoop.com/s/article/AFib-Notifications** | — | **MISSING** |

### Requirement-Level Tests (TS-6.x)

| ANF1-030 Suite | Description | Outline ID | Status |
|---|---|---|---|
| TS-6.8 Notification Req. | Notification requirements verification | IHRN_OVERV_09, IHRN_OVERV_10 | Partial |
| **TS-6.9 History Req.** | **Detection history grouped by "Month YYYY" header** | — | **MISSING** |
| TS-6.10 Security | API auth 401 for unauthenticated AFib history GET | — | **MISSING (Cloud/API scope)** |
| TS-6.12 SW Updates | Software update testing | — | Out of scope (Cloud) |
| **TS-6.13 Operational** | **Offline "Couldn't load status" state on Heart screen** | — | **MISSING** |
| **TS-6.13 Operational** | **"Heart Notifications data behind" state (Kafka lag)** | — | **MISSING** |
| **TS-6.16 Analytics** | **Amplitude events: open, toggle, confirm actions** | — | **MISSING** |
| TS-6.17 Module Level | Module level requirements | Context_01, Context_02 | Partial |

### Cloud / Infrastructure Tests (out of scope for mobile QA outline)

| Suite | Description | Status |
|---|---|---|
| IT-CLOUD-007-xxx | Integration — cloud detection service | Out of scope (Cloud team) |
| IT-CLOUD-008-xxx | Integration — notification delivery pipeline | Out of scope (Cloud team) |
| IT-CLOUD-009-xxx | Integration — history API | Out of scope (Cloud team) |
| ST-CLOUD-008-xxx | Cloud — notification service tests | Out of scope (Cloud team) |
| ST-CLOUD-009-001–008 | Cloud — history API + grouping by Month YYYY | Partially in scope (ST-CLOUD-009-008 relevant) |
| ST-CLOUD-012-xxx | Cloud — software update tests | Out of scope (Cloud team) |
| ST-CLOUD-013-xxx | Cloud — operational requirements | Out of scope (Cloud team) |
| ST-CLOUD-016-001 | Cloud — analytics events | Out of scope (Cloud team) |
| ST-CLOUD-017-xxx | Cloud — module level requirements | Out of scope (Cloud team) |
| ST-SECURE-010-1–7 | Security — all cloud security suites | Out of scope (Cloud team) |
| UT-MOBILE-005-001 | Unit — mobile eligibility check | Out of scope (unit test) |
| UT-CLOUD-xxx | Unit — cloud services | Out of scope (unit test) |
| Appendix D Load Testing | Load — shadow pipeline, 10% DAU, 20x scaling | Out of scope (Cloud team) |

---

## 3. Outline Items Beyond ANF1-030 Scope (Additional Coverage)

These test cases exist in the SQ-IHRN Outline but have no direct equivalent in the formal ANF1-030 protocol. They represent **valuable additional coverage** not required by the protocol.

| Outline ID | Description | Disposition |
|---|---|---|
| IHRN_EP_HS_02 | "ENABLE FEATURES" card on Home screen for unenrolled eligible users | Additional coverage — keep |
| IHRN_EP_HS_03 | "Possible AFib Detected" + "REVIEW DETAILS" card on Home screen | Additional coverage — keep |
| IHRN_OVERV_01 | Heart Screener screen title and back arrow UI verification | Additional coverage — keep |
| IHRN_OVERV_02 | Inactive section content text verification | Additional coverage — keep |
| IHRN_OVERV_03 | "Enable Afib Monitor" button states with "notification currently off" text | Additional coverage — keep |
| IHRN_HT_02 | Offline navigation for already-onboarded user | Additional coverage — keep |
| ECG_Spanish | Language test — Spanish | Out of scope per ANF1-030 §2; team-discretionary |
| ECG_Italian | Language test — Italian | Out of scope per ANF1-030 §2; team-discretionary |
| ECG_Portuguese | Language test — Portuguese | Out of scope per ANF1-030 §2; team-discretionary |
| ECG_German | Language test — German | Out of scope per ANF1-030 §2; team-discretionary |
| ECG_French | Language test — French | Out of scope per ANF1-030 §2; team-discretionary |

---

## 4. Net-New Scenarios Proposed (Coverage Gaps)

The following **15 new scenarios** were created to address gaps identified during the ANF1-030 comparison. These are flagged `[NEW]` in the Gherkin file.

| New ID | Description | ANF1-030 Source | Priority |
|---|---|---|---|
| ANF-NEW-001 | Offline state — "Couldn't load status" on Heart screen | TS-6.13 Operational | P2 |
| ANF-NEW-002 | "Heart Notifications data behind" Kafka lag state | TS-6.13 Operational | P2 |
| ANF-NEW-003 | App killed mid-onboarding → toggles revert to disabled | ST-Mobile-002-009 | P2 |
| ANF-NEW-004 | Push notification receipt after `notification_sent_at` reset | ST-Mobile-003-002 | P1 |
| ANF-NEW-005 | Amplitude open events (AFib Onboarding, ANF Education, Possible AFib) | TS-6.16 / ST-CLOUD-016-001 | P2 |
| ANF-NEW-006 | Amplitude toggle events (Afib Detection, Arrhythmia Notification) | TS-6.16 / ST-CLOUD-016-001 | P2 |
| ANF-NEW-007 | Amplitude confirm events (Clear Full History, Clear Date History) | TS-6.16 / ST-CLOUD-016-001 | P2 |
| ANF-NEW-008 | Detection history detail view — classifications + time periods | ST-Mobile-004-002, 004, 006 | P2 |
| ANF-NEW-009 | Clear single-day detection history flow | ST-Mobile-004-002 | P2 |
| ANF-NEW-010 | Clear all history detailed confirmation flow | ST-Mobile-004-003, 005 | P2 |
| ANF-NEW-011 | AFib history preserved after detection toggle off | ST-Mobile-005-003 | P1 |
| ANF-NEW-012 | User data isolation — no cross-user AFib data access | ST-Mobile-006-001, 002, 003 | P1 |
| ANF-NEW-013 | IFU link navigates to correct support article URL | ST-Mobile-008-002 | P2 |
| ANF-NEW-014 | Unauthenticated API GET to AFib history returns 401 | ST-SECURE-010-1 | P1 |
| ANF-NEW-015 | Detection history grouped by "Month YYYY" headers | ST-CLOUD-009-008 | P2 |

---

## 5. Discrepancies / Open Questions

1. **IHRN_EP_AVA_01/02** — "AVA" entry points are referenced in the outline but have no clear mapping to a test suite in ANF1-030. Confirm whether "AVA" refers to Activity View App or another surface.

2. **Country list discrepancy** — ANF1-030 formally lists only US as the initially supported country. The outline explicitly tests for 23+ countries (GB, DE, FR, IT, ES, NL, IE, BE, AT, SE, FI, PL, CZ, DK, PT, GR, CA, AU, NZ, SA, AE, QA). Confirm if the protocol has been updated or if these are planned-expansion countries.

3. **Language tests** — ANF1-030 §2 explicitly marks i18n/localization as out of scope. The outline includes 5 language test cases. These should either be removed, tagged as "discretionary," or a PRD amendment should be raised.

4. **Cloud-only tests (SECURE-010, CLOUD-016, etc.)** — 15 new scenarios were proposed with mobile context where feasible. For pure API/cloud tests (ANF-NEW-014), confirm whether mobile QA or a separate Cloud QA team owns execution.

5. **IHRN_OVERV_04 through IHRN_OVERV_10** — the outline IDs suggest 10 overview scenarios, but only IDs 01–10 are listed. Verify whether IHRN_OVERV_04 through IHRN_OVERV_06 exist in the outline with explicit goals or if they were inferred from ANF1-030.

6. **Amplitude event field values** — ANF1-030 TS-6.16 lists specific event names. Confirm exact Amplitude event property schemas with the dev team before executing ANF-NEW-005 through ANF-NEW-007.
