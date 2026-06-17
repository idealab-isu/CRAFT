// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 16; //[8:32:0.1]
width_mm = 5; //[2.5:10:0.1]
flange_diameter_mm = 18; //[9:36:0.1]
flange_width_mm = 1; //[0.5:2:0.1]
eps_mm = 0.6; //[0.2:1.5:0.1]
outer_rim_radial_mm = 1.2; //[0.6:2.4:0.1]
inner_hub_radial_mm = 1.2; //[0.6:2.4:0.1]
shield_radial_thickness_mm = 0.6; //[0.3:1.2:0.1]
shield_axial_thickness_mm = 0.8; //[0.4:1.6:0.1]
ball_diameter_mm = 2.0; //[1.0:4.0:0.1]
ball_count = 8; //[6:14:1]
ball_pitch_radius_mm = 5.2; //[3.5:7.0:0.1]

// Outer race
module outer_race() {
  color("DimGray") difference() {
    cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
    cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm, h=width_mm + 2*eps_mm, center=true);
  }
}

// Inner race
module inner_race() {
  color("DimGray") difference() {
    cylinder(r=bore_diameter_mm/2 + inner_hub_radial_mm, h=width_mm, center=true);
    cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
  }
}

// Flange
module flange_feature() {
  color("Silver") difference() {
    translate([0, 0, -width_mm/2 + flange_width_mm/2])
      cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
    translate([0, 0, -width_mm/2 + flange_width_mm/2])
      cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm + eps_mm, h=flange_width_mm + 2*eps_mm, center=true);
  }
}

// Shield region
module shield_region() {
  color("Black") difference() {
    cylinder(r=outer_diameter_mm/2 - outer_rim_radial_mm + eps_mm, h=shield_axial_thickness_mm, center=true);
    cylinder(r=bore_diameter_mm/2 + inner_hub_radial_mm - eps_mm, h=shield_axial_thickness_mm + 2*eps_mm, center=true);
  }
}

// Bearing ball
module bearing_ball() {
  color("Silver") sphere(r=ball_diameter_mm/2, center=true);
}

// Bearing balls
module bearing_balls() {
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count])
      translate([ball_pitch_radius_mm, 0, 0])
      bearing_ball();
  }
}

// Ball bearing assembly
module ball_bearing() {
  union() {
    outer_race();
    inner_race();
    shield_region();
    flange_feature();
    bearing_balls();
  }
}

// Final assembly
module assembly() {
  ball_bearing();
}

assembly();