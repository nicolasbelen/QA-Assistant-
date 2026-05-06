# Feature: Arrhythmia Notification Feature (ANF) / IHRN
# Source: SQ-IHRN (ANF) Outline — Confluence (Alexander Villaquiran)
# Protocol: ANF1-030 Verification Protocol, Version 0 — Sky Zhang
# Generated: 2026-04-24 by QA Agent
#
# Tag legend:
#   @IHRN                 — all ANF/IHRN scenarios
#   @Context              — prerequisite/setup validation
#   @EntryPoints          — ANF entry point navigation
#   @Onboarding           — enrollment flow
#   @Overview             — Heart Screener overview screen
#   @HealthTab            — Health Tab integration
#   @History              — AFib detection history
#   @Notifications        — push notification behavior
#   @Analytics            — Amplitude event verification
#   @Security             — data isolation and API auth
#   @Languages            — localization (out of scope per ANF1-030 §2)
#   @New                  — net-new scenario from gap analysis; NOT in original outline
#   @OutOfScope-ANF1030   — outline test with no ANF1-030 equivalent
#   @P1 / @P2 / @P3       — priority (P1=Critical, P2=High, P3=Normal)

Feature: Arrhythmia Notification Feature (ANF) / IHRN (Irregular Heart Rate Notification)
  As a WHOOP user eligible for AFib monitoring
  I want to be notified when potential AFib is detected
  So that I can take timely action regarding my heart health

  Background:
    Given the user has a WHOOP 4.0 strap paired to the app
    And the strap firmware version is greater than "41.11.7.0"
    And the user is 22 years of age or older
    And the user is located in a supported country
    And the user has no prior AFib diagnosis on record
    And the feature flag "arrhythmia-notification-feature-android" is enabled for Android
    And the feature flag "arrhythmia-notification-feature-ios" is enabled for iOS
    And the feature flag "health-mainview-tab" is enabled
    And the feature flag "heart-health" is enabled

  # =====================================================================
  # CONTEXT — Feature Prerequisites
  # =====================================================================

  @IHRN @Context @P2
  Scenario: Context - ANF feature flag prerequisites are active
    Given the test user is configured in the test environment
    When the tester verifies the feature flag state for that user
    Then the flag "arrhythmia-notification-feature-android" is enabled for Android
    And the flag "arrhythmia-notification-feature-ios" is enabled for iOS
    And the flag "health-mainview-tab" is enabled
    And the flag "heart-health" is enabled

  @IHRN @Context @P1
  Scenario: Context_01 - Eligible user can access the ANF feature
    Given the user meets all ANF eligibility criteria
    When the user opens the WHOOP app
    Then the Heart Screener module is visible and accessible
    And the ANF entry point is present on the Heart screen

  @IHRN @Context @P1
  Scenario: Context_02 - Ineligible user cannot access ANF
    Given a user who does not meet one or more ANF eligibility criteria
    When the user opens the WHOOP app
    Then the ANF feature is not available to that user
    And no AFib monitoring entry points are displayed

  @IHRN @Context @P2
  Scenario: Context_03 - Required hardware and firmware version are met
    Given the user has a WHOOP 4.0 strap paired to the app
    When the tester checks the strap firmware version
    Then the firmware version is greater than "41.11.7.0"
    And the app version meets the minimum required version for ANF

  @IHRN @Context @P2
  Scenario: Context_04 - Supported country eligibility
    Given the user's account is registered in a supported country
    When the user opens the WHOOP app
    Then the ANF feature is accessible
    And supported countries include US, GB, DE, FR, IT, ES, NL, IE, BE, AT, SE, FI, PL, CZ, DK, PT, GR, CA, AU, NZ, SA, AE, and QA

  # =====================================================================
  # ENTRY POINTS — Heart Screen
  # =====================================================================

  @IHRN @EntryPoints @P1
  Scenario: IHRN_EP_HS_01 - Access ANF from Heart screen Heart Score section
    Given the user is eligible for ANF and has not yet enrolled
    And the user is on the Heart screen
    When the user taps on the Heart Score section
    Then the user is navigated to the ANF enrollment entry point
    And the ANF feature introduction or onboarding screen is displayed

  @IHRN @EntryPoints @OutOfScope-ANF1030 @P2
  Scenario: IHRN_EP_HS_02 - "ENABLE FEATURES" card displayed for unenrolled eligible users on Home screen
    Given the user is eligible for ANF and has not yet enrolled
    And the user is on the Home screen
    When the user views the Home screen content
    Then an "ENABLE FEATURES" card is displayed
    And the card presents the ANF enrollment option

  @IHRN @EntryPoints @OutOfScope-ANF1030 @P1
  Scenario: IHRN_EP_HS_03 - "Possible AFib Detected" card with "REVIEW DETAILS" action on Home screen
    Given the user is enrolled in ANF with detection enabled
    And a potential AFib detection event has occurred
    And the user is on the Home screen
    When the user views the Home screen content
    Then a "Possible AFib Detected" notification card is displayed
    And the card includes a "REVIEW DETAILS" button
    When the user taps "REVIEW DETAILS"
    Then the user is navigated to the AFib detection detail screen

  # =====================================================================
  # ENTRY POINTS — AVA
  # =====================================================================

  @IHRN @EntryPoints @P2
  Scenario: IHRN_EP_AVA_01 - Access ANF from AVA entry point (unenrolled user)
    Given the user is eligible for ANF and has not yet enrolled
    And the user is in the AVA experience
    When the user views the ANF entry point in AVA
    Then the ANF enrollment entry point is displayed
    And the user can navigate to the onboarding flow from AVA

  @IHRN @EntryPoints @P2
  Scenario: IHRN_EP_AVA_02 - Access ANF from AVA entry point (enrolled user)
    Given the user is enrolled in ANF with detection enabled
    And the user is in the AVA experience
    When the user views the ANF section in AVA
    Then the ANF monitoring status is displayed
    And the user can navigate to the Heart Screener from AVA

  # =====================================================================
  # ONBOARDING
  # =====================================================================

  @IHRN @Onboarding @P1
  Scenario: IHRN_ONB_01 - Onboarding intro screen is displayed correctly
    Given the user is eligible for ANF and has not yet enrolled
    And the user has navigated to the ANF onboarding entry point
    When the onboarding intro screen loads
    Then the ANF introduction screen is displayed
    And the screen contains information about the AFib detection feature
    And a "Get Started" or equivalent call-to-action button is visible

  @IHRN @Onboarding @P1
  Scenario: IHRN_ONB_02 - Onboarding terms and consent screen
    Given the user has advanced past the ANF intro screen
    When the terms and consent screen is displayed
    Then the user sees the ANF terms and conditions
    And the user must accept the terms to proceed
    And declining the terms prevents completion of enrollment

  @IHRN @Onboarding @P1
  Scenario: IHRN_ONB_03 - Enable AFib Detection toggle during onboarding
    Given the user has accepted the ANF terms during onboarding
    When the detection configuration step is displayed
    Then an "Enable AFib Detection" toggle is presented
    And the toggle defaults to the disabled state
    When the user enables the "Enable AFib Detection" toggle
    Then the toggle moves to the enabled state
    And AFib detection will be activated upon enrollment completion

  @IHRN @Onboarding @P1
  Scenario: IHRN_ONB_04 - Enable Notifications toggle during onboarding
    Given the user has enabled the AFib Detection toggle during onboarding
    When the notifications configuration step is displayed
    Then an "Enable Notifications" toggle is presented
    And the toggle defaults to the disabled state
    When the user enables the "Enable Notifications" toggle
    Then the toggle moves to the enabled state
    And AFib push notifications will be activated upon enrollment completion

  @IHRN @Onboarding @P1
  Scenario: IHRN_ONB_05 - Complete the onboarding flow successfully
    Given the user has enabled both AFib Detection and Notifications toggles during onboarding
    When the user completes the full onboarding flow
    Then the user is successfully enrolled in ANF
    And the user is navigated to the Heart Screener overview screen
    And the AFib Detection toggle shows as enabled
    And the Notifications toggle shows as enabled

  @IHRN @Onboarding @P2
  Scenario: IHRN_ONB_06 - Cancel or navigate back during onboarding
    Given the user is in the middle of the ANF onboarding flow
    When the user taps the back arrow or cancels the flow
    Then the user is returned to the previous screen
    And no enrollment changes are saved
    And the user remains in the unenrolled state

  @IHRN @Onboarding @P2
  Scenario: IHRN_ONB_07 - Already-onboarded user is not shown the onboarding flow again
    Given the user has previously completed ANF onboarding
    When the user navigates to the ANF entry point
    Then the user is taken directly to the Heart Screener overview screen
    And the onboarding flow is not shown
    And the user's current detection and notification toggle states are displayed

  # =====================================================================
  # HEART SCREENER OVERVIEW — IHRN
  # =====================================================================

  @IHRN @Overview @OutOfScope-ANF1030 @P2
  Scenario: IHRN_OVERV_01 - Heart Screener screen title and back arrow navigation
    Given the user is on the Heart Screener overview screen
    When the user views the screen header
    Then the screen title "Heart Screener" is displayed correctly
    And a back arrow is visible in the top-left corner
    When the user taps the back arrow
    Then the user is navigated back to the previous screen

  @IHRN @Overview @OutOfScope-ANF1030 @P3
  Scenario: IHRN_OVERV_02 - Inactive section content and text are correct
    Given the user is on the Heart Screener overview screen
    And the AFib detection is in the inactive/disabled state
    When the user views the inactive section
    Then the section displays the correct descriptive text about enabling AFib monitoring
    And the copy matches the expected UI specifications

  @IHRN @Overview @OutOfScope-ANF1030 @P2
  Scenario: IHRN_OVERV_03 - "Enable Afib Monitor" button states with notification indicator
    Given the user is on the Heart Screener overview screen
    And the user has AFib detection disabled
    When the user views the AFib monitoring section
    Then an "Enable Afib Monitor" button is displayed
    And the text "notification currently off" is visible alongside the button
    And the button is tappable to navigate to the detection settings

  @IHRN @Overview @P1
  Scenario: IHRN_OVERV_04 - Heart Screener overview shows active detection state
    Given the user has completed ANF onboarding with detection enabled
    When the user navigates to the Heart Screener overview screen
    Then the AFib detection status shows as active and enabled
    And the most recent detection result is displayed if one exists
    And the detection history section is accessible

  @IHRN @Overview @P1
  Scenario: IHRN_OVERV_05 - Latest detection tile is displayed on the overview screen
    Given the user is enrolled in ANF with detection enabled
    And at least one AFib detection event has been recorded
    When the user views the Heart Screener overview screen
    Then the latest detection tile is displayed
    And the tile shows the detection result classification
    And the tile shows the date and time of the last detection

  @IHRN @Overview @P2
  Scenario: IHRN_OVERV_06 - Full detection history is accessible from the overview screen
    Given the user is enrolled in ANF with detection enabled
    And multiple AFib detection events have been recorded
    When the user navigates to the full detection history from the overview
    Then all recorded detection events are listed
    And the history is sorted with the most recent detection first

  @IHRN @Overview @P1
  Scenario: IHRN_OVERV_07 - Toggle AFib detection off from the overview screen
    Given the user is on the Heart Screener overview screen
    And the AFib Detection toggle is currently enabled
    When the user taps the AFib Detection toggle to disable it
    Then the toggle moves to the disabled state
    And AFib detection is no longer active for the user
    And the Heart Screener overview reflects the disabled state

  @IHRN @Overview @P1
  Scenario: IHRN_OVERV_08 - Toggle AFib detection back on from the overview screen
    Given the user is on the Heart Screener overview screen
    And the AFib Detection toggle is currently disabled
    When the user taps the AFib Detection toggle to enable it
    Then the toggle moves to the enabled state
    And AFib detection is re-activated for the user
    And the Heart Screener overview reflects the enabled state

  @IHRN @Overview @P1
  Scenario: IHRN_OVERV_09 - Toggle AFib notifications off from the overview screen
    Given the user is on the Heart Screener overview screen
    And the Notifications toggle is currently enabled
    When the user taps the Notifications toggle to disable it
    Then the toggle moves to the disabled state
    And AFib push notifications are no longer sent to the user
    And the Heart Screener overview reflects notifications as disabled

  @IHRN @Overview @P1
  Scenario: IHRN_OVERV_10 - Toggle AFib notifications back on from the overview screen
    Given the user is on the Heart Screener overview screen
    And the Notifications toggle is currently disabled
    When the user taps the Notifications toggle to enable it
    Then the toggle moves to the enabled state
    And AFib push notifications are re-activated for the user
    And the Heart Screener overview reflects notifications as enabled

  # =====================================================================
  # IHRN — HEALTH TAB
  # =====================================================================

  @IHRN @HealthTab @P2
  Scenario: IHRN_HT_01 - Health Tab displays ANF status for enrolled user
    Given the user has completed ANF onboarding
    When the user navigates to the Health Tab
    Then the Heart Screener module is visible in the Health Tab
    And the current AFib detection status is displayed
    And the user can navigate to the Heart Screener from the Health Tab

  @IHRN @HealthTab @OutOfScope-ANF1030 @P2
  Scenario: IHRN_HT_02 - Offline navigation for already-onboarded user
    Given the user has completed ANF onboarding
    And the device has no network connectivity
    When the user navigates to the ANF section of the app
    Then the user can still view the Health Tab and Heart Screener screen
    And previously cached data is displayed where available
    And an appropriate offline indicator or message is shown when real-time data is unavailable

  # =====================================================================
  # LANGUAGE TESTS (ECG Localization)
  # Note: Explicitly out of scope per ANF1-030 Section 2.
  #       Maintained as team-discretionary additional coverage.
  # =====================================================================

  @IHRN @Languages @OutOfScope-ANF1030 @P3
  Scenario: ECG_Spanish - ANF screens render correctly in Spanish
    Given the user's device language is set to Spanish
    And the user is enrolled in ANF
    When the user navigates to the Heart Screener and related ANF screens
    Then all screen text, labels, and UI elements are displayed in Spanish
    And the Spanish copy is accurate with no untranslated strings

  @IHRN @Languages @OutOfScope-ANF1030 @P3
  Scenario: ECG_Italian - ANF screens render correctly in Italian
    Given the user's device language is set to Italian
    And the user is enrolled in ANF
    When the user navigates to the Heart Screener and related ANF screens
    Then all screen text, labels, and UI elements are displayed in Italian
    And the Italian copy is accurate with no untranslated strings

  @IHRN @Languages @OutOfScope-ANF1030 @P3
  Scenario: ECG_Portuguese - ANF screens render correctly in Portuguese
    Given the user's device language is set to Portuguese
    And the user is enrolled in ANF
    When the user navigates to the Heart Screener and related ANF screens
    Then all screen text, labels, and UI elements are displayed in Portuguese
    And the Portuguese copy is accurate with no untranslated strings

  @IHRN @Languages @OutOfScope-ANF1030 @P3
  Scenario: ECG_German - ANF screens render correctly in German
    Given the user's device language is set to German
    And the user is enrolled in ANF
    When the user navigates to the Heart Screener and related ANF screens
    Then all screen text, labels, and UI elements are displayed in German
    And the German copy is accurate with no untranslated strings

  @IHRN @Languages @OutOfScope-ANF1030 @P3
  Scenario: ECG_French - ANF screens render correctly in French
    Given the user's device language is set to French
    And the user is enrolled in ANF
    When the user navigates to the Heart Screener and related ANF screens
    Then all screen text, labels, and UI elements are displayed in French
    And the French copy is accurate with no untranslated strings

  # =====================================================================
  # [NEW] NET-NEW SCENARIOS — Gap Analysis (ANF1-030 → Missing from Outline)
  # These scenarios address coverage gaps identified by comparing the
  # SQ-IHRN Outline against the ANF1-030 formal verification protocol.
  # Flag each for review before adding to the test suite in Xray.
  # =====================================================================

  @IHRN @New @Negative @P2
  Scenario: [NEW] ANF-NEW-001 - Offline state shows "Couldn't load status" on Heart screen
    Given the user is enrolled in ANF
    And the device has no network connectivity (airplane mode or network unavailable)
    When the user navigates to the Heart screen
    Then the Heart screen displays a "Couldn't load status" error state
    And no stale or incorrect data is presented as current
    And the user can retry once connectivity is restored

  @IHRN @New @Negative @P2
  Scenario: [NEW] ANF-NEW-002 - "Heart Notifications data behind" state when Kafka consumer lags
    Given the user is enrolled in ANF with notifications enabled
    And the cloud detection pipeline has been put into a consumer lag state
    When the user views the Heart Screener overview screen
    Then a "Heart Notifications data behind" indicator or message is displayed
    And the user is informed that detection data may be delayed
    And the app does not crash or display incorrect detection state

  @IHRN @New @Onboarding @Negative @P2
  Scenario: [NEW] ANF-NEW-003 - App killed mid-onboarding reverts both toggles to disabled
    Given the user is in the ANF onboarding flow
    And the user has enabled both the AFib Detection toggle and the Notifications toggle
    When the app is force-closed before enrollment is completed
    And the user reopens the app and navigates back to the ANF entry point
    Then the onboarding flow is presented again from the beginning
    And both the AFib Detection toggle and the Notifications toggle are in the disabled state
    And no partial enrollment data is retained

  @IHRN @New @Notifications @P1
  Scenario: [NEW] ANF-NEW-004 - Push notification received after notification_sent_at reset
    Given the user is enrolled in ANF with both detection and notifications enabled
    And a potential AFib detection event exists for the user
    And the tester has reset the "notification_sent_at" field via the backend
    When approximately 10 minutes have elapsed since the reset
    Then the user receives a push notification for the AFib detection event
    And the notification contains the expected content indicating possible AFib detection
    And tapping the notification navigates the user to the detection detail screen

  @IHRN @New @Analytics @P2
  Scenario: [NEW] ANF-NEW-005 - Amplitude open events fire correctly for ANF screens
    Given the user is enrolled in ANF
    And Amplitude event tracking is active for the test user
    When the user opens the AFib Onboarding screen
    Then an "Afib Onboarding" open event is captured in Amplitude
    When the user opens the ANF Education screen
    Then an "ANF Education" open event is captured in Amplitude
    When the user is navigated to the Possible AFib screen
    Then a "Possible Afib" open event is captured in Amplitude

  @IHRN @New @Analytics @P2
  Scenario: [NEW] ANF-NEW-006 - Amplitude toggle events fire correctly for detection and notification toggles
    Given the user is on the Heart Screener overview screen
    And Amplitude event tracking is active for the test user
    When the user toggles the AFib Detection setting
    Then an "Afib Detection" toggle event is captured in Amplitude with the updated state
    When the user toggles the Arrhythmia Notification setting
    Then an "Arrhythmia Notification" toggle event is captured in Amplitude with the updated state

  @IHRN @New @Analytics @History @P2
  Scenario: [NEW] ANF-NEW-007 - Amplitude confirm events fire on detection history clear actions
    Given the user has AFib detection history
    And Amplitude event tracking is active for the test user
    When the user confirms clearing the full AFib detection history
    Then a "Clear Full History" confirm event is captured in Amplitude
    When the user confirms clearing a single-day AFib detection history entry
    Then a "Clear Date History" confirm event is captured in Amplitude

  @IHRN @New @History @P2
  Scenario: [NEW] ANF-NEW-008 - Detection history detail view shows classification and time period
    Given the user has AFib detection history with at least one recorded event
    When the user taps on a specific detection tile in the history list
    Then the detection detail view is displayed
    And the detail view shows the AFib classification (e.g. "No AFib Detected" or "Possible AFib Detected")
    And the detail view shows the detection time period
    And the detail view shows the date and time the detection was recorded

  @IHRN @New @History @P2
  Scenario: [NEW] ANF-NEW-009 - Clear single-day detection history
    Given the user has AFib detection history spanning multiple days
    When the user selects the option to clear a single day's detection history
    And the user confirms the deletion in the confirmation dialog
    Then only the selected day's detection records are removed
    And detection records for all other days remain intact
    And the history list is updated to reflect the deletion

  @IHRN @New @History @P2
  Scenario: [NEW] ANF-NEW-010 - Clear all detection history with confirmation flow
    Given the user has AFib detection history with multiple recorded events
    When the user selects the option to clear all detection history
    Then a confirmation dialog is displayed asking the user to confirm full history deletion
    When the user confirms the deletion
    Then all AFib detection history records are removed
    And the history screen displays an empty state
    And the cleared history cannot be restored

  @IHRN @New @History @P1
  Scenario: [NEW] ANF-NEW-011 - AFib detection history is preserved after detection toggle is turned off
    Given the user has AFib detection history with multiple recorded events
    And the AFib Detection toggle is currently enabled
    When the user disables the AFib Detection toggle on the Heart Screener overview screen
    Then the AFib Detection toggle moves to the disabled state
    And all previously recorded AFib detection history remains visible in the history view
    And the history is not deleted or cleared as a result of disabling detection

  @IHRN @New @Security @P1
  Scenario: [NEW] ANF-NEW-012 - User cannot access another user's AFib detection data
    Given two separate test users (User A and User B) are both enrolled in ANF
    And User A has recorded AFib detection history
    When User B is authenticated and requests the AFib history API endpoint
    Then the API returns only User B's own AFib detection data
    And User A's detection data is not included in the response
    And no cross-user data leakage occurs at any API layer

  @IHRN @New @Security @P2
  Scenario: [NEW] ANF-NEW-013 - IFU link navigates to the correct WHOOP support article
    Given the user is viewing an ANF-related screen that contains the IFU link
    When the user taps the IFU (Instructions for Use) link
    Then the browser opens to the URL "https://support.whoop.com/s/article/AFib-Notifications"
    And the support article content loads successfully

  @IHRN @New @Security @API @P1
  Scenario: [NEW] ANF-NEW-014 - Unauthenticated API request to AFib history endpoint returns 401
    Given the tester has an API client with no authentication token
    When the tester sends a GET request to the AFib history endpoint
    Then the API responds with HTTP status 401 Unauthorized
    And no AFib detection data is returned in the response body
    And the error response does not expose sensitive system information

  @IHRN @New @History @P2
  Scenario: [NEW] ANF-NEW-015 - Detection history list is grouped by "Month YYYY" headers
    Given the user has AFib detection history spanning multiple calendar months
    When the user views the full detection history list
    Then detection events are grouped under month headers
    And each month header is formatted as "Month YYYY" (e.g. "April 2026")
    And within each month group events are sorted with the most recent detection first
