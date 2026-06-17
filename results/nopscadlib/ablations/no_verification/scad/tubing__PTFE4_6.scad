// PTFE Tubing (single connected solid)

// Parameters
length = 15; //[7.5:30:0.5]
outer_diameter = 4; //[2:8:0.1]
inner_diameter = 2; //[1:6:0.1]
forced_id = 0; //[0:6:0.1]
center = 1; //[0:1:1]
eps = 0.8; //[0.5:2:0.1]

$fn = 96;

module tubing() {
  od = outer_diameter;
  id = (forced_id > 0) ? forced_id : inner_diameter;

  // Keep a guaranteed positive wall thickness
  min_wall = 0.2;
  id_safe = max(0, min(id, od - 2*min_wall));
  od_safe = max(od, id_safe + 2*min_wall);

  // Correct centering: if not centered, place base at z=0
  z_shift = center ? 0 : length/2;

  color([0.85, 0.85, 0.8])
  translate([0, 0, z_shift])
    difference() {
      cylinder(h=length, r=od_safe/2, center=true);
      // Slightly longer cut to ensure a clean through-hole
      cylinder(h=length + 2*eps, r=id_safe/2, center=true);
    }
}

tubing();