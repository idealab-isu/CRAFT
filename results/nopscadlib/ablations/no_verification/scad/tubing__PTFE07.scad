// Parameters
length = 15; //[8:30:1]
outer_diameter = 4; //[2:8:0.5]
inner_diameter = 2; //[1:6:0.5]
center = 1; //[0:1:1]
forced_id = 0; //[0:6:0.5]
eps_overlap = 0.8; //[0.5:2:0.1]

$fn = 96;

// Tubing - PTFE sleeving (single connected solid)
module tubing() {
  od = max(outer_diameter, 0.01);
  id_req = (forced_id > 0) ? forced_id : inner_diameter;

  // Ensure a valid, visible wall thickness and non-negative ID
  min_wall = 0.2;
  id = min(max(id_req, 0), max(0, od - 2*min_wall));

  // Positioning: if centered, keep at origin; if not, sit on Z=0 plane
  zc = (center == 1) ? 0 : length/2;

  color([0.85, 0.85, 0.8])
  translate([0, 0, zc])
  difference() {
    cylinder(h=length, r=od/2, center=true);
    cylinder(h=length + 2*eps_overlap, r=id/2, center=true);
  }
}

tubing();