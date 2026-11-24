# Walkthrough - MSG91 OTP Service Integration & Fixes

We have resolved the `[firebase_functions/invalid-argument] Mobile no. already verified` error returned by MSG91 when an OTP is verified again (e.g. on retry or double-submission).

## Summary of Fixes

### 1. Handling "Mobile no. already verified" from MSG91 ([index.js](file:///Users/mohdusama/Desktop/Usama Flutter Projects/cherry_on_top/functions/index.js))
- Updated `verifyMsg91Otp` cloud function to treat `"Mobile no. already verified"` response messages from MSG91 as a successful verification.
- Automatically handles existing user lookup in Firebase Auth (`getUserByPhoneNumber`) and generates a secure Firebase Custom Token.

## Deployment Command
```bash
firebase deploy --only functions
```
