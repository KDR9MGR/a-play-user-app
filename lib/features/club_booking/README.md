# Club Booking Feature

This feature allows users to book tables at clubs through the app.

## Database Setup

To set up the database for this feature, you need to run the SQL queries in `migration_club_tables.sql`. This will:

1. Create a `club_tables` table that stores information about tables available at each club
2. Create a `club_bookings` table that stores reservations made by users
3. Set up appropriate indexes for efficient queries
4. Configure Row Level Security policies to control access
5. Insert sample data for testing

### Running the Migration

You can run the migration through the Supabase dashboard:

1. Go to the SQL Editor in your Supabase project
2. Copy the contents of `migration_club_tables.sql`
3. Run the SQL query

Alternatively, you can use the Supabase CLI to apply the migration:

```bash
supabase migration new club_tables
# Copy SQL into the generated migration file
supabase db push
```

## Updating the App

After applying the migration, the app will use:

1. `club_tables` table instead of `tables`
2. `club_bookings` table instead of using `bookings`

This keeps club table reservations separate from event bookings. 