// Parameters
outer_diameter_mm = 6; //[3:12:0.1]
height_mm = 2; //[1:4:0.1]
inner_diameter_mm = 0; //[0:4:0.1]
fit_overlap_mm = 0.8; //[0.5:2:0.1]
edge_round_mm = 0.2; //[0:0.6:0.05]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper color for the magnet
    difference() {
      // Outer cylinder
      cylinder(r=outer_diameter_mm/2, h=height_mm, center=true, $fn=64);
      
      // Inner bore (if applicable)
      if (inner_diameter_mm > 0) {
        translate([0, 0, 0])
          cylinder(r=inner_diameter_mm/2, h=height_mm + 2*fit_overlap_mm, center=true, $fn=64);
      }
    }
    
    // Edge rounding (if applicable)
    if (edge_round_mm > 0) {
      minkowski() {
        cylinder(r=outer_diameter_mm/2, h=height_mm, center=true, $fn=64);
        sphere(r=edge_round_mm, $fn=32);
      }
    }
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();