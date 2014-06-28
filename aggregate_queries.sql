SELECT
        (SELECT count(*) FROM taxi_trips) AS total_trips,
        (SELECT count(distinct taxi_trip_id) FROM similar_taxi_trips) AS equivalent_trip_count,
        ((SELECT count(distinct taxi_trip_id) FROM similar_taxi_trips)/
        ((SELECT count(*) FROM taxi_trips)+0.0001)) AS EQUIV_PERCENTAGE;
        
        

SELECT
        stt.start_station_id, stt.end_station_id, count(*) AS cnt,
        avg(taxi_trips.trip_time_in_secs) AS avg_taxi_time,
        avg(citibike_trips.trip_duration) AS avg_cb_time,
        avg(citibike_trips.trip_duration) - avg(taxi_trips.trip_time_in_secs) AS time_diff,
        'https://www.google.com/maps/dir/' || cs1.latitude || ','|| cs1.longitude || '/' ||  cs2.latitude ||','|| cs2.longitude,
        (SELECT COUNT(*) 
         FROM citibike_trips AS cbt1 
         WHERE cbt1.start_station_id = citibike_trips.start_station_id AND 
         cbt1.end_station_id = citibike_trips.end_station_id) AS cb_trip_count
FROM
        similar_taxi_trips AS stt,
        taxi_trips,
        citibike_trips,
        citibike_stations as cs1,
        citibike_stations as cs2

WHERE
        stt.taxi_trip_id = taxi_trips.taxi_trip_id AND
        stt.start_station_id  = citibike_trips.start_station_id AND
        stt.end_station_id  = citibike_trips.end_station_id AND
        cs1.station_id = stt.start_station_id AND
        cs2.station_id = stt.end_station_id
GROUP BY
        stt.start_station_id, stt.end_station_id,
        cs1.latitude, cs1.longitude, cs2.latitude, cs2.longitude,
        cb_trip_count
ORDER BY
        cnt DESC 
LIMIT 30;
