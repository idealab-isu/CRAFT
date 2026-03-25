// Parameters
outer_diameter_mm = 20; //[10:40:1]
inner_diameter_mm = 5; //[0:20:1]
height_mm = 5; //[2.5:10:0.5]
edge_radius_mm = 1; //[0:4:0.25]
overlap_mm = 1; //[0.5:2:0.25]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper color for magnet
    // Core cylinder
    cylinder(r=outer_diameter_mm/2, h=height_mm, center=true, $fn=64);

    // Top edge torus
    translate([0, 0, height_mm/2 - edge_radius_mm])
      rotate_extrude($fn=64)
      translate([outer_diameter_mm/2 - edge_radius_mm, 0])
      circle(r=edge_radius_mm, $fn=32);

    // Bottom edge torus
    translate([0, 0, -height_mm/2 + edge_radius_mm])
      rotate_extrude($fn=64)
      translate([outer_diameter_mm/2 - edge_radius_mm, 0])
      circle(r=edge_radius_mm, $fn=32);

    // Optional central bore
    if (inner_diameter_mm > 0) {
      color("Black") // Bore color
      difference() {
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