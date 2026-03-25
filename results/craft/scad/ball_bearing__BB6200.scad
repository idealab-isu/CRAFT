// Parameters
bore_diameter_mm = 10; //[5:20:0.5]
outer_diameter_mm = 30; //[15:60:0.5]
width_mm = 9; //[4.5:18:0.5]
radial_thickness_mm = 3.5; //[2:7:0.1]
shield_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_radial_gap_mm = 0.4; //[0.1:1.0:0.05]
shield_axial_inset_mm = 0.4; //[0.1:1.5:0.05]
ball_diameter_mm = 4.0; //[2.5:6.0:0.1]
ball_count = 8; //[6:12:1]
ball_overlap_mm = 0.8; //[0.3:1.5:0.05]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2);
  }
}

// BB6200 - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Ring
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      cylinder(r=outer_diameter_mm/2 - radial_thickness_mm, h=width_mm + 2*eps_mm, center=true);
    }
    // Inner Ring
    difference() {
      cylinder(r=bore_diameter_mm/2 + radial_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
    }
  }
  
  // Shields
  color("Black") {
    translate([0, 0, width_mm/2 - shield_axial_inset_mm - shield_thickness_mm/2])
      difference() {
        cylinder(r=outer_diameter_mm/2 - radial_thickness_mm - shield_radial_gap_mm, h=shield_thickness_mm, center=true);
        cylinder(r=bore_diameter_mm/2 + radial_thickness_mm + shield_radial_gap_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
      }
    translate([0, 0, -(width_mm/2 - shield_axial_inset_mm - shield_thickness_mm/2)])
      difference() {
        cylinder(r=outer_diameter_mm/2 - radial_thickness_mm - shield_radial_gap_mm, h=shield_thickness_mm, center=true);
        cylinder(r=bore_diameter_mm/2 + radial_thickness_mm + shield_radial_gap_mm, h=shield_thickness_mm + 2*eps_mm, center=true);
      }
  }
  
  // Balls
  color("Silver") {
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count]) 
        translate([((bore_diameter_mm/2 + radial_thickness_mm) + (outer_diameter_mm/2 - radial_thickness_mm))/2, 0, 0])
          scale((ball_diameter_mm + 2*ball_overlap_mm)/ball_diameter_mm)
            bearing_ball();
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();