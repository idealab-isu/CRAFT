// Neoprene tubing (smooth, visible length, single connected solid)

// Parameters
length = 60; //[7.5:120:0.5]
center = 1; //[0:1:1]
outer_diameter = 10; //[5:20:0.5]
inner_diameter = 6; //[3:18:0.5]
forced_id = 0; //[0:18:0.5]
eps = 0.2; //[0.05:1:0.05]

// Smoothness (reduce faceting)
$fn = max(64, ceil(outer_diameter * 12));

// Tubing
module tubing(len, od, id, e) {
  id_eff = (forced_id > 0) ? forced_id : id;
  id_eff = min(id_eff, od - 2*e); // keep wall thickness positive

  color([0.2, 0.2, 0.2])
  difference() {
    cylinder(d=od, h=len, center=true);
    cylinder(d=id_eff, h=len + 2*e, center=true);
  }
}

// Assembly
module assembly() {
  zpos = (center == 1) ? 0 : (length/2);
  translate([0, 0, zpos])
    tubing(length, outer_diameter, inner_diameter, eps);
}

assembly();