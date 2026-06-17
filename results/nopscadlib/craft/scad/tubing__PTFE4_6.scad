// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
outer_diameter = 4; //[2:8:0.1]
inner_diameter = 2; //[1:6:0.1]
forced_id = 0; //[0:6:0.1]
eps = 0.2; //[0.01:1:0.01]

// Smoothness for circular PTFE tube
$fn = 128;

module tubing() {
  od = max(outer_diameter, 0.01);
  id_req = (forced_id > 0) ? forced_id : inner_diameter;

  // Ensure a valid, non-degenerate wall thickness
  min_wall = 0.2;
  id = min(max(id_req, 0), max(od - 2*min_wall, 0));

  // Avoid coincident faces by slightly extending the cutter
  cut_h = length + 2*max(eps, 0.01);

  color([0.85, 0.85, 0.8])
  difference() {
    cylinder(h=length, r=od/2, center=true);
    cylinder(h=cut_h, r=id/2, center=true);
  }
}

module assembly() {
  zoff = (center == 1) ? 0 : (length/2);
  translate([0, 0, zoff]) tubing();
}

assembly();