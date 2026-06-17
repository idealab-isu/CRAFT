// Parameters
tooth_count = 20; //[10:80:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
belt_pitch_mm = 2; //[1:10:0.01]
pulley_width_mm = 7; //[3.5:14:0.1]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_tangential_width_mm = 1.4; //[0.7:2.8:0.05]
tooth_overlap_mm = 0.8; //[0.3:2:0.05]
bore_diameter_mm = 5; //[2.5:10:0.01]
hub_diameter_mm = 16; //[8:32:0.1]
hub_length_mm = 10; //[5:20:0.1]
flanges_optional_by_param = 1; //[0:1:1]
flange_diameter_mm = 18; //[9:36:0.1]
flange_thickness_mm = 1.5; //[0.8:3:0.1]
tolerance_mm = 0.2; //[0:0.6:0.01]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    union() {
      // Toothed pulley body
      cylinder(r=pitch_radius_mm + tooth_radial_height_mm - tooth_overlap_mm, h=pulley_width_mm, center=true);
      
      // Hub section
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
      
      // Flanges
      if (flanges_optional_by_param) {
        translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2])
          cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2])
          cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      }
    }
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count]) {
      translate([pitch_radius_mm + (tooth_radial_height_mm + tooth_overlap_mm)/2 - tooth_overlap_mm, 0, 0]) {
        cube([tooth_radial_height_mm + tooth_overlap_mm, tooth_tangential_width_mm, pulley_width_mm], center=true);
      }
    }
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  union() {
    printed_pulley_teeth();
    cylinder(r=pitch_radius_mm, h=pulley_width_mm, center=true);
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  union() {
    printed_pulley_teeth_from_profile();
  }
}

// Assembly
module assembly() {
  difference() {
    union() {
      pulley();
      printed_pulley_GT2_teeth();
    }
    // Center bore
    cylinder(r=(bore_diameter_mm + tolerance_mm)/2, h=hub_length_mm + pulley_width_mm + 2*flange_thickness_mm + 2, center=true);
  }
}

assembly();