// PVC aquarium tubing (hollow tube) - fixed to always render visible geometry

// Parameters
length_mm = 15; //[8:30:1]
outer_diameter_mm = 10; //[5:20:0.5]
inner_diameter_mm = 8; //[3:18:0.5]
forced_inner_diameter_mm = 0; //[0:18:0.5]
center = 1; //[0:1:1]
eps_mm = 0.8; //[0.5:2:0.1]

// Smoothness
$fn = 96;

module tubing() {
  od = max(outer_diameter_mm, 0.01);
  id_req = (forced_inner_diameter_mm > 0) ? forced_inner_diameter_mm : inner_diameter_mm;

  // Ensure a non-zero wall thickness so difference() doesn't cancel out (blank render)
  min_wall = max(eps_mm, 0.2);
  id = clamp(id_req, 0, max(0, od - 2*min_wall));

  // Z placement: either centered about origin or sitting on Z=0
  z_shift = (center == 1) ? (-length_mm/2) : 0;

  translate([0, 0, z_shift])
    color([0.85, 0.85, 0.8])
      difference() {
        cylinder(h=length_mm, r=od/2, center=false);

        // Inner bore extends beyond ends for a clean through-hole
        translate([0, 0, -min_wall])
          cylinder(h=length_mm + 2*min_wall, r=id/2, center=false);
      }
}

tubing();