// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
belt_pitch_mm = 2; //[1:10:0.01]
pulley_width_mm = 7; //[4:20:0.1]
tooth_depth_mm = 0.8; //[0.4:1.6:0.01]
tooth_width_mm = 1.5; //[0.8:3:0.01]
tooth_profile_scale = 1; //[0.8:1.2:0.01]
tooth_root_radius_offset_mm = 0.6; //[0.2:1.5:0.01]
tooth_outer_radius_offset_mm = 0.9; //[0.3:2:0.01]
hub_diameter_mm = 18; //[10:36:0.1]
hub_length_mm = 10; //[5:25:0.1]
bore_diameter_mm = 5; //[2:12:0.01]
flange_outer_diameter_mm = 16; //[10:30:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
flanges_enabled = 1; //[0:1:1]
set_screw_count = 1; //[0:2:1]
set_screw_hole_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_offset_mm = 0; //[-5:5:0.1]
set_screw_radial_inset_mm = 1; //[0.5:3:0.1]
d_flat_enabled = 0; //[0:1:1]
d_flat_depth_mm = 0.6; //[0.2:2:0.01]
keyway_enabled = 0; //[0:1:1]
keyway_width_mm = 2; //[1:5:0.1]
keyway_depth_mm = 1; //[0.5:3:0.1]
tolerance_mm = 0.2; //[0.05:0.6:0.01]
overlap_mm = 1; //[0.5:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed Rim
    difference() {
      cylinder(r=pitch_radius_mm + tooth_outer_radius_offset_mm, h=pulley_width_mm, center=true);
      cylinder(r=pitch_radius_mm - tooth_root_radius_offset_mm, h=pulley_width_mm + 2*overlap_mm, center=true);
    }
    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
    // Flanges
    if (flanges_enabled) {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  scale([tooth_profile_scale, tooth_profile_scale, 1]) {
    translate([pitch_radius_mm + tooth_depth_mm/2 - overlap_mm, 0, 0]) {
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count]) {
          linear_extrude(height=pulley_width_mm) {
            polygon(points=[
              [-tooth_width_mm/2, 0],
              [-tooth_width_mm/2, tooth_depth_mm],
              [0, tooth_depth_mm*1.15],
              [tooth_width_mm/2, tooth_depth_mm],
              [tooth_width_mm/2, 0]
            ]);
          }
        }
      }
    }
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  printed_pulley_teeth_from_profile();
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