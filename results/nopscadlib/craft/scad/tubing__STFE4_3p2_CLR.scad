// PTFE heatshrink sleeving (standalone hollow tube)

// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:1]
tubing_id = 2; //[1:6:0.5]
wall_thickness = 0.3; //[0.15:0.8:0.05]
eps = 0.2; //[0.1:0.5:0.05]

$fn = 96;

id = (forced_id > 0) ? forced_id : tubing_id;
ir = id/2;
or = ir + wall_thickness;

module ptfe_heatshrink_sleeving() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(r=or, h=length, center=center);
    // Inner void slightly extended to guarantee a clean through-hole
    translate([0, 0, center ? 0 : -eps])
      cylinder(r=ir, h=length + 2*eps, center=center);
  }
}

ptfe_heatshrink_sleeving();