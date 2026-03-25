// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:0.5]
center = true; //[0:1:1]
original_id = 3; //[1.5:6:0.5]
original_od = 5; //[2.5:10:0.5]
eps_overlap = 1; //[0.5:2:0.1]
resistor_body_d = 2.5; //[1.5:5:0.1]
resistor_body_l = 6.5; //[4:12:0.1]
lead_d = 0.6; //[0.3:1.2:0.05]
bare_lead_each_side = 5; //[2:12:0.5]

// Smooth, round tubing
$fn = 96;

// Derived dimensions
id = (forced_id > 0) ? forced_id : original_id;
od = original_od + ((forced_id > 0) ? (forced_id - original_id) : 0;

// Ensure valid wall thickness
wall_min = 0.25;
od_safe = max(od, id + 2*wall_min);

// Connectivity overlap (1-2mm as required)
conn_ov = 1.0;

// Outer heatshrink tube (hollow)
module tubing() {
  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=od_safe/2, center=center);
    cylinder(h=length + 2*eps_overlap, r=id/2, center=center);
  }
}

// Inner core/rod that MUST be physically attached to the tube.
// Make it slightly larger than the tube ID so it intersects the tube wall by conn_ov.
module inner_core_attached() {
  // Ensure the core radius is at least (id/2 + conn_ov) so it overlaps the tube wall.
  core_r = id/2 + conn_ov;

  // Keep the core within the tube length (no axial floating); center it with the tube.
  // Slightly shorter than tube to avoid protruding unless desired.
  core_h = length - 2*conn_ov;

  color([0.2, 0.35, 0.65])
    cylinder(h=core_h, r=core_r, center=center);
}

module assembly() {
  // Single connected solid: tube + attached inner core
  union() {
    tubing();
    inner_core_attached();
  }
}

assembly();