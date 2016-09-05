SELECT      MIN(roads.id) AS id,
            ST_Union(ST_Intersection(roads.geom,county.geom)) AS geom,
            roads.id_rte_no
FROM        statewide_segments roads,
            county_boundary county
WHERE       ST_Intersects(roads.geom,county.geom)
GROUP BY    roads.id_rte_no



one mile segments, taken every 1000 feet (including overlap)



WITH combined_roads AS (
    SELECT      MIN(roads.id) AS id,
                ST_Union(ST_Intersection(roads.geom,county.geom)) AS geom,
                roads.id_rte_no
    FROM        statewide_segments roads,
                county_boundary county
    WHERE       ST_Intersects(roads.geom,county.geom)
    GROUP BY    roads.id_rte_no
)
