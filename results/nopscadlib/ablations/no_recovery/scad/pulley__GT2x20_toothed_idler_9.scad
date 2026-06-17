// Parameters
tooth_count = 20; //[10:80:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
belt_pitch_mm = 2; //[1:10:0.01]
pulley_width_mm = 7; //[4:20:0.1]
bore_diameter_mm = 5; //[1:12:0.1]
hub_diameter_mm = 16; //[10:32:0.1]
hub_length_mm = 10; //[5:25:0.1]
flange_diameter_mm = 18; //[12:40:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
set_screw_count = 2; //[0:4:1]
set_screw_thread = 3; //[2:6:1]
set_screw_z_offset_mm = 0; //[-6:6:0.1]
tolerances_mm = 0.25; //[0.1:0.6:0.01]
overlap_mm = 1; //[0.5:2:0.1]
gt2_tooth_r_mm = 0.555; //[0.3:1.2:0.001]
tooth_radial_height_mm = 0.75; //[0.3:1.5:0.01]
tooth_root_clearance_mm = 0.6; //[0.2:1.5:0.01]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed pulley body
    cylinder(r=pitch_diameter_mm/2 + tooth_radial_height_mm, h=pulley_width_mm, center=true);
    
    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
    
    // Flanges
    translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
  }
}

// Printed Pulley Teeth - detailed geometry
module printed_pulley_teeth() {
  color("DimGray") {
    // Approximate GT2 teeth
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i * 360 / tooth_count])
        translate([pitch_diameter_mm/2, 0, 0])
        cylinder(r=gt2_tooth_r_mm, h=pulley_width_mm + 2*overlap_mm, center=true);
    }
  }
}

// Printed Pulley Teeth From Profile - detailed geometry
module printed_pulley_teeth_from_profile() {
  color("DimGray") {
    // Profile-based teeth
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i * 360 / tooth_count])
        translate([pitch_diameter_mm/2, 0, 0])
        cylinder(r=gt2_tooth_r_mm, h=pulley_width_mm + 2*overlap_mm, center=true);
    }
  }
}

// Printed Pulley GT2 Teeth - detailed geometry
module printed_pulley_GT2_teeth() {
  color("DimGray") {
    // GT2 teeth approximation
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i * 360 / tooth_count])
        translate([pitch_diameter_mm/2, 0, 0])
        cylinder(r=gt2_tooth_r_mm, h=pulley_width_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth();
  printed_pulley_teeth_from_profile();
  printed_pulley_GT2_teeth();
}

assembly();