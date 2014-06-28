This is a very early take on putting the citbike nyc trip data together with the taxi trip data that has been released.

I'm looking to compare equivalent taxi trips to citibike trips.

This requires http://www.postgresql.org/ with the postgis extensions.

I downloaded data from http://www.andresmh.com/nyctaxitrips/ and http://www.citibikenyc.com/system-data

I run the scripts like this.

```

cat initial_creation.sql | psql -U postgres cb_taxi
cat create_tables.sql | psql -U postgres cb_taxi
cat create_citibike_table.sql | psql -U postgres cb_taxi
cat aggregate_queries.sql | psql -U postgres cb_taxi

```

This is very early alpha and not cleaned up.  suggestions welecome.
