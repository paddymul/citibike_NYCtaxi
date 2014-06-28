SELECT
        start_station_id, end_station_id, count(*) AS cnt 
FROM
        similar_taxi_trips 
GROUP BY
        start_station_id, end_station_id 
ORDER BY
        cnt DESC 
LIMIT 30;
