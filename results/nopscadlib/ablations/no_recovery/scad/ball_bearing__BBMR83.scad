// Parameters
bore_diameter_mm = 3.0; //[1.5:6.0:0.1]
outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
width_mm = 3.0; //[1.5:6.0:0.1]
shield_type = 0; //[0:2:1]
flange_diameter_mm = 0.0; //[0.0:16.0:0.1]
flange_width_mm = 0.0; //[0.0:3.0:0.1]
race_rim_mm = 0.8; //[0.4:1.6:0.05]
hub_thickness_mm = 0.8; //[0.4:1.6:0.05]
ball_diameter_mm = 1.2; //[0.6:2.4:0.05]
ball_count = 8; //[4:16:1]
shield_thickness_mm = 0.3; //[0.15:0.8:0.05]
overlap_mm = 0.6; //[0.2:1.5:0.1]

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
      cylinder(r=outer_diameter_mm/2 - race_rim_mm, h=width_mm + 2*overlap_mm, center=true);
    }
    
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + hub_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
    }
    
    // Flange (if applicable)
    if (flange_diameter_mm > 0 && flange_width_mm > 0) {
      difference() {
        translate([0, 0, width_mm/2 - flange_width_mm/2 + overlap_mm])
          cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
        translate([0, 0, width_mm/2 - flange_width_mm/2 + overlap_mm])
          cylinder(r=outer_diameter_mm/2 - race_rim_mm, h=flange_width_mm + 2*overlap_mm, center=true);
      }
    }
    
    // Shields or Seals (if applicable)
    if (shield_type > 0) {
      difference() {
        translate([0, 0, width_mm/2 - shield_thickness_mm/2])
          cylinder(r=outer_diameter_mm/2 - race_rim_mm + overlap_mm, h=shield_thickness_mm, center=true);
        translate([0, 0, width_mm/2 - shield_thickness_mm/2])
          cylinder(r=bore_diameter_mm/2 + hub_thickness_mm - overlap_mm, h=shield_thickness_mm + 2*overlap_mm, center=true);
      }
      difference() {
        translate([0, 0, -width_mm/2 + shield_thickness_mm/2])
          cylinder(r=outer_diameter_mm/2 - race_rim_mm + overlap_mm, h=shield_thickness_mm, center=true);
        translate([0, 0, -width_mm/2 + shield_thickness_mm/2])
          cylinder(r=bore_diameter_mm/2 + hub_thickness_mm - overlap_mm, h=shield_thickness_mm + 2*overlap_mm, center=true);
      }
    }
  }
  
  // Bearing Balls
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count]) 
      translate([(bore_diameter_mm/2 + hub_thickness_mm + (outer_diameter_mm/2 - race_rim_mm))/2, 0, 0])
        bearing_ball();
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();