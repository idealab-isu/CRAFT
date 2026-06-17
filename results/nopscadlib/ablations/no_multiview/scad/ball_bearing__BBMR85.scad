// Parameters
bore_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 8; //[4:16:0.1]
width_mm = 2.5; //[1.25:5:0.05]
radial_rim_thickness_mm = 0.6; //[0.3:1.2:0.05]
inner_race_radial_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_thickness_mm = 0.25; //[0.15:0.6:0.05]
shield_radial_overlap_mm = 0.2; //[0.05:0.6:0.05]
ball_diameter_mm = 0.8; //[0.4:1.4:0.05]
ball_count = 8; //[5:14:1]
ball_radial_overlap_mm = 0.15; //[0.05:0.4:0.05]
eps_mm = 0.05; //[0.01:0.2:0.01]

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
      cylinder(r=outer_diameter_mm/2 - radial_rim_thickness_mm, h=width_mm + 2*eps_mm, center=true);
    }
    
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + inner_race_radial_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*eps_mm, center=true);
    }
    
    // Shields
    union() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2])
        cylinder(r=outer_diameter_mm/2 - radial_rim_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
      translate([0, 0, -(width_mm/2 - shield_thickness_mm/2)])
        cylinder(r=outer_diameter_mm/2 - radial_rim_thickness_mm + shield_radial_overlap_mm, h=shield_thickness_mm, center=true);
    }
    
    // Bearing Balls
    for (i = [0:ball_count-1]) {
      rotate([0, 0, i*360/ball_count])
        translate([((bore_diameter_mm/2 + inner_race_radial_thickness_mm) + (outer_diameter_mm/2 - radial_rim_thickness_mm))/2, 0, 0])
          bearing_ball();
    }
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();