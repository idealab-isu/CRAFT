// Parameters
thread_diameter = 3; //[1.5:6:0.1]
thread_pitch = 0.5; //[0.25:1:0.05]
across_flats = 5.5; //[2.75:11:0.1]
thickness = 1.8; //[0.9:3.6:0.1]
across_corners = 6.350852961085883; //[3.1754264805429413:12.701705922171765:0.1]
inner_hole_diameter_clearance = 3; //[2.5:3.6:0.05]
chamfer_top = 0; //[0:0.6:0.05]
chamfer_bottom = 0; //[0:0.6:0.05]
eps_overlap = 0.6; //[0.2:2:0.1]

// Hexagonal Nut
module hex_nut() {
  color("DimGray") {
    difference() {
      // Hexagonal body
      linear_extrude(height=thickness, center=true) {
        polygon(points=[
          [across_flats/2, 0],
          [across_flats/4, (across_flats/2)*tan(60)],
          [-across_flats/4, (across_flats/2)*tan(60)],
          [-across_flats/2, 0],
          [-across_flats/4, -(across_flats/2)*tan(60)],
          [across_flats/4, -(across_flats/2)*tan(60)]
        ]);
      }
      // Central through hole
      translate([0, 0, 0])
        cylinder(r=inner_hole_diameter_clearance/2, h=thickness + 2*eps_overlap, center=true);
    }
  }
}

// Assembly
module assembly() {
  hex_nut();
}

assembly();