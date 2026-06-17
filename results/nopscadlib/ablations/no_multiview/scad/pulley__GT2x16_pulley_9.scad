// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.65; //[5:20:0.01]
pitch_mm = 2; //[1:5:0.01]
pulley_width_mm = 6; //[3:20:0.1]
bore_diameter_mm = 5; //[1:12:0.01]
hub_diameter_mm = 12; //[6:24:0.1]
hub_length_mm = 10; //[4:30:0.1]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 14; //[8:30:0.1]
flange_thickness_mm = 1; //[0.6:3:0.1]
set_screw_enabled = 0; //[0:1:1]
set_screw_count = 1; //[1:4:1]
set_screw_diameter_mm = 3; //[2:6:0.1]
set_screw_z_mm = 5; //[0:20:0.1]
tolerance_mm = 0.2; //[0:0.6:0.01]
overlap_mm = 0.8; //[0.2:2:0.1]
tooth_radial_height_mm = 0.8; //[0.4:1.6:0.01]
tooth_tangential_width_mm = 1.5; //[0.8:3:0.01]
tooth_root_clearance_mm = 0.3; //[0.1:0.8:0.01]
hub_to_teeth_overlap_mm = 0.8; //[0.2:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Hub
    translate([0, 0, hub_length_mm/2])
      cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true, $fn=64);
    
    // Flanges
    if (flange_enabled) {
      translate([0, 0, flange_thickness_mm/2])
        cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true, $fn=64);
      translate([0, 0, hub_length_mm + pulley_width_mm - flange_thickness_mm/2 - hub_to_teeth_overlap_mm])
        cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true, $fn=64);
    }
    
    // Bore
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm*flange_enabled + pulley_width_mm/2 - hub_to_teeth_overlap_mm])
      cylinder(h=hub_length_mm + pulley_width_mm + 2*flange_thickness_mm + 4*overlap_mm, r=(bore_diameter_mm + tolerance_mm)/2, center=true, $fn=64);
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([pitch_diameter_mm/2 + (tooth_radial_height_mm + tooth_root_clearance_mm)/2 - tooth_root_clearance_mm, 0, hub_length_mm/2 + flange_thickness_mm*flange_enabled + pulley_width_mm/2 - hub_to_teeth_overlap_mm])
          cube([tooth_radial_height_mm + tooth_root_clearance_mm, tooth_tangential_width_mm, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  printed_pulley_teeth_from_profile();
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  printed_pulley_GT2_teeth();
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth();
}

assembly();