// Parameters
length = 15; //[8:30:1]
outer_diameter = 10; //[5:20:0.5]
inner_diameter = 8; //[4:18:0.5]
forced_id = 0; //[0:18:0.5]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.5]

$fn = 96;

// Tubing - single connected solid (hollow cylinder)
module tubing() {
  od = outer_diameter;
  id_req = (forced_id > 0) ? forced_id : inner_diameter;

  // Keep a minimum wall thickness and avoid degenerate/negative radii
  min_wall = 0.2;
  id_clamped = max(0.2, min(id_req, od - 2*min_wall));

  difference() {
    cylinder(h=length, r=od/2, center=true);
    cylinder(h=length + 2*overlap, r=id_clamped/2, center=true);
  }
}

// Assembly
module assembly() {
  zoff = (center > 0) ? 0 : (length/2);
  translate([0, 0, zoff]) tubing();
}

assembly();