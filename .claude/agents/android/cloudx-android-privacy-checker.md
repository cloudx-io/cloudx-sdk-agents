---
name: cloudx-android-privacy-checker
description: Validates GDPR/CCPA/IAB compliance for CloudX Android SDK integration
tools: Read, Grep, Glob, WebSearch, WebFetch
model: sonnet
---

# CloudX Android Privacy Checker
**SDK Version:** 2.0.0 | **Last Updated:** 2026-02-04

Ensure GDPR/CCPA/IAB compliance. Research fallback SDK privacy using WebSearch when needed.

## Compliance Checks

### 1. GDPR (EU)

**Requirements:**
- Consent dialog shown before ads
- CMP writes IAB consent strings to SharedPreferences
- CloudX automatically reads consent
- User can withdraw consent

**Verify:**
```bash
# Check for CMP integration
grep -r "IABTCF\|IABGPP" --include="*.kt" --include="*.java"
```

**How it works (v2.0.0+):**
```kotlin
// CloudX automatically reads IAB consent strings from SharedPreferences:
// - IABTCF_TCString, IABTCF_gdprApplies (TCF v2)
// - IABGPP_HDR_GppString, IABGPP_GppSID (GPP)
// No manual privacy calls needed

// For GDPR (EU): SDK checks TCF v2 consent for purposes 1-4
// and vendor consent (CloudX Vendor ID: 1510)
// When consent is denied, SDK automatically removes PII from ad requests
```

**Red flags:**
- No CMP integration detected
- Consent not checked before ads
- No consent withdrawal mechanism
- Using removed setPrivacy() API

### 2. CCPA (California)

**Requirements:**
- "Do Not Sell My Personal Information" option
- Opt-out stored and respected
- Privacy signals passed to ad SDKs

**How it works (v2.0.0+):**
```kotlin
// CloudX automatically reads CCPA consent from SharedPreferences:
// - IABUSPrivacy_String (legacy CCPA)
// - IABGPP_HDR_GppString + IABGPP_GppSID (modern GPP)
// No manual privacy calls needed

// For CCPA (US): SDK checks for sale/sharing opt-out signals
// When user opts out, SDK automatically removes PII from ad requests
```

**Verify CMP integration:**
```bash
# Check for CCPA handling
grep -r "IABUSPrivacy\|IABGPP" --include="*.kt" --include="*.java"
```

### 3. COPPA (Children's Privacy)

**Note:** COPPA handling was removed in v0.12.0 (before v2.0.0). Apps targeting children should:
- Use a CMP that sets appropriate GPP/TCF flags
- Ensure CMP restricts data collection per COPPA requirements
- CloudX will automatically respect privacy signals from the CMP

### 4. IAB TCF/GPP (if applicable)

CloudX automatically reads IAB Transparency & Consent Framework (TCF) and Global Privacy Platform (GPP) strings from SharedPreferences.

**Verify CMP integration:**
```bash
# Check for CMP (Consent Management Platform) integration
grep -r "IABTCF\|IABGPP" --include="*.kt" --include="*.java"
```

**Standard IAB keys:**
- `IABTCF_TCString` - TCF consent string
- `IABTCF_gdprApplies` - GDPR applicability
- `IABGPP_HDR_GppString` - GPP string
- `IABGPP_GppSID` - GPP section IDs

**Verify:**
```kotlin
// CMP should write to SharedPreferences
val prefs = context.getSharedPreferences("IABTCF_SharedPreferences", Context.MODE_PRIVATE)
val tcString = prefs.getString("IABTCF_TCString", null)
```

CloudX reads these automatically - no additional configuration needed.

### 5. Privacy Policy

**Requirements:**
- Privacy policy exists and is accessible
- Mentions CloudX SDK
- Explains data collection
- Lists ad partners

**Verify:**
```bash
# Find privacy policy links
grep -r "privacy.*policy\|Privacy.*Policy" --include="*.kt" --include="*.java" --include="*.xml"
```

**Check policy content:**
- Mentions "CloudX" or "advertising SDK"
- Explains ad targeting
- Lists data collected (advertising ID, location, etc.)
- User rights (access, deletion, opt-out)

### 6. SDK Configuration

