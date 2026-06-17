// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
belt_pitch_mm = 2; //[1:10:0.01]
pulley_width_mm = 10; //[5:30:0.1]
tooth_depth_mm = 0.8; //[0.3:2:0.01]
tooth_width_mm = 1.5; //[0.8:3:0.01]
root_clearance_mm = 0.4; //[0.1:1.5:0.01]
bore_diameter_mm = 5; //[2:10:0.01]
hub_diameter_mm = 16; //[8:32:0.1]
hub_length_mm = 14; //[6:40:0.1]
flange_diameter_mm = 18; //[10:40:0.1]
flange_thickness_mm = 1.5; //[0.8:5:0.1]
tolerance_mm = 0; //[0:0.5:0.01]
overlap_mm = 1; //[0.5:2:0.1]
pitch_circle_ref_thickness_mm = 0.6; //[0.2:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed pulley body
    cylinder(r=pitch_radius_mm - root_clearance_mm, h=pulley_width_mm, center=true);

    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges
    translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm/2])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm/2])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

    // Bore hole
    translate([0, 0, 0])
      cylinder(r=(bore_diameter_mm + tolerance_mm)/2, h=hub_length_mm + pulley_width_mm + 2*flange_thickness_mm + 2*overlap_mm, center=true);
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([pitch_radius_mm - root_clearance_mm + tooth_depth_mm/2 - overlap_mm, 0, 0])
        cube([tooth_depth_mm, tooth_width_mm, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  printed_pulley_teeth();
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  printed_pulley_GT2_teeth();
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth_from_profile();
}

assembly();