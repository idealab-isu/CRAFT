// Parameters
pulley_type_timing = 1; //[0:1:1]
tooth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:1]
belt_width_mm = 6; //[3:18:1]
bore_diameter_mm = 5; //[2.5:10:0.5]
hub_diameter_mm = 12; //[6:24:1]
hub_length_mm = 10; //[5:20:1]
flange_diameter_mm = 18; //[9:36:1]
flange_thickness_mm = 1; //[0.5:3:0.5]
set_screw_count = 2; //[0:4:1]
set_screw_diameter_mm = 3; //[2:6:0.5]
set_screw_z_offset_mm = 5; //[0:10:0.5]
tooth_radial_height_mm = 1; //[0.5:2.5:0.1]
tooth_tangential_width_mm = 1.2; //[0.6:2.4:0.1]
rim_core_radial_thickness_mm = 1.5; //[0.8:4:0.1]
overlap_mm = 1; //[0.5:2:0.5]
hole_extra_length_mm = 2; //[1:10:1]

// Pulley module
module pulley() {
  color("Silver") {
    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Outer Rim
    translate([0, 0, 0])
      cylinder(r=outer_diameter_mm/2 - tooth_radial_height_mm*pulley_type_timing, h=belt_width_mm, center=true);

    // Flanges
    translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    translate([0, 0, -(belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm)])
      cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);

    // Teeth
    if (pulley_type_timing == 1) {
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
          translate([(outer_diameter_mm/2 - tooth_radial_height_mm/2) - overlap_mm, 0, 0])
          cube([tooth_radial_height_mm, tooth_tangential_width_mm, belt_width_mm], center=true);
      }
    }
  }
}

// Assembly module
module assembly() {
  difference() {
    pulley();
    // Bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=hub_length_mm + hole_extra_length_mm, center=true);

    // Set Screw Holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 90, i*360/set_screw_count])
          translate([0, 0, -hub_length_mm/2 + set_screw_z_offset_mm])
          cylinder(r=set_screw_diameter_mm/2, h=hub_diameter_mm + hole_extra_length_mm, center=true);
      }
    }
  }
}

// Final assembly call
assembly();