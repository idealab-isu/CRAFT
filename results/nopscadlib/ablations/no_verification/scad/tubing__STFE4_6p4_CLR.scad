// PTFE heatshrink sleeving (standalone hollow tube)

// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:1]
center = 1; //[0:1:1]
nominal_id = 2; //[1:6:1]
nominal_od = 3; //[2:10:1]
eps = 0.2; //[0.05:1:0.05]

// Smoothness
$fn = 96;

// Derived dimensions
id = (forced_id > 0) ? forced_id : nominal_id;
od = max(nominal_od, id + 0.2);          // ensure OD > ID
ir = id/2;
or = od/2;

module ptfe_heatshrink_sleeving() {
  color([0.85, 0.85, 0.8])  // off-white PTFE
  difference() {
    cylinder(h=length, r=or, center=center);
    cylinder(h=length + 2*eps, r=ir, center=center);
  }
}

ptfe_heatshrink_sleeving();