// Parameters
tooth_count = 80; //[20:200:1]
pitch_diameter_mm = 50.42; //[25.21:100.84:0.01]
belt_pitch_mm = 2; //[1:10:0.01]
tooth_profile = 0; //[0:2:1]
pulley_width_mm = 16; //[8:32:0.5]
bore_diameter_mm = 8; //[3:20:0.01]
hub_diameter_mm = 24; //[12:48:0.1]
hub_length_mm = 10; //[0:30:0.5]
flange_diameter_mm = 60; //[40:90:0.1]
flange_thickness_mm = 1.5; //[0:4:0.1]
set_screw_count = 2; //[0:4:1]
set_screw_thread = 3; //[2:6:1]
set_screw_z_offset_mm = 5; //[0:20:0.5]
keyway_width_mm = 0; //[0:8:0.1]
keyway_depth_mm = 0; //[0:4:0.1]
shaft_flat_depth_mm = 0; //[0:3:0.1]
tolerance_mm = 0.2; //[0:0.6:0.01]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_root_clearance_mm = 0.6; //[0.2:1.5:0.05]
tooth_width_factor = 0.55; //[0.35:0.75:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed pulley body
    cylinder(h=pulley_width_mm, r=(pitch_diameter_mm/2) - tooth_root_clearance_mm, center=true);
    
    // Hub
    translate([0, 0, -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm])
      cylinder(h=hub_length_mm + overlap_mm, r=hub_diameter_mm/2, center=true);
    
    // Flanges
    if (flange_thickness_mm > 0) {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(h=flange_thickness_mm + overlap_mm, r=flange_diameter_mm/2, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(h=flange_thickness_mm + overlap_mm, r=flange_diameter_mm/2, center=true);
    }
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([(pitch_diameter_mm/2) - tooth_root_clearance_mm + (tooth_radial_height_mm + overlap_mm)/2 - overlap_mm, 0, 0])
        cube([tooth_radial_height_mm + overlap_mm, belt_pitch_mm*tooth_width_factor, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([(pitch_diameter_mm/2) - tooth_root_clearance_mm + (tooth_radial_height_mm + overlap_mm)/2 - overlap_mm, 0, 0])
        cube([tooth_radial_height_mm + overlap_mm, belt_pitch_mm*tooth_width_factor, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([(pitch_diameter_mm/2) - tooth_root_clearance_mm + (tooth_radial_height_mm + overlap_mm)/2 - overlap_mm, 0, 0])
        cube([tooth_radial_height_mm + overlap_mm, belt_pitch_mm*tooth_width_factor, pulley_width_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth_from_profile();
  printed_pulley_GT2_teeth();
  printed_pulley_teeth();
}

assembly();