// Parameters
tooth_count = 80; //[40:160:1]
pitch_diameter_mm = 50.42; //[25.21:100.84:0.01]
belt_pitch_mm = 2; //[1:10:0.01]
pulley_width_mm = 10; //[5:30:0.1]
bore_diameter_mm = 8; //[3:20:0.01]
hub_diameter_mm = 22; //[12:44:0.1]
hub_length_mm = 16; //[8:32:0.1]
flange_diameter_mm = 60; //[40:90:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
set_screw_count = 2; //[0:4:1]
set_screw_hole_diameter_mm = 3.3; //[2:6:0.01]
set_screw_z_mm = 8; //[2:30:0.1]
tooth_radial_height_mm = 1.2; //[0.6:2.5:0.01]
tooth_tangential_width_mm = 1.2; //[0.6:3:0.01]
tooth_root_clearance_mm = 0.6; //[0.2:1.5:0.01]
connection_overlap_mm = 1; //[0.5:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Hub
    translate([0, 0, hub_length_mm/2])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges
    translate([0, 0, (hub_length_mm + flange_thickness_mm)/2])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    translate([0, 0, (hub_length_mm + 2*flange_thickness_mm + pulley_width_mm - flange_thickness_mm/2 - connection_overlap_mm)])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

    // Pulley Body
    translate([0, 0, (hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2 - connection_overlap_mm)])
      cylinder(r=(pitch_diameter_mm/2 + tooth_radial_height_mm - tooth_root_clearance_mm), h=pulley_width_mm, center=true);

    // Bore
    translate([0, 0, (hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2 - connection_overlap_mm)])
      cylinder(r=bore_diameter_mm/2, h=(hub_length_mm + 2*flange_thickness_mm + pulley_width_mm + 4*connection_overlap_mm), center=true);
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count]) {
      translate([0, (pitch_diameter_mm/2 + tooth_radial_height_mm/2 - connection_overlap_mm), (hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2 - connection_overlap_mm)])
        cube([tooth_tangential_width_mm, tooth_radial_height_mm, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  printed_pulley_GT2_teeth();
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  printed_pulley_teeth_from_profile();
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth();
}

assembly();