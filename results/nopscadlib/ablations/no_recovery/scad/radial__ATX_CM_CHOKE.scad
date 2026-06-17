// Parameters
r_outer = 17.4; //[8.7:34.8:0.1]
r_step = 11.4; //[5.7:22.8:0.1]
r_hub = 9.0; //[4.5:18.0:0.1]
thickness = 0.5; //[0.25:1.0:0.05]

// Geometry
module outer_disk() {
  cylinder(r=r_outer, h=thickness, center=true);
}

module inner_step() {
  cylinder(r=r_step, h=thickness, center=true);
}

module center_hub() {
  cylinder(r=r_hub, h=thickness, center=true);
}

// Final Union
module stepped_disk_union() {
  union() {
    outer_disk();
    inner_step();
    center_hub();
  }
}

// Render the final geometry
stepped_disk_union();