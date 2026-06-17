// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.75; //[5:20:0.05]
pulley_width_mm = 10; //[5:30:0.5]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 14; //[8:28:0.5]
hub_length_mm = 12; //[6:30:0.5]
flange_diameter_mm = 16; //[10:32:0.5]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_size_mm = 3; //[2:6:0.5]
set_screw_z_mm = 0; //[-10:10:0.5]
tooth_radial_height_mm = 1.2; //[0.6:2.5:0.1]
tooth_root_depth_mm = 0.6; //[0.2:1.5:0.1]
tooth_tangential_width_factor = 0.55; //[0.3:0.8:0.01]
tooth_overlap_mm = 0.8; //[0.3:2:0.1]
connection_overlap_mm = 0.8; //[0.3:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Pulley body
    difference() {
      cylinder(h=pulley_width_mm, r=(pitch_diameter_mm/2) - tooth_root_depth_mm, center=true);
      // Center bore
      cylinder(h=hub_length_mm + pulley_width_mm + 2*flange_thickness_mm, r=bore_diameter_mm/2, center=true);
    }
    // Hub
    translate([0, 0, 0])
      cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);
    // Flanges
    translate([0, 0, (pulley_width_mm/2) + (flange_thickness_mm/2) - connection_overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
    translate([0, 0, -(pulley_width_mm/2) - (flange_thickness_mm/2) + connection_overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count]) {
      translate([0, (pitch_diameter_mm/2) + (tooth_radial_height_mm - tooth_root_depth_mm)/2 - tooth_overlap_mm/2, 0])
        cube([tooth_pitch_mm*tooth_tangential_width_factor, tooth_radial_height_mm + tooth_root_depth_mm + tooth_overlap_mm, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  intersection() {
    printed_pulley_teeth();
    cylinder(h=pulley_width_mm, r=(pitch_diameter_mm/2) + tooth_radial_height_mm, center=true);
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  intersection() {
    printed_pulley_teeth_from_profile();
    cylinder(h=pulley_width_mm, r=(pitch_diameter_mm/2) + tooth_radial_height_mm, center=true);
  }
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_GT2_teeth();
}

assembly();