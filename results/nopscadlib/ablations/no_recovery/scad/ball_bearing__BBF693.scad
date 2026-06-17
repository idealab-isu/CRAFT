// Parameters
bore_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 8; //[4:16:0.1]
width_mm = 3; //[1.5:6:0.1]
flange_diameter_mm = 9.5; //[4.75:19:0.1]
flange_width_mm = 0.6; //[0.3:1.2:0.05]
outer_race_radial_thickness_mm = 1.2; //[0.6:2.4:0.05]
inner_race_radial_thickness_mm = 1; //[0.5:2:0.05]
shield_thickness_mm = 0.3; //[0.15:0.8:0.05]
chamfer_size_mm = 0.25; //[0.1:0.6:0.05]
ball_diameter_mm = 1.2; //[0.6:2.4:0.05]
ball_count = 8; //[4:16:1]
overlap_mm = 0.8; //[0.2:2:0.1]

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Silver") {
    sphere(r=ball_diameter_mm/2, $fn=32);
  }
}

// Ball Bearing - complete geometry
module ball_bearing() {
  color("DimGray") {
    // Outer Race
    difference() {
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true, $fn=64);
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2 - outer_race_radial_thickness_mm, h=width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    
    // Inner Race
    difference() {
      cylinder(r=bore_diameter_mm/2 + inner_race_radial_thickness_mm, h=width_mm, center=true, $fn=64);
      translate([0, 0, 0])
        cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    
    // Shield
    difference() {
      translate([0, 0, width_mm/2 - shield_thickness_mm/2])
        cylinder(r=outer_diameter_mm/2 - outer_race_radial_thickness_mm + overlap_mm, h=shield_thickness_mm, center=true, $fn=64);
      translate([0, 0, width_mm/2 - shield_thickness_mm/2])
        cylinder(r=bore_diameter_mm/2 + inner_race_radial_thickness_mm - overlap_mm, h=shield_thickness_mm + 2*overlap_mm, center=true, $fn=64);
    }
    
    // Flange
    difference() {
      translate([0, 0, -width_mm/2 + flange_width_mm/2])
        cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true, $fn=64);
      translate([0, 0, -width_mm/2 + flange_width_mm/2])
        cylinder(r=outer_diameter_mm/2 - overlap_mm, h=flange_width_mm + 2*overlap_mm, center=true, $fn=64);
    }
    
    // Chamfers
    difference() {
      union() {
        translate([0, 0, width_mm/2 - chamfer_size_mm/2])
          cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_size_mm, h=chamfer_size_mm, center=true, $fn=64);
        translate([0, 0, -width_mm/2 + chamfer_size_mm/2])
          cylinder(r1=outer_diameter_mm/2, r2=outer_diameter_mm/2 - chamfer_size_mm, h=chamfer_size_mm, center=true, $fn=64);
      }
    }
    
    // Bore Chamfers
    difference() {
      union() {
        translate([0, 0, width_mm/2 - chamfer_size_mm/2])
          cylinder(r1=bore_diameter_mm/2 + chamfer_size_mm, r2=bore_diameter_mm/2, h=chamfer_size_mm, center=true, $fn=64);
        translate([0, 0, -width_mm/2 + chamfer_size_mm/2])
          cylinder(r1=bore_diameter_mm/2 + chamfer_size_mm, r2=bore_diameter_mm/2, h=chamfer_size_mm, center=true, $fn=64);
      }
    }
  }
  
  // Balls
  for (i = [0:ball_count-1]) {
    rotate([0, 0, i*360/ball_count])
      translate([(bore_diameter_mm/2 + inner_race_radial_thickness_mm + outer_diameter_mm/2 - outer_race_radial_thickness_mm)/2, 0, 0])
        bearing_ball();
  }
}

// Assembly
module assembly() {
  ball_bearing();
}

assembly();