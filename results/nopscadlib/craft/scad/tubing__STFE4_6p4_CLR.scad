// PTFE heatshrink sleeving (hollow tube) with a lead passing through (one connected solid)

// Parameters
length = 15; //[8:30:1]
original_id = 2; //[1:6:0.1]
original_od = 3; //[1.5:9:0.1]
forced_id = 0; //[0:6:0.1]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]
lead_radius = 0.4; //[0.2:1:0.05]
lead_length = 6; //[3:15:1]

// Smooth cylinders (avoid faceted/pentagonal look)
$fn = 96;

// Derived dimensions
id = (forced_id > 0) ? forced_id : original_id;
od = original_od + (id - original_id);          // keep wall thickness consistent when forced_id changes
od_safe = max(od, id + 0.2);                    // ensure OD > ID
r_in = id / 2;
r_out = od_safe / 2;

// Z placement
z0 = (center > 0) ? 0 : length/2;

// Tubing (hollow)
module tubing() {
  color([0.85, 0.85, 0.8])  // off-white PTFE
  difference() {
    translate([0,0,z0]) cylinder(h=length, r=r_out, center=true);
    translate([0,0,z0]) cylinder(h=length + 2*overlap, r=r_in, center=true);
  }
}

// Lead through the bore (ensures ONE connected solid via overlap inside tube)
module lead_through() {
  color([0.2, 0.2, 0.2])
  translate([0,0,z0])
    cylinder(h=length + lead_length, r=lead_radius, center=true);
}

// Assembly: union makes a single connected solid
union() {
  tubing();
  lead_through();
}