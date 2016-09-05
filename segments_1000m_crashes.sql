DROP TABLE IF EXISTS segments_1000m_crashes;
WITH pre AS (
    SELECT  segments_1000m.id,
            segments_1000m.geom,
            segments_1000m.road_tdg_id,
            (
                SELECT  COUNT(ped.id)
                FROM    severe_ped_crashes_2012_to_2015 ped
                WHERE   segments_1000m.geom <#> ped.geom <= 50
                AND     ST_Intersects(ST_Buffer(segments_1000m.geom,50),ped.geom)
            ) AS ped_count,
            (
                SELECT  COUNT(veh.id)
                FROM    severe_veh_crashes_2012_to_2015 veh
                WHERE   segments_1000m.geom <#> veh.geom <= 50
                AND     ST_Intersects(ST_Buffer(segments_1000m.geom,50),veh.geom)
            ) AS veh_count,
            ST_Length(segments_1000m.geom) AS length_m
    FROM    segments_1000m
)

SELECT  id,
        geom,
        road_tdg_id,
        ped_count,
        veh_count,
        ped_count + veh_count AS combined_count,
        length_m,
        1000 * ped_count::FLOAT / length_m AS ped_count_per_km,
        1000 * veh_count::FLOAT / length_m AS veh_count_per_km,
        1000 * (ped_count + veh_count)::FLOAT / length_m AS combined_count_per_km,
        rank() OVER (ORDER BY 1000 * ped_count::FLOAT / length_m DESC) AS ped_rank_per_km,
        rank() OVER (ORDER BY 1000 * veh_count::FLOAT / length_m DESC) AS veh_rank_per_km,
        rank() OVER (ORDER BY 1000 * (ped_count + veh_count)::FLOAT / length_m DESC) AS combined_rank_per_km
INTO    segments_1000m_crashes
FROM    pre
WHERE   ped_count + veh_count > 0;

CREATE INDEX sidx_s1000mcrashgeom ON segments_1000m_crashes USING GIST (geom);
ANALYZE segments_1000m_crashes;
