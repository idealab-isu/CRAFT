// Parameters
tooth_count = 12; //[6:24:1]
pitch_diameter_mm = 7.15; //[3.6:14.3:0.01]
pulley_width_mm = 10; //[5:20:1]
bore_diameter_mm = 5; //[2.5:10:0.1]
hub_diameter_mm = 12; //[6:24:0.1]
hub_length_mm = 8; //[4:16:0.5]
flange_diameter_mm = 14; //[7:28:0.1]
flange_thickness_mm = 1; //[0.5:3:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_hole_diameter_mm = 3; //[2:5:0.1]
set_screw_height_from_base_mm = 4; //[1:12:0.5]
tooth_depth_mm = 0.764; //[0.38:1.53:0.001]
tooth_width_mm = 1.494; //[0.75:3:0.001]
tooth_relief_scale_mm = 0.2; //[0:0.6:0.01]
tooth_outer_radius_offset_mm = 0.6; //[0.2:1.5:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]
chamfer_mm = 0.6; //[0:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Hub
    translate([0, 0, 0])
      cylinder(h=hub_length_mm, r=hub_diameter_mm/2, center=true);

    // Toothed Outer Profile
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2 - overlap_mm])
      cylinder(h=pulley_width_mm, r=pitch_diameter_mm/2 + tooth_outer_radius_offset_mm, center=true);

    // Belt Flanges
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm + pulley_width_mm + flange_thickness_mm/2 - 2*overlap_mm])
      cylinder(h=flange_thickness_mm, r=flange_diameter_mm/2, center=true);

    // Center Bore
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2 - overlap_mm])
      cylinder(h=hub_length_mm + pulley_width_mm + 2*flange_thickness_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);

    // Set Screw Holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 90, 0])
          translate([0, 0, -hub_length_mm/2 + set_screw_height_from_base_mm])
          rotate([0, 0, i*360/set_screw_count])
          cylinder(h=hub_diameter_mm + 2*overlap_mm, r=set_screw_hole_diameter_mm/2, center=true);
      }
    }

    // Chamfers
    translate([0, 0, hub_length_mm/2 - chamfer_mm])
      cylinder(h=2*chamfer_mm, r1=hub_diameter_mm/2 + chamfer_mm, r2=hub_diameter_mm/2 - chamfer_mm, center=true);
    translate([0, 0, -hub_length_mm/2 + chamfer_mm])
      cylinder(h=2*chamfer_mm, r1=hub_diameter_mm/2 - chamfer_mm, r2=hub_diameter_mm/2 + chamfer_mm, center=true);
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  color("Gray") {
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2 - overlap_mm])
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
          translate([0, -(pitch_diameter_mm/2 + tooth_outer_radius_offset_mm - tooth_depth_mm/2 - overlap_mm), 0])
          cube([tooth_width_mm + tooth_relief_scale_mm, tooth_depth_mm, pulley_width_mm + 2*overlap_mm], center=true);
      }
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  color("DarkGray") {
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2 - overlap_mm])
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
          translate([0, -(pitch_diameter_mm/2 + tooth_outer_radius_offset_mm - tooth_depth_mm/2 - overlap_mm), 0])
          cube([tooth_width_mm + tooth_relief_scale_mm, tooth_depth_mm, pulley_width_mm + 2*overlap_mm], center=true);
      }
  }
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  color("LightGray") {
    translate([0, 0, hub_length_mm/2 + flange_thickness_mm + pulley_width_mm/2 - overlap_mm])
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
          translate([0, -(pitch_diameter_mm/2 + tooth_outer_radius_offset_mm - tooth_depth_mm/2 - overlap_mm), 0])
          cube([tooth_width_mm + tooth_relief_scale_mm, tooth_depth_mm, pulley_width_mm + 2*overlap_mm], center=true);
      }
  }
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_teeth_from_profile();
  printed_pulley_GT2_teeth();
  printed_pulley_teeth();
}

assembly();