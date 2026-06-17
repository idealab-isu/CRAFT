// Parameters
magnet_type = 0; //[0:20:1]
outer_diameter_mm = 20; //[10:40:1]
inner_diameter_mm = 0; //[0:20:1]
height_mm = 5; //[2.5:10:0.5]
edge_radius_mm = 0.5; //[0:2:0.1]
bore_clearance_mm = 0.2; //[0:1:0.05]
bore_height_extra_mm = 2; //[1:6:0.5]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper color for magnet
    difference() {
      // Magnet body with edge rounding
      minkowski() {
        // Raw magnet body
        cylinder(r=outer_diameter_mm/2 - edge_radius_mm, h=height_mm - 2*edge_radius_mm, center=true);
        // Edge rounding sphere
        sphere(r=edge_radius_mm, center=true);
      }
      // Optional center bore
      if (inner_diameter_mm > 0) {
        cylinder(r=(inner_diameter_mm + bore_clearance_mm)/2, h=height_mm + bore_height_extra_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();