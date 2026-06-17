// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.75; //[5:20:0.05]
pitch_radius_mm = 4.875; //[2.5:10:0.025]
belt_pitch_mm = 2; //[1:5:0.1]
tooth_profile_standard = 2; //[1:3:1]
pulley_width_mm = 10; //[5:30:1]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 14; //[8:28:0.5]
hub_length_mm = 8; //[0:25:1]
flange_diameter_mm = 16; //[10:35:0.5]
flange_thickness_mm = 1.5; //[0:5:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_thread = 3; //[2:6:1]
set_screw_z_offset_mm = 4; //[0:20:0.5]
tolerance_mm = 0.2; //[0:0.6:0.05]
tooth_radial_height_mm = 0.8; //[0.4:1.6:0.05]
tooth_root_relief_mm = 0.4; //[0.2:1.2:0.05]
tooth_tangential_width_mm = 1.2; //[0.6:2.5:0.05]
tooth_overlap_mm = 0.8; //[0.3:2:0.05]
connection_overlap_mm = 0.8; //[0.5:2:0.1]
set_screw_clearance_mm = 3.2; //[2.2:6.5:0.1]
set_screw_hole_length_mm = 30; //[10:80:1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed pulley body
    translate([0, 0, hub_length_mm + flange_thickness_mm + pulley_width_mm/2])
      cylinder(r=pitch_diameter_mm/2 + tooth_radial_height_mm, h=pulley_width_mm, center=true);

    // Hub
    translate([0, 0, hub_length_mm/2])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges
    translate([0, 0, hub_length_mm + flange_thickness_mm/2])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    translate([0, 0, hub_length_mm + flange_thickness_mm + pulley_width_mm - flange_thickness_mm/2])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

    // Central bore
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2])
      cylinder(r=(bore_diameter_mm + tolerance_mm)/2, h=hub_length_mm + 2*flange_thickness_mm + pulley_width_mm + 2*connection_overlap_mm, center=true);
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count]) {
      translate([pitch_diameter_mm/2 + tooth_radial_height_mm/2 - tooth_overlap_mm/2, 0, hub_length_mm + flange_thickness_mm + pulley_width_mm/2])
        cube([tooth_radial_height_mm + tooth_overlap_mm, tooth_tangential_width_mm, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  printed_pulley_teeth_from_profile();
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  printed_pulley_GT2_teeth();
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth();
}

assembly();