// Parameters
thread_diameter_mm = 4; //[2:8:0.1]
across_flats_mm = 5.3; //[2.65:10.6:0.1]
thickness_mm = 6.3; //[3.15:12.6:0.1]
tolerance_mm = 0; //[0:0.6:0.05]
eps_mm = 0.8; //[0.2:2:0.1]

// Hexagonal Nut - complete geometry
module hex_nut() {
  color("DimGray") {
    difference() {
      // Hexagonal body
      intersection() {
        // Hexagonal profile
        linear_extrude(height = thickness_mm, center = true) {
          polygon(points = [
            [across_flats_mm/2, 0],
            [across_flats_mm/4, across_flats_mm*sqrt(3)/4],
            [-across_flats_mm/4, across_flats_mm*sqrt(3)/4],
            [-across_flats_mm/2, 0],
            [-across_flats_mm/4, -across_flats_mm*sqrt(3)/4],
            [across_flats_mm/4, -across_flats_mm*sqrt(3)/4]
          ]);
        }
        // Cylinder to control thickness
        cube([across_flats_mm, across_flats_mm, thickness_mm], center = true);
      }
      // Central through-hole
      cylinder(r = (thread_diameter_mm + tolerance_mm)/2, h = thickness_mm + 2*eps_mm, center = true);
    }
  }
}

// Assembly
module assembly() {
  hex_nut();
}

assembly();