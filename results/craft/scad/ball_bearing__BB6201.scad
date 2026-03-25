// Parameters
bore_diameter_mm = 12.0; //[6.0:24.0:0.1]
outer_diameter_mm = 32.0; //[16.0:64.0:0.1]
width_mm = 10.0; //[5.0:20.0:0.1]
bore_radius_mm = 6.0; //[3.0:12.0:0.1]
outer_radius_mm = 16.0; //[8.0:32.0:0.1]
race_radial_thickness_mm = 3.0; //[1.5:6.0:0.1]
shield_thickness_mm = 0.6; //[0.3:1.5:0.1]
shield_radial_clearance_mm = 0.5; //[0.2:1.5:0.1]
ball_diameter_mm = 4.0; //[2.0:8.0:0.1]
ball_radial_overlap_mm = 0.8; //[0.2:2.0:0.1]
connect_overlap_mm = 1.0; //[0.5:2.0:0.1]

// Outer Race
module outer_race() {
  color("Silver") difference() {
    cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
    cylinder(r=outer_diameter_mm/2 - race_radial_thickness_mm, h=width_mm + 2*connect_overlap_mm, center=true);
  }
}

// Inner Race
module inner_race() {
  color("Silver") difference() {
    cylinder(r=bore_diameter_mm/2 + race_radial_thickness_mm, h=width_mm, center=true);
    cylinder(r=bore_diameter_mm/2, h=width_mm + 2*connect_overlap_mm, center=true);
  }
}

// Shield Faces
module shield_faces() {
  color("DimGray") union() {
    translate([0, 0, width_mm/2 - shield_thickness_mm/2 - connect_overlap_mm/2])
      cylinder(r=outer_diameter_mm/2 - race_radial_thickness_mm - shield_radial_clearance_mm, h=shield_thickness_mm, center=true);
    translate([0, 0, -width_mm/2 + shield_thickness_mm/2 + connect_overlap_mm/2])
      cylinder(r=outer_diameter_mm/2 - race_radial_thickness_mm - shield_radial_clearance_mm, h=shield_thickness_mm, center=true);
  }
}

// Bearing Ball
module bearing_ball() {
  color("Copper") translate([
    bore_diameter_mm/2 + race_radial_thickness_mm + (outer_diameter_mm/2 - race_radial_thickness_mm - (bore_diameter_mm/2 + race_radial_thickness_mm))/2 - ball_radial_overlap_mm,
    0,
    0
  ]) sphere(r=ball_diameter_mm/2);
}

// Ball Bearing Assembly
module ball_bearing() {
  union() {
    outer_race();
    inner_race();
    shield_faces();
    bearing_ball();
  }
}

// Final Assembly
module assembly() {
  ball_bearing();
}

assembly();