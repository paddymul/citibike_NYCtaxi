
--"tripduration","starttime","stoptime","start station id","start station name","start station latitude","start station longitude","end station id","end station name","end station latitude","end station longitude","bikeid","usertype","birth year","gender"
--"634","2013-07-01 00:00:00","2013-07-01 00:10:34","164","E 47 St & 2 Ave","40.75323098","-73.97032517","504","1 Ave & E 15 St","40.73221853","-73.98165557","16950","Customer",\N,"0"
drop table citibike_trips;
CREATE TABLE citibike_trips
(
cb_trip_key    serial primary key,
trip_duration integer,
starttime timestamp,
stoptime timestamp,

start_station_id integer,
start_station_name character varying(50),
start_station_latitude float,
start_station_longitude float,
start_station_geom geometry,

end_station_id integer,
end_station_name character varying(50),
end_station_latitude float,
end_station_longitude float,
end_station_geom geometry,

bikeid integer,
usertype character varying(20),
birth_year character varying(20),
gender integer

CONSTRAINT enforce_dims_start_station_geom CHECK (st_ndims(start_station_geom) = 2),
CONSTRAINT enforce_dims_end_station_geom CHECK (st_ndims(end_station_geom) = 2),
CONSTRAINT enforce_geotype_start_station_geom CHECK (geometrytype(start_station_geom) = 'POINT'::text OR start_station_geom IS NULL),
CONSTRAINT enforce_geotype_end_station_geom CHECK (geometrytype(end_station_geom) = 'POINT'::text OR end_station_geom IS NULL),
CONSTRAINT enforce_srid_start_station_geom CHECK (st_srid(start_station_geom) = 4326),
CONSTRAINT enforce_srid_end_station_geom CHECK (st_srid(end_station_geom) = 4326)

)
WITH (
     OIDS=FALSE
);
ALTER TABLE citibike_trips
OWNER TO postgres;
 


CREATE INDEX start_station_geom_gist
ON citibike_trips
USING gist
(start_station_geom);

CREATE INDEX end_station_geom_gist
ON citibike_trips
USING gist
(end_station_geom);




\copy citibike_trips(trip_duration, starttime, stoptime, start_station_id, start_station_name, start_station_latitude, start_station_longitude, end_station_id, end_station_name, end_station_latitude, end_station_longitude, bikeid, usertype, birth_year, gender) FROM '/Users/paddy/code/taxi_citibike/data/cb_short.csv' DELIMITERS ',' CSV HEADER;

UPDATE
citibike_trips
SET
start_station_geom = ST_GeomFromText('POINT(' || start_station_longitude || ' ' || start_station_latitude ||')', 4326);

UPDATE
        citibike_trips
SET
        end_station_geom = ST_GeomFromText('POINT(' || end_station_longitude || ' ' || end_station_latitude ||')', 4326);


SELECT
         ST_Distance(start_station_geom, end_station_geom) AS dist, 
         'https://www.google.com/maps/dir/' ||start_station_latitude || ','|| start_station_longitude || '/' ||  end_station_latitude ||','|| end_station_longitude, 
         trip_duration
FROM
         citibike_trips
ORDER BY
         dist DESC 
LIMIT 30; 
-- ST_Transform(ST_GeomFromText('POINT(-72.1235 42.3521)',4326)
-- ,26986),
