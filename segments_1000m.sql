DROP TABLE IF EXISTS segments_1000m;
SELECT  10000000 + (roads.id * 1000) + n AS id,
        roads.tdg_id AS road_tdg_id,
        n AS series,
        ST_Length(geom) AS road_length,
        n * 100 AS seg_start,
        CASE    WHEN    ST_Length(geom) < 900 THEN roads.geom
                ELSE    ST_LineSubstring(
                            roads.geom,
                            (n * 100) / ST_Length(geom),
                            LEAST(((n * 100) + 1000) / ST_Length(geom),1)
                        )
                END AS geom
INTO    segments_1000m
FROM    statewide_segments roads,
        generate_series(0,10000) n
WHERE   (n * 100) < (ST_Length(geom) - 900)
AND     EXISTS (
            SELECT  1
            FROM    county_boundary
            WHERE   ST_Intersects(county_boundary.geom,roads.geom)
);

INSERT INTO segments_1000m (
    id,
    road_tdg_id,
    series,
    geom
)
SELECT  roads.id,
        roads.tdg_id,
        0,
        geom
FROM    statewide_segments roads
WHERE   ST_Length(geom) < 900
AND     NOT roadname LIKE 'RAMP%'
AND     EXISTS (
            SELECT  1
            FROM    county_boundary
            WHERE   ST_Intersects(county_boundary.geom,roads.geom)
);

CREATE INDEX sidx_s100mgeom ON segments_1000m USING GIST (geom);
ANALYZE segments_1000m;
