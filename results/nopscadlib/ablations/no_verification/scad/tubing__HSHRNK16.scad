// Heatshrink sleeving / tubing (single connected solid)

// Parameters
length = 15; //[8:30:1]
original_id = 2.0; //[1.0:4.0:0.1]
original_od = 3.2; //[1.6:6.4:0.1]
forced_id = 0; //[0:6:0.1]
center = true; //[0:1:1]
overlap = 0.8; //[0.5:2:0.1]

// Smoothness for round tube (avoid hex/prismatic look)
$fn = 96;

// Derived dimensions
id = (forced_id > 0) ? forced_id : original_id;
od = (forced_id > 0) ? (original_od + (forced_id - original_id)) : original_od;

// Ensure valid wall thickness and non-empty geometry
min_wall = 0.25;
od_safe = max(od, id + 2*min_wall);
id_safe = min(id, od_safe - 2*min_wall);

module tubing() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=od_safe/2, center=center);
    cylinder(h=length + 2*overlap, r=id_safe/2, center=center);
  }
}

// One connected solid: just the tube (no floating/extra parts)
tubing();