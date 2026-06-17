// Parameters
bore_diameter_mm = 8; //[4:16:0.1]
outer_diameter_mm = 22; //[11:44:0.1]
width_mm = 7; //[3.5:14:0.1]
ball_count = 8; //[6:12:1]
ball_diameter_mm = 3.5; //[2:5:0.1]
race_radial_thickness_mm = 2.6; //[1.5:5.2:0.1]
race_axial_margin_mm = 0.6; //[0.3:1.5:0.1]
shield_thickness_mm = 0.4; //[0.2:1:0.05]
shield_radial_overlap_mm = 0.6; //[0.3:1.5:0.1]
connection_overlap_mm = 0.8; //[0.5:2:0.1]
inner_radius_mm = 4; //[2:8:0.1]
outer_radius_mm = 11; //[5.5:22:0.1]
inner_race_outer_radius_mm = 6.6; //[4.5:10.4:0.1]
outer_race_inner_radius_mm = 8.4; //[6:18:0.1]
race_height_mm = 5.8; //[2.5:13:0.1]
ball_pitch_radius_mm = 7.5; //[5:10:0.1]
shield_outer_radius_mm = 10.4; //[7:21:0.1]
shield_inner_radius_mm = 5.2; //[3:10:0.1]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2);
  }
}

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2 - race_radial_thickness_mm, h=width_mm + 2*connection_overlap_mm, center=true);
      translate([0, 0, width_mm/2 - race_axial_margin_mm/2])
        cube([outer_diameter_mm*2, outer_diameter_mm*2, width_mm - (width_mm - 2*race_axial_margin_mm)], center=true);
      translate([0, 0, -(width_mm/2 - race_axial_margin_mm/2)])
        cube([outer_diameter_mm*2, outer_diameter_mm*2, width_mm - (width_mm - 2*race_axial_margin_mm)], center=true);
    }
    
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + race_radial_thickness_mm, h=width_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=bore_diameter_mm/2, h=width_mm + 2*connection_overlap_mm, center=true);
      translate([0, 0, width_mm/2 - race_axial_margin_mm/2])
        cube([outer_diameter_mm*2, outer_diameter_mm*2, width_mm - (width_mm - 2*race_axial_margin_mm)], center=true);
      translate([0, 0, -(width_mm/2 - race_axial_margin_mm/2)])
        cube([outer_diameter_mm*2, outer_diameter_mm*2, width_mm - (width_mm - 2*race_axial_margin_mm)], center=true);
    }
    
    // Shields
    difference() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2 - connection_overlap_mm])
        cylinder(r=outer_diameter_mm/2 - shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, width_mm/2 - shield_thickness_mm/2 - connection_overlap_mm])
        cylinder(r=bore_diameter_mm/2 + shield_radial_overlap_mm, h=shield_thickness_mm + 2*connection_overlap_mm, center=true);
    }
    difference() {
      translate([0, 0, -width_mm/2 + shield_thickness_mm/2 + connection_overlap_mm])
        cylinder(r=outer_diameter_mm/2 - shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, -width_mm/2 + shield_thickness_mm/2 + connection_overlap_mm])
        cylinder(r=bore_diameter_mm/2 + shield_radial_overlap_mm, h=shield_thickness_mm + 2*connection_overlap_mm, center=true);
    }
  }
  
  // Bearing Balls
  color("Silver") {
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([ball_pitch_radius_mm, 0, 0])
        bearing_ball();
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();