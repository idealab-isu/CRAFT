// Parameters
outer_diameter_mm = 8; //[4:16:0.1]
height_mm = 4.2; //[2.1:8.4:0.1]
inner_diameter_mm = 0; //[0:8:0.1]
bore = 0; //[0:1:1]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper-like color for magnet
    // Magnet body
    cylinder(h=height_mm, r=outer_diameter_mm/2, center=true, $fn=64);
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();