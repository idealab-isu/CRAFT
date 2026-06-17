// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
pulley_width_mm = 10; //[5:30:0.5]
bore_diameter_mm = 5; //[2:12:0.1]
hub_diameter_mm = 16; //[8:32:0.5]
hub_length_mm = 12; //[0:30:0.5]
flange_diameter_mm = 18; //[10:40:0.5]
flange_thickness_mm = 1.5; //[0:5:0.1]
set_screw_count = 1; //[0:4:1]
set_screw_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_offset_mm = 0; //[-20:20:0.5]
tooth_standard = 2; //[1:5:1]
tooth_pitch_mm = 2; //[1:5:0.01]
tooth_depth_mm = 0.75; //[0.3:2:0.01]
tooth_width_mm = 1.2; //[0.6:3:0.01]
tolerances_mm = 0.2; //[0:0.6:0.01]
tooth_root_radius_mm = 0.55; //[0.2:1.2:0.01]
tooth_overlap_mm = 0.8; //[0.2:2:0.01]
connection_overlap_mm = 1; //[0.5:2:0.1]
set_screw_length_mm = 50; //[20:120:1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed pulley body
    difference() {
      cylinder(h=pulley_width_mm, r=pitch_radius_mm + tooth_depth_mm, center=true);
      printed_pulley_teeth();
      // Central bore
      cylinder(h=pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 4*connection_overlap_mm, 
               r=(bore_diameter_mm + 2*tolerances_mm)/2, center=true);
    }
    // Hub
    if (hub_length_mm > 0) {
      translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - connection_overlap_mm)])
        cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);
    }
    // Flanges
    if (flange_thickness_mm > 0) {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm])
        cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
      translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - connection_overlap_mm)])
        cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
    }
    // Set screw holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 0, i*360/set_screw_count])
          translate([hub_diameter_mm/2 - connection_overlap_mm, 0, 
                     -(pulley_width_mm/2 + hub_length_mm/2 - connection_overlap_mm) + set_screw_z_offset_mm])
            rotate([0, 90, 0])
              cylinder(h=set_screw_length_mm, r=(set_screw_diameter_mm + 2*tolerances_mm)/2, center=true);
      }
    }
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  for (i = [0:tooth_count-1]) {
    rotate([0, 0, i*360/tooth_count]) {
      translate([0, (pitch_radius_mm + tooth_depth_mm) - (tooth_depth_mm/2) - tooth_overlap_mm, 0])
        printed_pulley_teeth_from_profile();
    }
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  hull() {
    translate([0, tooth_root_radius_mm, 0])
      linear_extrude(height=pulley_width_mm + 2*connection_overlap_mm, center=true)
        square([2*tooth_root_radius_mm, 2*tooth_root_radius_mm], center=true);
    linear_extrude(height=pulley_width_mm + 2*connection_overlap_mm, center=true)
      circle(r=tooth_root_radius_mm);
  }
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  printed_pulley_teeth();
}

// Assembly
module assembly() {
  pulley();
}

assembly();