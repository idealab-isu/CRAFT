// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.75; //[5:20:0.05]
pulley_width_mm = 10; //[5:30:1]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.05]
tooth_tangential_width_mm = 1.6; //[0.8:3.2:0.05]
tooth_root_clearance_mm = 0.6; //[0.3:1.2:0.05]
bore_diameter_mm = 5; //[2:10:0.1]
tolerance_mm = 0.2; //[0:0.6:0.05]
hub_diameter_mm = 14; //[7:28:0.5]
hub_length_mm = 8; //[0:25:1]
hub_enabled = 1; //[0:1:1]
flange_diameter_mm = 16; //[10:32:0.5]
flange_thickness_mm = 1.5; //[0:4:0.1]
flanges_enabled = 1; //[0:1:1]
set_screw_count = 1; //[0:2:1]
set_screw_hole_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_offset_mm = 3; //[0:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Pulley body
    cylinder(h=pulley_width_mm, r=pitch_diameter_mm/2 - tooth_root_clearance_mm, center=true);
    
    // Hub
    if (hub_enabled) {
      translate([0, 0, -pulley_width_mm/2 - hub_length_mm/2 + overlap_mm/2])
        cylinder(h=hub_length_mm + overlap_mm, r=hub_diameter_mm/2, center=true);
    }
    
    // Flanges
    if (flanges_enabled) {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm/2])
        cylinder(h=flange_thickness_mm + overlap_mm, r=flange_diameter_mm/2, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm/2])
        cylinder(h=flange_thickness_mm + overlap_mm, r=flange_diameter_mm/2, center=true);
    }
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count]) {
      translate([(pitch_diameter_mm/2) + (tooth_radial_height_mm + overlap_mm)/2 - overlap_mm, 0, 0])
        cube([tooth_radial_height_mm + overlap_mm, tooth_tangential_width_mm, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  printed_pulley_teeth();
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  union() {
    pulley();
    printed_pulley_teeth();
  }
}

// Assembly
module assembly() {
  difference() {
    printed_pulley_GT2_teeth();
    // Center bore
    translate([0, 0, -(hub_length_mm*hub_enabled)/2])
      cylinder(h=pulley_width_mm + (hub_length_mm*hub_enabled) + (2*flange_thickness_mm*flanges_enabled) + 4*overlap_mm, 
               r=(bore_diameter_mm/2) + tolerance_mm, center=true);
    
    // Set screw holes
    if (set_screw_count >= 1) {
      translate([(hub_diameter_mm/2) * 0.5, 0, -pulley_width_mm/2 - (hub_length_mm*hub_enabled)/2 + set_screw_z_offset_mm])
        rotate([0, 90, 0])
        cylinder(h=(hub_diameter_mm/2) + (pitch_diameter_mm/2) + 4*overlap_mm, 
                 r=(set_screw_hole_diameter_mm/2 + tolerance_mm), center=true);
    }
    if (set_screw_count >= 2) {
      translate([0, (hub_diameter_mm/2) * 0.5, -pulley_width_mm/2 - (hub_length_mm*hub_enabled)/2 + set_screw_z_offset_mm])
        rotate([90, 0, 0])
        cylinder(h=(hub_diameter_mm/2) + (pitch_diameter_mm/2) + 4*overlap_mm, 
                 r=(set_screw_hole_diameter_mm/2 + tolerance_mm), center=true);
    }
  }
}

assembly();