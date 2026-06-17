// Parameters
outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
height_mm = 4.2; //[2.1:8.4:0.1]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper-like color for magnet
    // Magnet body
    translate([0, 0, 0])
      cylinder(r=outer_diameter_mm/2, h=height_mm, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();