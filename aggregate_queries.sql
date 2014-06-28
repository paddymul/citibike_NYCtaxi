SELECT
        stt.start_station_id, stt.end_station_id, count(*) AS cnt,
        avg(taxi_trips.trip_time_in_secs) AS avg_taxi_time,
        avg(citibike_trips.trip_duration) AS avg_cb_time,
        avg(citibike_trips.trip_duration) - avg(taxi_trips.trip_time_in_secs) AS time_diff
FROM
        similar_taxi_trips AS stt,
        taxi_trips,
        citibike_trips
WHERE
        stt.taxi_trip_id = taxi_trips.taxi_trip_id AND
        stt.start_station_id  = citibike_trips.start_station_id AND
        stt.end_station_id  = citibike_trips.end_station_id 
GROUP BY
        stt.start_station_id, stt.end_station_id 
ORDER BY
        cnt DESC 
LIMIT 30;
