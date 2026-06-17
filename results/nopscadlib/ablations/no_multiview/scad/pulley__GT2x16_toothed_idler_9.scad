// Parameters
tooth_count = 16; //[8:64:1]
pitch_diameter_mm = 9.75; //[5:20:0.01]
pitch_radius_mm = 4.875; //[2.5:10:0.001]
belt_pitch_mm = 2; //[1:10:0.01]
tooth_depth_mm = 0.8; //[0.4:2:0.01]
tooth_width_mm = 1.5; //[0.8:4:0.01]
pulley_width_mm = 10; //[5:30:0.1]
bore_diameter_mm = 5; //[2:12:0.01]
hub_diameter_mm = 12; //[6:30:0.1]
hub_length_mm = 6; //[0:20:0.1]
flange_diameter_mm = 14; //[8:40:0.1]
flange_thickness_mm = 1.5; //[0:5:0.1]
set_screw_count = 1; //[0:4:1]
set_screw_hole_diameter_mm = 3; //[1.5:6:0.01]
set_screw_z_offset_mm = 3; //[0:20:0.1]
tolerance_mm = 0.2; //[0:0.6:0.01]
overlap_mm = 1; //[0.5:2:0.1]
pitch_ref_radial_thickness_mm = 0.4; //[0.2:1.5:0.05]
pitch_ref_z_thickness_mm = 0.6; //[0.2:2:0.05]

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  rotate_extrude() {
    polygon(points=[
      [pitch_radius_mm - tooth_depth_mm, -tooth_width_mm/2],
      [pitch_radius_mm + tooth_depth_mm, -tooth_width_mm/2],
      [pitch_radius_mm + tooth_depth_mm, tooth_width_mm/2],
      [pitch_radius_mm - tooth_depth_mm, tooth_width_mm/2]
    ]);
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  rotate([0, 0, 180/tooth_count])
    printed_pulley_teeth_from_profile();
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  printed_pulley_GT2_teeth();
}

// Pulley
module pulley() {
  color("Silver") {
    // Pulley body with hub and flanges
    union() {
      // Pulley body
      cylinder(r=pitch_radius_mm + tooth_depth_mm, h=pulley_width_mm, center=true);
      // Hub
      translate([0, 0, -(pulley_width_mm/2 + hub_length_mm/2 - overlap_mm)])
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
      // Flanges
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -(pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm)])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }
    // Pitch circle reference
    translate([0, 0, pulley_width_mm/2 - pitch_ref_z_thickness_mm/2 - overlap_mm])
      difference() {
        cylinder(r=pitch_radius_mm + pitch_ref_radial_thickness_mm/2, h=pitch_ref_z_thickness_mm, center=true);
        cylinder(r=pitch_radius_mm - pitch_ref_radial_thickness_mm/2, h=pitch_ref_z_thickness_mm + 2*overlap_mm, center=true);
      }
    // Center bore
    difference() {
      cylinder(r=bore_diameter_mm/2 + tolerance_mm, h=pulley_width_mm + 2*flange_thickness_mm + hub_length_mm + 4*overlap_mm, center=true);
      // Set screw holes
      if (set_screw_count > 0) {
        for (i = [0 : 360/set_screw_count : 360-360/set_screw_count]) {
          rotate([0, 0, i])
            translate([hub_diameter_mm/2 - (set_screw_hole_diameter_mm/2 + tolerance_mm) - overlap_mm, 0, -(pulley_width_mm/2 + hub_length_mm) + set_screw_z_offset_mm])
              rotate([0, 90, 0])
                cylinder(r=set_screw_hole_diameter_mm/2 + tolerance_mm, h=hub_diameter_mm + 4*overlap_mm, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth();
}

assembly();