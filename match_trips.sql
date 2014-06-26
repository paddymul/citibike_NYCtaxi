
SELECT
ST_Distance(cb.start_station_geom, taxi.pickup_geom) AS start_dist,  
ST_Distance(cb.end_station_geom, taxi.dropoff_geom) AS end_dist, 
'https://www.google.com/maps/dir/' ||pickup_latitude || ','|| pickup_longitude || '/' ||  dropoff_latitude ||','|| dropoff_longitude, 
cb.trip_duration,
taxi.trip_time_in_secs
FROM
citibike_trips as cb,
taxi_trips as taxi
WHERE cb.start_station_id = 164 AND
cb.end_station_id = 237
ORDER BY
(ST_Distance(cb.start_station_geom, taxi.pickup_geom) + ST_Distance(cb.end_station_geom, taxi.dropoff_geom))
LIMIT 30; 

