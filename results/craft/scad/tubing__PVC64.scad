// Parameters
length_mm = 15; //[8:30:1]
outer_diameter_mm = 10; //[5:20:0.5]
inner_diameter_mm = 8; //[4:18:0.5]
center = 1; //[0:1:1]
eps_overlap_mm = 0.8; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // Off-white for PVC
    difference() {
      // Outer cylinder
      translate([0, 0, center * (0) + (1 - center) * (length_mm / 2)])
        cylinder(r=outer_diameter_mm / 2, h=length_mm, center=true);
      // Inner cut cylinder
      translate([0, 0, center * (0) + (1 - center) * (length_mm / 2)])
        cylinder(r=inner_diameter_mm / 2, h=length_mm + 2 * eps_overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();