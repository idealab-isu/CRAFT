// Parameters
thread_diameter = 6; //[3:12:0.1]
across_flats = 11.5; //[6:23:0.1]
thickness = 3; //[1.5:6:0.1]
tolerance = 0; //[-0.2:0.5:0.01]
hole_type = 0; //[0:1:1]
eps = 0.8; //[0.2:2:0.1]

// Hexagonal Nut with Washer
module nut_and_washer() {
  color("DimGray") {
    difference() {
      // Hexagonal profile
      union() {
        linear_extrude(height = thickness, center = true) {
          polygon(points = [
            [(across_flats/2)/cos(30), 0],
            [(across_flats/2)/cos(30)*cos(60), (across_flats/2)/cos(30)*sin(60)],
            [(across_flats/2)/cos(30)*cos(120), (across_flats/2)/cos(30)*sin(120)],
            [(across_flats/2)/cos(30)*cos(180), (across_flats/2)/cos(30)*sin(180)],
            [(across_flats/2)/cos(30)*cos(240), (across_flats/2)/cos(30)*sin(240)],
            [(across_flats/2)/cos(30)*cos(300), (across_flats/2)/cos(30)*sin(300)]
          ]);
        }
        // Top and bottom faces for robustness
        cube([across_flats, across_flats, thickness], center = true);
      }
      // Central through-hole
      cylinder(r = (thread_diameter + tolerance)/2, h = thickness + 2*eps, center = true);
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();