SELECT
        (SELECT count(*) FROM taxi_trips) AS total_trips,
        (SELECT count(distinct taxi_trip_id) FROM similar_taxi_trips) AS equivalent_trip_count,
        ((SELECT count(distinct taxi_trip_id) FROM similar_taxi_trips)/
        ((SELECT count(*) FROM taxi_trips)+0.0001)) AS EQUIV_PERCENTAGE;
        

SELECT COUNT(*) FROM 
       citibike_trips AS cbt,
       similar_taxi_trips AS stt
WHERE
        stt.start_station_id  = cbt.start_station_id AND
        stt.end_station_id  = cbt.end_station_id;


CREATE TABLE citibike_trip_short AS
SELECT
        cbt.start_station_id, cbt.end_station_id,       
        cbt.trip_duration AS cb_trip_duration,
        cbt.starttime AS cb_starttime,
        cbt.gender
FROM 
        citibike_trips AS cbt;
       
CREATE INDEX cbshort_start_end_idx ON citibike_trip_short (start_station_id, end_station_id);           

DROP TABLE citibike_agg_stat;
CREATE TABLE citibike_agg_stat AS
SELECT
       cbt.start_station_id, cbt.end_station_id,
       AVG(cbt.cb_trip_duration) AS cb_trip_duration,
       count(*) as cb_trip_count
FROM 
       citibike_trip_short AS cbt
GROUP BY
      cbt.start_station_id, cbt.end_station_id;

CREATE TABLE taxi_agg_stat AS 
SELECT
        stt.start_station_id, stt.end_station_id, count(*) AS tt_trip_count,
        AVG(taxi_trips.trip_time_in_secs) AS avg_taxi_time
FROM
        similar_taxi_trips AS stt,
        taxi_trips
WHERE
        stt.taxi_trip_id = taxi_trips.taxi_trip_id
GROUP BY
        stt.start_station_id, stt.end_station_id;

CREATE INDEX tas_start_end_idx ON taxi_agg_stat (start_station_id, end_station_id);
CREATE INDEX cas_start_end_idx ON citibike_agg_stat (start_station_id, end_station_id);

SELECT
        tas.start_station_id, tas.end_station_id,
        ROUND(tas.avg_taxi_time,2), ROUND(cas.cb_trip_duration,2), 
        ROUND(cas.cb_trip_duration -tas.avg_taxi_time,  2) AS diff,
        tas.tt_trip_count, cas.cb_trip_count
FROM
        citibike_agg_stat AS cas,
        taxi_agg_stat AS tas
WHERE                   
        tas.start_station_id  = cas.start_station_id AND
        tas.end_station_id  = cas.end_station_id AND 
        cas.start_station_id <> cas.end_station_id AND
        tt_trip_count > 10 AND
        cb_trip_count > 10
ORDER BY diff
LIMIT 50;


SELECT
        tas.start_station_id, tas.end_station_id,
        sum(cb_trip_count), sum(tas.tt_trip_count)
FROM
        citibike_agg_stat AS cas,
        taxi_agg_stat AS tas
WHERE                   
        tas.start_station_id  = cas.start_station_id AND
        tas.end_station_id  = cas.end_station_id AND 
        cas.start_station_id <> cas.end_station_id AND
        tt_trip_count > 10 AND
        cb_trip_count > 10 AND
        (cas.cb_trip_duration - tas.avg_taxi_time) < 0;



SELECT
        SUM(cb_trip_count) AS cb_trips, SUM(tas.tt_trip_count) AS taxi_trips, SUM(cb_trip_count) /  2556902.0 as percentile
FROM
        citibike_agg_stat AS cas,
        taxi_agg_stat AS tas
WHERE                   
        tas.start_station_id  = cas.start_station_id AND
        tas.end_station_id  = cas.end_station_id AND 
        cas.start_station_id <> cas.end_station_id AND
        tt_trip_count > 10 AND
        cb_trip_count > 10 AND
        (cas.cb_trip_duration - tas.avg_taxi_time) < 360;


SELECT
        tas.start_station_id AS start_id, tas.end_station_id AS end_id,
        ROUND(tas.avg_taxi_time,2) AS avg_taxi, ROUND(cas.cb_trip_duration,2) AS avg_cb, 
        ROUND(cas.cb_trip_duration -tas.avg_taxi_time,  2) AS diff,
        tas.tt_trip_count AS tt_cnt, cas.cb_trip_count AS cb_cnt
FROM
        citibike_agg_stat AS cas,
        taxi_agg_stat AS tas
WHERE                   
        tas.start_station_id  = cas.start_station_id AND
        tas.end_station_id  = cas.end_station_id AND 
        cas.start_station_id <> cas.end_station_id AND
        tt_trip_count > 10 AND
        cb_trip_count > 10
ORDER BY diff
LIMIT 50;


SELECT
        stt.start_station_id, stt.end_station_id, count(*) AS cnt,
        (SELECT COUNT(*) 
        FROM citibike_trips AS cbt1 
        WHERE cbt1.start_station_id = citibike_trips.start_station_id AND 
        cbt1.end_station_id = citibike_trips.end_station_id) AS cb_trip_count,
        round(avg(taxi_trips.trip_time_in_secs),2) AS avg_taxi_time,
        round(avg(citibike_trips.trip_duration),2) AS avg_cb_time,
        round(avg(citibike_trips.trip_duration) - avg(taxi_trips.trip_time_in_secs),2) AS time_diff,
        'https://www.google.com/maps/dir/' || cs1.latitude || ','|| cs1.longitude || '/' ||  cs2.latitude ||','|| cs2.longitude
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
        cb_trip_count DESC 
LIMIT 30;
