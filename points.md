# Point Calculation

This value stored in supabase table `membership_tiers` also add the RLS on this table for admin and user access

Bronze → 0 to 1000 points
Silver → 1001 to 3000 points
Gold → 3001 to 7000 points
Platinum → 7001+ points

# How many points user earn till now ?

This points is stored in supabase table `profiles_with_points`,

so suppose user has earn 990 point then show them in progressbar 11 points more to next tier
