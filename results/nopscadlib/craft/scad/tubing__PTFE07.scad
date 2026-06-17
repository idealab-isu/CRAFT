// Parameters
length = 15; //[7.5:30:0.5]
outer_diameter = 4; //[2:8:0.1]
inner_diameter = 2; //[1:6:0.1]
forced_id = 0; //[0:10:0.1]
center = 1; //[0:1:1]
eps = 0.8; //[0.2:2:0.1]

$fn = 96;

// Tubing - PTFE sleeving (hollow cylinder)
module tubing() {
  od = max(outer_diameter, 0.01);
  id_req = (forced_id > 0) ? forced_id : inner_diameter;

  // Ensure a printable/visible wall thickness and valid difference
  min_wall = 0.2;
  id = min(max(id_req, 0), max(0, od - 2*min_wall));

  // Avoid degenerate height
  h = max(length, 0.01);

  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=h, r=od/2, center=true);
    cylinder(h=h + 2*eps, r=id/2, center=true);
  }
}

// Assembly
module assembly() {
  // center=1 -> centered at origin; center=0 -> bottom at z=0
  translate([0, 0, (1-center) * (length/2)]) tubing();
}

assembly();