// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 12.16; //[6.08:24.32:0.01]
pulley_width_mm = 10; //[5:30:0.5]
tooth_radial_height_mm = 0.8; //[0.4:1.6:0.05]
tooth_root_clearance_mm = 0.4; //[0.2:1.0:0.05]
tooth_tangential_width_factor = 0.55; //[0.35:0.8:0.01]
bore_diameter_mm = 5; //[2:10:0.1]
hub_diameter_mm = 16; //[10:32:0.5]
hub_length_mm = 14; //[6:40:0.5]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[12:40:0.5]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_hole_diameter_mm = 3; //[1.5:5:0.1]
set_screw_z_from_center_mm = 0; //[-10:10:0.5]
overlap_mm = 1; //[0.5:2:0.1]
tolerances_mm = 0.2; //[0:0.6:0.05]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Pulley body
    cylinder(h=pulley_width_mm, r=pitch_diameter_mm/2 - tooth_root_clearance_mm, center=true);
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  color("DimGray") {
    // Single tooth
    module tooth() {
      translate([pitch_diameter_mm/2 + (tooth_radial_height_mm - tooth_root_clearance_mm)/2 - overlap_mm/2, 0, 0])
      cube([tooth_radial_height_mm + tooth_root_clearance_mm + overlap_mm, 
            (PI*pitch_diameter_mm/tooth_count)*tooth_tangential_width_factor, 
            pulley_width_mm], center=true);
    }
    // Rotate and place teeth
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count]) tooth();
    }
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  color("DimGray") {
    printed_pulley_teeth_from_profile();
  }
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  color("DimGray") {
    printed_pulley_GT2_teeth();
  }
}

// Hub
module hub() {
  color("Silver") {
    cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);
  }
}

// Flanges
module flanges() {
  if (flange_enabled) {
    color("Silver") {
      // Top flange
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
      // Bottom flange
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
    }
  }
}

// Center Bore
module center_bore() {
  cylinder(h=hub_length_mm + 2*flange_thickness_mm + 2*overlap_mm, 
           r=(bore_diameter_mm + tolerances_mm)/2, center=true);
}

// Set Screw Holes
module set_screw_holes() {
  if (set_screw_count > 0) {
    color("Black") {
      // First set screw hole
      rotate([0, 90, 0])
      translate([0, 0, set_screw_z_from_center_mm])
      cylinder(h=hub_diameter_mm + 2*overlap_mm, 
               r=(set_screw_hole_diameter_mm + tolerances_mm)/2, center=true);
      // Second set screw hole if needed
      if (set_screw_count == 2) {
        rotate([90, 0, 0])
        translate([0, 0, set_screw_z_from_center_mm])
        cylinder(h=hub_diameter_mm + 2*overlap_mm, 
                 r=(set_screw_hole_diameter_mm + tolerances_mm)/2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  difference() {
    union() {
      pulley();
      printed_pulley_teeth();
      hub();
      flanges();
    }
    center_bore();
    set_screw_holes();
  }
}

assembly();