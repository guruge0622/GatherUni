# Demo-friendly Firebase Rules

Use these rules for a short demo or local testing. They are permissive and should NOT be used in production.

## Firestore Rules

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    match /users/{userId} {
      allow read, write: if request.auth != null;
    }

    match /events/{eventId} {
      allow read: if true;
      allow create, update, delete: if request.auth != null;
    }

    match /tickets/{ticketId} {
      allow read, write: if request.auth != null;
    }

    match /organizer_requests/{requestId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Storage Rules

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    match /posters/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }

    match /tickets/{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Notes
- These rules allow any authenticated user (including anonymous users) to write to `posters/` and `events/`.
- For production, tighten rules to require organizer role for publishing events and ensure only owners can modify their resources.
- After switching to production rules, revoke any rotated service account keys if they were checked into Git.
