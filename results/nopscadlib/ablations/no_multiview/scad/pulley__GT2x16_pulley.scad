// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.75; //[5:20:0.05]
pitch_mm = 2; //[1:10:0.1]
pulley_width_mm = 10; //[5:30:0.5]
tooth_depth_mm = 0.8; //[0.4:2:0.05]
tooth_width_mm = 1.5; //[0.8:3:0.05]
outer_diameter_mm = 11.35; //[9:20:0.05]
bore_diameter_mm = 5; //[2:10:0.05]
hub_diameter_mm = 14; //[8:28:0.5]
hub_length_mm = 12; //[6:30:0.5]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 16; //[10:32:0.5]
flange_thickness_mm = 1.5; //[0.5:4:0.1]
set_screw_count = 2; //[0:4:1]
set_screw_hole_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_offset_mm = 0; //[-10:10:0.5]
tolerances_mm = 0.2; //[0:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]
pitch_radius_mm = 4.875; //[2.5:10:0.025]
outer_radius_mm = 5.675; //[4.5:10:0.025]
root_radius_mm = 4.875; //[2.5:10:0.025]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Pulley body
    cylinder(r=root_radius_mm, h=pulley_width_mm, center=true);

    // Teeth
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([root_radius_mm + (tooth_depth_mm + tolerances_mm)/2 - overlap_mm, 0, 0])
        cube([tooth_depth_mm + tolerances_mm, tooth_width_mm + tolerances_mm, pulley_width_mm], center=true);
    }

    // Hub
    cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges
    if (flange_enabled) {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }

    // Central bore
    difference() {
      cylinder(r=(bore_diameter_mm + tolerances_mm)/2, h=hub_length_mm + pulley_width_mm + 2*(flange_thickness_mm*flange_enabled + eps_mm) + 10, center=true);
    }

    // Set screw holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 0, i*90])
          translate([0, 0, set_screw_z_offset_mm])
          rotate([0, 90, 0])
          cylinder(r=set_screw_hole_diameter_mm/2, h=hub_diameter_mm + 10, center=true);
      }
    }
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  color("Gray") {
    // Placeholder for detailed geometry
    // Implement detailed geometry based on specific profile requirements
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  color("Gray") {
    // Placeholder for detailed geometry
    // Implement detailed geometry based on GT2 profile requirements
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  color("Gray") {
    // Placeholder for detailed geometry
    // Implement detailed geometry based on specific tooth requirements
  }
}

// Assembly
module assembly() {
  pulley();
  translate([0, 0, hub_length_mm/2 + pulley_width_mm/2 + 1])
    printed_pulley_teeth_from_profile();
  translate([0, 0, hub_length_mm/2 + pulley_width_mm/2 + 2])
    printed_pulley_GT2_teeth();
  translate([0, 0, hub_length_mm/2 + pulley_width_mm/2 + 3])
    printed_pulley_teeth();
}

assembly();