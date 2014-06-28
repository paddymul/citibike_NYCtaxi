

-- http://www.kevfoo.com/2012/01/Importing-CSV-to-PostGIS/

-- -- DROP TABLE landmarks2;

-- CREATE TABLE landmarks2
-- (
-- gid serial NOT NULL,
-- name character varying(50),
-- address character varying(50),
-- date_built character varying(10),
-- architect character varying(50),
-- landmark character varying(10),
-- the_geom geometry,
-- CONSTRAINT landmarks2_pkey PRIMARY KEY (gid),
-- CONSTRAINT enforce_dims_the_geom CHECK (st_ndims(the_geom) = 2),
-- CONSTRAINT enforce_geotype_geom CHECK (geometrytype(the_geom) = 'POINT'::text OR the_geom IS NULL),
-- CONSTRAINT enforce_srid_the_geom CHECK (st_srid(the_geom) = 4326)
-- )
-- WITH (
-- OIDS=FALSE
-- );
-- ALTER TABLE landmarks2
-- OWNER TO postgres;

-- -- Index: landmarks_the_geom_gist

-- -- DROP INDEX landmarks_the_geom_gist;




DROP TABLE taxi_trips;
CREATE TABLE taxi_trips
(
mytable_key    serial primary key,
        medallion character varying(50),
        hack_license  character varying(50),
        vendor_id  character varying(50),
        rate_code  character varying(50),
        store_and_fwd_flag  character varying(50),
        pickup_datetime timestamp,
        dropoff_datetime timestamp,
        passenger_count integer,
        trip_time_in_secs integer,
        trip_distance float,
        pickup_longitude float,
        pickup_latitude float,
        dropoff_longitude float,
        dropoff_latitude float,
        pickup_geom geometry,
        dropoff_geom geometry,

CONSTRAINT enforce_dims_pickup_geom CHECK (st_ndims(pickup_geom) = 2),
CONSTRAINT enforce_dims_dropoff_geom CHECK (st_ndims(dropoff_geom) = 2),
CONSTRAINT enforce_geotype_pickup_geom CHECK (geometrytype(pickup_geom) = 'POINT'::text OR pickup_geom IS NULL),
CONSTRAINT enforce_geotype_dropoff_geom CHECK (geometrytype(dropoff_geom) = 'POINT'::text OR dropoff_geom IS NULL),
CONSTRAINT enforce_srid_pickup_geom CHECK (st_srid(pickup_geom) = 4326),
CONSTRAINT enforce_srid_dropoff_geom CHECK (st_srid(dropoff_geom) = 4326)

)
WITH (
     OIDS=FALSE
);
ALTER TABLE taxi_trips
OWNER TO postgres;
 

-- CREATE INDEX pickup_geom_gist
-- ON taxi_trips
-- USING gist
-- (pickup_geom);

-- CREATE INDEX dropoff_geom_gist
-- ON taxi_trips
-- USING gist
-- (dropoff_geom);




copy taxi_trips(medallion,hack_license,vendor_id,rate_code,store_and_fwd_flag,pickup_datetime,dropoff_datetime,passenger_count,trip_time_in_secs,trip_distance,pickup_longitude,pickup_latitude,dropoff_longitude,dropoff_latitude) FROM '/Users/paddy/code/citibike_NYCtaxi/data/short_trip_data.csv' DELIMITERS ',' CSV HEADER;
--\copy taxi_trips(medallion,hack_license,vendor_id,rate_code,store_and_fwd_flag,pickup_datetime,dropoff_datetime,passenger_count,trip_time_in_secs,trip_distance,pickup_longitude,pickup_latitude,dropoff_longitude,dropoff_latitude) FROM '/Users/paddy/code/taxi_citibike/data/trip_data_1.csv'  DELIMITERS ',' CSV HEADER;


UPDATE
taxi_trips
SET
pickup_geom = ST_GeomFromText('POINT(' || pickup_longitude || ' ' || pickup_latitude ||')', 4326);

UPDATE
        taxi_trips
SET
        dropoff_geom = ST_GeomFromText('POINT(' || dropoff_longitude || ' ' || dropoff_latitude ||')', 4326);


SELECT
         ST_Distance(pickup_geom, dropoff_geom) AS dist, 
         'https://www.google.com/maps/dir/' ||pickup_latitude || ','|| pickup_longitude || '/' ||  dropoff_latitude ||','|| dropoff_longitude, 
         trip_distance, 
         trip_time_in_secs, 
         passenger_count, 
         pickup_datetime 
FROM
         taxi_trips
ORDER BY
         trip_distance DESC 
LIMIT 30; 
-- ST_Transform(ST_GeomFromText('POINT(-72.1235 42.3521)',4326)
-- ,26986),