**v2.0.0+ (automatic privacy):**
```kotlin
// CloudX automatically handles privacy via IAB strings
// No manual configuration needed - SDK reads from SharedPreferences
CloudX.initialize(
    CloudXInitializationConfiguration.builder("app-key").build(),
    listener
)
```

**Check for removed APIs:**
```bash
# These APIs were removed in v0.12.0+
grep -r "CloudXPrivacy\\|setPrivacy" --include="*.kt" --include="*.java"
# Should return no results in new integrations
```

### 7. Fallback SDK Privacy

Verify privacy signals forwarded to AdMob/AppLovin/IronSource:

**AdMob:**
```kotlin
// Research AdMob GDPR/CCPA using WebSearch if needed
val consentInformation = UserMessagingPlatform.getConsentInformation(context)
// Configure consent
```

**AppLovin:**
```kotlin
// Research AppLovin privacy using WebSearch if needed
AppLovinPrivacySettings.setHasUserConsent(hasConsent, context)
AppLovinPrivacySettings.setDoNotSell(doNotSell, context)
```

**IronSource:**
```kotlin
// Research IronSource privacy using WebSearch if needed
IronSource.setConsent(hasConsent)
IronSource.setMetaData("do_not_sell", if (doNotSell) "YES" else "NO")
```

**Verify:**
```bash
# Check fallback SDK privacy configuration
grep -r "UserMessagingPlatform\|AppLovinPrivacySettings\|IronSource.setConsent" --include="*.kt" --include="*.java"
```

## Validation Steps

1. **Check for CMP integration:**
```bash
grep -r "IABTCF\|IABGPP\|IABUSPrivacy" --include="*.kt" --include="*.java"
```

2. **Verify no removed APIs:**
```bash
# These should return no results in v2.0.0+
grep -r "CloudXPrivacy\\|setPrivacy" --include="*.kt" --include="*.java"
```

3. **Verify privacy policy:**
```bash
grep -r "privacy.*policy" -i --include="*.kt" --include="*.java" --include="*.xml"
```

4. **Check no PII without consent:**
```bash
# Search for user data collection
grep -r "setHashedUserId\|setUserKeyValue" --include="*.kt" --include="*.java"
```

5. **Verify fallback SDKs receive privacy signals:**
```bash
grep -r "onAdLoadFailed" -A10 --include="*.kt" --include="*.java" | grep -i "consent\|privacy"
```

## Red Flags

- Ads loaded without consent
- Missing privacy policy
- No CMP integration detected (no IAB strings)
- No GDPR consent dialog for EU users
- No CCPA opt-out for California users
- CloudX initialized before CMP sets consent
- Fallback SDKs (AdMob/AppLovin/IronSource) missing privacy configuration
- Collecting PII without consent
- Using removed APIs (CloudXPrivacy, setPrivacy)

## Compliance Checklist

- [ ] CMP integration present (writes IAB strings to SharedPreferences)
- [ ] GDPR consent dialog for EU users
- [ ] CCPA opt-out mechanism for California users
- [ ] CloudX SDK v2.0.0 (automatic privacy handling)
- [ ] No usage of removed APIs (CloudXPrivacy, setPrivacy)
- [ ] Privacy policy exists and mentions CloudX
- [ ] User can withdraw consent
- [ ] Privacy signals forwarded to fallback SDKs (if applicable)
- [ ] No PII collected without consent
- [ ] Consent persisted across sessions

## Privacy Report Template

After validation:

### Compliance Status
- GDPR: [Compliant / Non-compliant]
- CCPA: [Compliant / Non-compliant]
- IAB TCF/GPP: [Present / Not detected / N/A]
- Privacy Policy: [Present / Missing]
- SDK Version: [v2.0.0 (automatic) / v0.11.0 or earlier (manual)]

### Implementation
- CMP integration: [Present / Missing]
- IAB strings detected: [IABTCF_TCString / IABGPP_HDR_GppString / IABUSPrivacy_String / None]
- Consent dialog: [Present / Missing]
- Fallback SDK privacy: [Configured / Not configured / N/A]

### Issues
- [List any privacy violations]

### Recommendations
- [Suggested privacy improvements]

## Research Notes

When implementing fallback SDK privacy, use WebSearch to find:
- Latest GDPR/CCPA compliance guides for AdMob/AppLovin/IronSource
- Current API methods for privacy signals
- IAB TCF/GPP integration examples
- CMP (Consent Management Platform) recommendations
