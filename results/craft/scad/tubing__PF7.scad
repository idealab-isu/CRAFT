// Parameters
length_mm = 15; //[8:30:1]
outer_diameter_mm = 4; //[2:8:0.1]
inner_diameter_mm = 2; //[1:6:0.1]
center = 1; //[0:1:1]
eps_overlap_mm = 0.8; //[0.5:2:0.1]

// Smoothness (prevents polygonal look)
$fn = 96;

// PTFE Tubing - cylindrical hollow tube
module tubing() {
  // Basic sanity to avoid invalid/blank geometry
  od = max(outer_diameter_mm, 0.01);
  id = min(max(inner_diameter_mm, 0), od - 0.02); // ensure wall thickness > 0
  len = max(length_mm, 0.01);

  z0 = center ? 0 : len/2;

  color([0.85, 0.85, 0.8])  // Off-white for PTFE
  translate([0, 0, z0])
  difference() {
    cylinder(h=len, r=od/2, center=true);
    cylinder(h=len + 2*eps_overlap_mm, r=id/2, center=true);
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();