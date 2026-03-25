// PTFE heatshrink sleeving (simple hollow tube) - ONE connected solid

$fn = 96;

// Parameters
material = 1; //[1:1:1]
category = 1; //[1:1:1]
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:0.1]
type_od = 2.4; //[1.2:4.8:0.1]
type_id = 1.6; //[0.8:3.2:0.1]
eps_overlap = 0.8; //[0.5:2:0.1]

// Derived dimensions
id = (forced_id > 0) ? forced_id : type_id;
od = type_od + ((forced_id > 0) ? (forced_id - type_id) : 0);

// Safety / validity
wall_min = 0.2;
od_safe = max(od, id + 2*wall_min);
id_safe = min(id, od_safe - 2*wall_min);

// Tube module (hollow cylinder)
module ptfe_heatshrink_tube() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=od_safe/2, center=(center==1));
    cylinder(h=length + 2*eps_overlap, r=id_safe/2, center=(center==1));
  }
}

ptfe_heatshrink_tube();