// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
pulley_width_mm = 7; //[4:20:0.1]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_root_clearance_mm = 0.6; //[0.3:1.2:0.05]
tooth_tangential_width_factor = 0.55; //[0.35:0.75:0.01]
tooth_overlap_mm = 0.8; //[0.3:2:0.05]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 16; //[10:32:0.1]
hub_length_mm = 10; //[5:25:0.1]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[12:40:0.1]
flange_thickness_mm = 1.2; //[0:4:0.1]
overlap_mm = 0.8; //[0.3:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed pulley body
    cylinder(r=pitch_radius_mm - tooth_root_clearance_mm, h=pulley_width_mm, center=true);

    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges
    if (flange_enabled) {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }

    // Central bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=hub_length_mm + 2*flange_thickness_mm + 2*overlap_mm, center=true);
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([pitch_radius_mm + (tooth_radial_height_mm + tooth_overlap_mm)/2 - tooth_overlap_mm, 0, 0])
        cube([tooth_radial_height_mm + tooth_overlap_mm, (PI*pitch_diameter_mm/tooth_count) * tooth_tangential_width_factor, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  color("DimGray") {
    printed_pulley_teeth();
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  color("DimGray") {
    printed_pulley_teeth_from_profile();
  }
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_GT2_teeth();
}

assembly();