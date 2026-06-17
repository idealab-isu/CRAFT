// Parameters
bore_diameter_mm = 5.0; //[2.5:10.0:0.1]
outer_diameter_mm = 13.0; //[6.5:26.0:0.1]
width_mm = 4.0; //[2.0:8.0:0.1]
flange_diameter_mm = 15.0; //[7.5:30.0:0.1]
flange_width_mm = 1.0; //[0.5:2.0:0.1]
outer_race_rim_thickness_mm = 1.2; //[0.6:2.4:0.1]
inner_race_hub_thickness_mm = 1.2; //[0.6:2.4:0.1]
chamfer_mm = 0.3; //[0.15:0.6:0.05]
shield_band_thickness_mm = 0.6; //[0.3:1.2:0.05]
shield_band_axial_clearance_mm = 0.5; //[0.2:1.0:0.05]
ball_diameter_mm = 2.0; //[1.0:4.0:0.1]
overlap_mm = 0.8; //[0.5:2.0:0.1]

// Ball Bearing - complete geometry
module ball_bearing() {
  color("Silver") {
    // Outer race with flange
    difference() {
      union() {
        // Outer race ring
        cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);
        // Flange
        translate([0, 0, (-width_mm/2) + (flange_width_mm/2) - overlap_mm])
          cylinder(r=flange_diameter_mm/2, h=flange_width_mm, center=true);
      }
      // Inner bore of outer race
      cylinder(r=outer_diameter_mm/2 - outer_race_rim_thickness_mm, h=width_mm + 2*overlap_mm, center=true);
    }
    
    // Inner race
    difference() {
      cylinder(r=bore_diameter_mm/2 + inner_race_hub_thickness_mm, h=width_mm, center=true);
      cylinder(r=bore_diameter_mm/2, h=width_mm + 2*overlap_mm, center=true);
    }
    
    // Shield or seal band
    difference() {
      cylinder(r=outer_diameter_mm/2 - outer_race_rim_thickness_mm + overlap_mm, h=width_mm - shield_band_axial_clearance_mm, center=true);
      cylinder(r=bore_diameter_mm/2 + inner_race_hub_thickness_mm - overlap_mm, h=width_mm - shield_band_axial_clearance_mm + 2*overlap_mm, center=true);
    }
    
    // Chamfers
    union() {
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r=outer_diameter_mm/2, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r=outer_diameter_mm/2, h=chamfer_mm, center=true);
      translate([0, 0, width_mm/2 - chamfer_mm/2])
        cylinder(r=bore_diameter_mm/2 + inner_race_hub_thickness_mm, h=chamfer_mm, center=true);
      translate([0, 0, -width_mm/2 + chamfer_mm/2])
        cylinder(r=bore_diameter_mm/2 + inner_race_hub_thickness_mm, h=chamfer_mm, center=true);
    }
  }
}

// Bearing Ball - complete geometry
module bearing_ball() {
  color("Copper") {
    translate([(bore_diameter_mm/2 + inner_race_hub_thickness_mm) + ((outer_diameter_mm/2 - outer_race_rim_thickness_mm) - (bore_diameter_mm/2 + inner_race_hub_thickness_mm))/2, 0, 0])
      sphere(r=ball_diameter_mm/2);
  }
}

// Assembly
module assembly() {
  ball_bearing();
  bearing_ball();
}

assembly();