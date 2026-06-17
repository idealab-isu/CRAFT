// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.75; //[5:20:0.05]
pitch_radius_mm = 4.875; //[2.5:10:0.05]
belt_pitch_mm = 2; //[1:5:0.01]
pulley_width_mm = 10; //[5:30:0.5]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 12; //[6:24:0.5]
hub_length_mm = 14; //[6:30:0.5]
flange_diameter_mm = 14; //[8:30:0.5]
flange_thickness_mm = 1.5; //[0:4:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_offset_mm = 0; //[-10:10:0.5]
tooth_radial_height_mm = 0.8; //[0.3:2:0.05]
tooth_root_depth_mm = 0.4; //[0.1:1.5:0.05]
tooth_tangential_width_factor = 0.55; //[0.3:0.9:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed pulley body
    cylinder(r=pitch_radius_mm + tooth_radial_height_mm, h=pulley_width_mm, center=true);
    
    // Hub
    cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
    
    // Flanges
    if (flange_thickness_mm > 0) {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count]) {
        translate([pitch_radius_mm + (tooth_radial_height_mm + tooth_root_depth_mm)/2 - overlap_mm, 0, 0])
          cube([tooth_radial_height_mm + tooth_root_depth_mm, belt_pitch_mm * tooth_tangential_width_factor, pulley_width_mm], center=true);
      }
    }
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  printed_pulley_GT2_teeth();
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  printed_pulley_teeth_from_profile();
}

// Assembly
module assembly() {
  difference() {
    union() {
      pulley();
      printed_pulley_teeth();
    }
    // Center bore
    cylinder(r=bore_diameter_mm/2, h=hub_length_mm + 2*overlap_mm, center=true);
    
    // Set screw holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 90, i*90]) {
          translate([0, 0, set_screw_z_offset_mm])
            cylinder(r=set_screw_diameter_mm/2, h=hub_diameter_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

assembly();