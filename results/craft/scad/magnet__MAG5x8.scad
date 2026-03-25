// Parameters
outer_diameter_mm = 20; //[10:40:1]
height_mm = 5; //[2.5:10:0.5]
inner_diameter_mm = 0; //[0:20:1]
edge_radius_mm = 0.8; //[0:2:0.1]
eps_mm = 0.8; //[0.5:2:0.1]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper color for magnet
    difference() {
      union() {
        // Magnet body with edge rounding
        union() {
          // Main body
          cylinder(r=outer_diameter_mm/2, h=height_mm, center=true, $fn=64);
          
          // Edge rounding
          translate([0, 0, height_mm/2 - edge_radius_mm + eps_mm/2])
            rotate_extrude($fn=64) translate([outer_diameter_mm/2 - edge_radius_mm, 0])
            circle(r=edge_radius_mm);
          
          translate([0, 0, -height_mm/2 + edge_radius_mm - eps_mm/2])
            rotate_extrude($fn=64) translate([outer_diameter_mm/2 - edge_radius_mm, 0])
            circle(r=edge_radius_mm);
        }
      }
      
      // Optional center bore
      if (inner_diameter_mm > 0) {
        cylinder(r=inner_diameter_mm/2, h=height_mm + 2*eps_mm, center=true, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();