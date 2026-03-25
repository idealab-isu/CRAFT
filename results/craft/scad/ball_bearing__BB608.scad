// Parameters
bore_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 22; //[11:44:0.1]
width_mm = 7; //[3.5:14:0.1]
race_radial_thickness_mm = 2.2; //[1.2:4.4:0.1]
race_axial_margin_mm = 0.6; //[0.3:1.2:0.05]
shield_thickness_mm = 0.4; //[0.2:0.8:0.05]
shield_radial_overlap_mm = 0.8; //[0.4:1.6:0.05]
shield_bore_clearance_mm = 0.6; //[0.3:1.2:0.05]
ball_diameter_mm = 3.5; //[2:6:0.1]
ball_count = 8; //[6:12:1]
ball_radial_clearance_mm = 0.25; //[0.1:0.6:0.05]
connect_overlap_mm = 0.8; //[0.5:2:0.1]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i * 360 / ball_count])
      translate([
        (bore_diameter_mm / 2 + race_radial_thickness_mm) + 
        ((outer_diameter_mm / 2 - race_radial_thickness_mm) - 
        (bore_diameter_mm / 2 + race_radial_thickness_mm)) / 2, 
        0, 0
      ])
      sphere(r = ball_diameter_mm / 2, $fn = 32);
    }
  }
}

// BB608 - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Race
    difference() {
      cylinder(r = outer_diameter_mm / 2, h = width_mm, center = true, $fn = 64);
      cylinder(r = outer_diameter_mm / 2 - race_radial_thickness_mm, 
               h = width_mm + 2 * connect_overlap_mm, center = true, $fn = 64);
    }
    // Inner Race
    difference() {
      cylinder(r = bore_diameter_mm / 2 + race_radial_thickness_mm, 
               h = width_mm - 2 * race_axial_margin_mm, center = true, $fn = 64);
      cylinder(r = bore_diameter_mm / 2, 
               h = width_mm - 2 * race_axial_margin_mm + 2 * connect_overlap_mm, 
               center = true, $fn = 64);
    }
    // Shields
    union() {
      translate([0, 0, width_mm / 2 - shield_thickness_mm / 2 - connect_overlap_mm])
        difference() {
          cylinder(r = outer_diameter_mm / 2 - connect_overlap_mm, 
                   h = shield_thickness_mm, center = true, $fn = 64);
          cylinder(r = bore_diameter_mm / 2 + shield_bore_clearance_mm, 
                   h = shield_thickness_mm + 2 * connect_overlap_mm, center = true, $fn = 64);
        }
      translate([0, 0, -(width_mm / 2 - shield_thickness_mm / 2 - connect_overlap_mm)])
        difference() {
          cylinder(r = outer_diameter_mm / 2 - connect_overlap_mm, 
                   h = shield_thickness_mm, center = true, $fn = 64);
          cylinder(r = bore_diameter_mm / 2 + shield_bore_clearance_mm, 
                   h = shield_thickness_mm + 2 * connect_overlap_mm, center = true, $fn = 64);
        }
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();