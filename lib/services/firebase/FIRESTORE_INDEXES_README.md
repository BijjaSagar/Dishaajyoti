# Firestore Indexes

This document explains the Firestore composite indexes required for the Firebase migration.

## Defined Indexes

The following composite indexes are defined in `firestore.indexes.json`:

### Reports Collection

1. **userId + createdAt (descending)**
   - Used for: Getting all reports for a user, ordered by creation date
   - Query: `getUserReports(userId)`

2. **userId + status + createdAt (descending)**
   - Used for: Getting reports by status for a user, ordered by creation date
   - Query: `getUserReportsByStatus(userId, status)`

3. **serviceType + status**
   - Used for: Admin queries to get reports by service type and status
   - Query: Future admin dashboard functionality

### Orders Collection

1. **userId + createdAt (descending)**
   - Used for: Getting all orders for a user, ordered by creation date
   - Query: `getUserOrders(userId)`

2. **status + createdAt (descending)**
   - Used for: Admin queries to get orders by status
   - Query: Future admin dashboard functionality

## Deploying Indexes

To deploy the indexes to Firebase, use the Firebase CLI:

```bash
# Make sure you're in the project root directory
cd Dishaajyoti

# Deploy only Firestore indexes
firebase deploy --only firestore:indexes

# Or deploy all Firestore rules and indexes
firebase deploy --only firestore
```

## Automatic Index Creation

Firebase will also automatically suggest indexes when you run queries that require them. You can:

1. Run the app and execute queries
2. Check the Firebase Console for index creation suggestions
3. Click the provided link to automatically create the index

## Monitoring Indexes

You can view and manage indexes in the Firebase Console:

1. Go to Firebase Console
2. Select your project
3. Navigate to Firestore Database
4. Click on "Indexes" tab

## Index Build Time

- Simple indexes: Usually build within minutes
- Complex indexes with large datasets: May take hours
- You'll receive an email when index building is complete

## Testing with Emulator

To test indexes locally with the Firebase Emulator:

```bash
# Start the Firestore emulator
firebase emulators:start --only firestore

# The emulator will automatically use the indexes defined in firestore.indexes.json
```

## Notes

- Indexes are required for compound queries (multiple where clauses)
- Indexes are required for orderBy with where clauses
- Single-field queries don't require composite indexes
- Each index increases write costs slightly but improves read performance significantly
