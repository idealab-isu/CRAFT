// PTFE heatshrink sleeving (simple hollow tube) - single connected solid

// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:0.5]
center = true; //[0:1:1]
original_od = 3.2; //[1.6:6.4:0.1]
original_id = 2.0; //[1.0:4.0:0.1]
eps_overlap = 0.8; //[0.5:2:0.1]

$fn = 96;

// Derived dimensions
id = (forced_id > 0) ? forced_id : original_id;
od = original_od + ((forced_id > 0) ? (forced_id - original_id) : 0);

// Safety clamps to avoid invalid/blank geometry
min_wall = 0.2;
od_safe = max(od, id + 2*min_wall);
id_safe = min(id, od_safe - 2*min_wall);

module ptfe_heatshrink_sleeve() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=od_safe/2, center=center);
    cylinder(h=length + 2*eps_overlap, r=id_safe/2, center=center);
  }
}

ptfe_heatshrink_sleeve();