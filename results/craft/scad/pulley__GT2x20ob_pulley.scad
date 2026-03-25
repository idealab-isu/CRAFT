// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter_mm = 12.22; //[6.11:24.44:0.01]
pitch_radius_mm = 6.11; //[3.055:12.22:0.01]
belt_pitch_mm = 2; //[1:10:0.01]
pulley_width_mm = 10; //[5:30:0.1]
bore_diameter_mm = 5; //[1:12:0.01]
hub_diameter_mm = 16; //[8:32:0.1]
hub_length_mm = 14; //[7:28:0.1]
flange_diameter_mm = 18; //[9:36:0.1]
flange_thickness_mm = 1.5; //[0.8:4:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_thread = 3; //[2:6:1]
set_screw_z_mm = 0; //[-10:10:0.1]
tolerance_mm = 0.2; //[0:0.6:0.01]
connect_overlap_mm = 1; //[0.5:2:0.1]
tooth_radial_height_mm = 0.8; //[0.4:1.6:0.01]
tooth_root_offset_mm = 0.6; //[0.2:1.5:0.01]
tooth_tangential_width_mm = 1.2; //[0.6:2.4:0.01]
tooth_round_radius_mm = 0.55; //[0.3:1.2:0.01]
set_screw_hole_radius_mm = 1.6; //[0.8:3.5:0.01]

// GT2x20 Pulley
module GT2x20_pulley_9() {
  color("Silver") {
    // Toothed Pulley Body
    translate([0, 0, 0])
      cylinder(r=pitch_radius_mm - tooth_root_offset_mm, h=pulley_width_mm, center=true);

    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges
    translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + connect_overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - connect_overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

    // Center Bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2 + tolerance_mm/2, h=hub_length_mm + pulley_width_mm + 2*flange_thickness_mm + 2*connect_overlap_mm, center=true);
  }
}

// Printed Pulley GT2 Teeth
module printed_pulley_GT2_teeth() {
  color("Black") {
    // Tooth Seed
    module tooth_seed() {
      hull() {
        translate([pitch_radius_mm - tooth_root_offset_mm + tooth_radial_height_mm - tooth_round_radius_mm, 0, 0])
          sphere(r=tooth_round_radius_mm);
        translate([pitch_radius_mm - tooth_root_offset_mm + tooth_round_radius_mm, 0, 0])
          sphere(r=tooth_round_radius_mm);
        translate([pitch_radius_mm - tooth_root_offset_mm + tooth_radial_height_mm/2, 0, 0])
          cube([tooth_round_radius_mm*2, tooth_tangential_width_mm, pulley_width_mm], center=true);
      }
    }

    // Rotate and place teeth
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        tooth_seed();
    }
  }
}

// Printed Pulley Teeth From Profile
module printed_pulley_teeth_from_profile() {
  color("DimGray") {
    printed_pulley_GT2_teeth();
    translate([0, 0, 0])
      cylinder(r=pitch_radius_mm - tooth_root_offset_mm, h=pulley_width_mm, center=true);
  }
}

// Printed Pulley Teeth
module printed_pulley_teeth() {
  color("DimGray") {
    printed_pulley_teeth_from_profile();
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
  }
}

// Assembly
module assembly() {
  GT2x20_pulley_9();
  printed_pulley_teeth();
}

assembly();