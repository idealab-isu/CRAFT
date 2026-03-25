// Parameters
pulley_type_timing = 0; //[0:1:1]
teeth_count = 20; //[10:60:1]
outer_diameter_mm = 20; //[10:40:1]
belt_width_mm = 6; //[3:20:1]
bore_diameter_mm = 5; //[2:12:0.5]
hub_diameter_mm = 12; //[6:24:1]
hub_length_mm = 10; //[5:25:1]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 22; //[12:44:1]
flange_thickness_mm = 1; //[1:4:0.5]
set_screw_count = 0; //[0:2:1]
set_screw_diameter_mm = 3; //[2:6:0.5]
set_screw_z_offset_mm = 5; //[0:20:0.5]
flat_enabled = 0; //[0:1:1]
flat_depth_mm = 0.8; //[0.4:2:0.1]
tooth_radial_height_mm = 1.2; //[0.6:2.5:0.1]
tooth_tangential_width_mm = 1.2; //[0.6:3:0.1]
rim_overlap_mm = 1; //[0.5:2:0.1]

// Pulley module
module pulley() {
  color("Silver") {
    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Pulley body
    translate([0, 0, 0])
      cylinder(r=outer_diameter_mm/2, h=belt_width_mm, center=true);

    // Flanges
    if (flange_enabled) {
      translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - rim_overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -belt_width_mm/2 - flange_thickness_mm/2 + rim_overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }

    // Teeth
    if (pulley_type_timing) {
      for (i = [0:teeth_count-1]) {
        rotate([0, 0, i*360/teeth_count])
          translate([outer_diameter_mm/2 - tooth_radial_height_mm/2, 0, 0])
          cube([tooth_radial_height_mm, tooth_tangential_width_mm, belt_width_mm], center=true);
      }
    }

    // Bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=hub_length_mm + belt_width_mm + 2*flange_thickness_mm, center=true);

    // Set screw holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 0, i*180])
          translate([0, 0, -hub_length_mm/2 + set_screw_z_offset_mm])
          rotate([0, 90, 0])
          cylinder(r=set_screw_diameter_mm/2, h=hub_diameter_mm + 2*outer_diameter_mm, center=true);
      }
    }

    // Flat cut
    if (flat_enabled) {
      translate([bore_diameter_mm/2 - flat_depth_mm/2, 0, 0])
        cube([bore_diameter_mm, bore_diameter_mm*2, hub_length_mm + belt_width_mm + 2*flange_thickness_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();