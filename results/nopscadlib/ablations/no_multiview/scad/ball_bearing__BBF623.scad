// Parameters
bore_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 10.0; //[5.0:20.0:0.1]
width_mm = 4.0; //[2.0:8.0:0.1]
flange_outer_diameter_mm = 11.5; //[6.0:23.0:0.1]
flange_width_mm = 1.0; //[0.5:2.0:0.1]
outer_race_radial_thickness_mm = 1.2; //[0.6:2.4:0.1]
inner_race_radial_thickness_mm = 1.0; //[0.5:2.0:0.1]
shield_band_radial_thickness_mm = 0.4; //[0.2:1.0:0.05]
shield_band_axial_clearance_mm = 0.6; //[0.3:1.2:0.05]
ball_diameter_mm = 1.2; //[0.6:2.4:0.1]
ball_center_radius_mm = 3.25; //[2.0:5.0:0.05]
connection_overlap_mm = 0.8; //[0.5:2.0:0.1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Race
    cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
    
    // Inner Race
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2 + inner_race_radial_thickness_mm, h=width_mm, center=true);
    
    // Flange
    translate([0, 0, width_mm/2 - flange_width_mm/2 + connection_overlap_mm/2])
      cylinder(r=flange_outer_diameter_mm/2, h=flange_width_mm, center=true);
    
    // Shield or Seal Band
    translate([0, 0, 0])
      cylinder(r=outer_diameter_mm/2 - outer_race_radial_thickness_mm + shield_band_radial_thickness_mm, h=width_mm - shield_band_axial_clearance_mm, center=true);
  }
  
  // Bore Through Hole
  translate([0, 0, 0])
    color("Black")
    cylinder(r=bore_diameter_mm/2, h=width_mm + 2*connection_overlap_mm, center=true);
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    translate([ball_center_radius_mm, 0, 0])
      sphere(r=ball_diameter_mm/2, center=true);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();