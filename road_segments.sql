select min(id) as id, st_union(geom) as geom, id_rte_no
from statewide_segments
group by id_rte_no
