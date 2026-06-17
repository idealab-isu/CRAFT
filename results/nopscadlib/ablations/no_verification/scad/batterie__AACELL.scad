// Parameters
overall_height_mm = 50.5; //[25.25:101:0.1]
body_diameter_mm = 14.5; //[7.25:29:0.1]
positive_terminal_diameter_mm = 5.5; //[2.75:11:0.1]
positive_terminal_height_mm = 1.2; //[0.6:2.4:0.05]
negative_terminal_diameter_mm = 6; //[3:12:0.1]
negative_terminal_height_mm = 0.2; //[0.1:0.6:0.05]
terminal_edge_radius_mm = 0.5; //[0.25:1:0.05]
terminal_overlap_mm = 0.8; //[0.5:2:0.1]
rounding_fn_mm = 0.01; //[0.005:0.05:0.005]

// Battery - complete geometry
module battery() {
  color("DimGray") {
    // Cylindrical cell body with edge rounding
    minkowski() {
      cylinder(
        h = overall_height_mm - positive_terminal_height_mm - negative_terminal_height_mm - 2 * terminal_edge_radius_mm,
        r = body_diameter_mm / 2 - terminal_edge_radius_mm,
        center = true
      );
      sphere(r = terminal_edge_radius_mm, center = true);
    }

    // Positive terminal button with edge rounding
    translate([0, 0, (overall_height_mm - positive_terminal_height_mm) / 2 - terminal_overlap_mm])
      minkowski() {
        cylinder(
          h = positive_terminal_height_mm,
          r = positive_terminal_diameter_mm / 2 - terminal_edge_radius_mm,
          center = true
        );
        sphere(r = terminal_edge_radius_mm, center = true);
      }

    // Negative terminal flat end with edge rounding
    translate([0, 0, -(overall_height_mm - negative_terminal_height_mm) / 2 + terminal_overlap_mm])
      minkowski() {
        cylinder(
          h = negative_terminal_height_mm,
          r = negative_terminal_diameter_mm / 2 - terminal_edge_radius_mm,
          center = true
        );
        sphere(r = terminal_edge_radius_mm, center = true);
      }
  }
}

// Assembly
module assembly() {
  battery();
}

assembly();