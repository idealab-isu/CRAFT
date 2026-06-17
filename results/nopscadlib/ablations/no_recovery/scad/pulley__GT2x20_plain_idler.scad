// Parameters
pulley_type = 1; //[0:1:1]
tooth_profile = 0; //[0:2:1]
tooth_count = 20; //[10:60:1]
outer_diameter_mm = 20; //[10:40:1]
belt_width_mm = 6; //[3:20:1]
bore_diameter_mm = 5; //[2.5:10:0.5]
hub_diameter_mm = 12; //[6:24:1]
hub_length_mm = 10; //[5:20:1]
flange_diameter_mm = 22; //[11:44:1]
flange_thickness_mm = 1; //[0:3:0.5]
set_screw_count = 0; //[0:2:1]
set_screw_diameter_mm = 3; //[0:6:0.5]
set_screw_z_offset_mm = 0; //[-5:5:0.5]
rim_wall_mm = 3; //[1.5:6:0.5]
tooth_radial_height_mm = 1.2; //[0:2.4:0.1]
tooth_tangential_width_factor = 0.55; //[0.3:0.8:0.05]
overlap_mm = 1; //[0.5:2:0.5]
set_screw_length_mm = 40; //[20:80:1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Rim
    difference() {
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=belt_width_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2 - rim_wall_mm, h=belt_width_mm + 2*overlap_mm, center=true);
    }

    // Flanges
    if (flange_thickness_mm > 0) {
      translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -(belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm)])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }

    // Teeth
    if (pulley_type == 1 && tooth_radial_height_mm > 0) {
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
          translate([outer_diameter_mm/2 + (tooth_radial_height_mm + overlap_mm)/2 - overlap_mm, 0, 0])
          cube([tooth_radial_height_mm + overlap_mm, (PI*outer_diameter_mm/tooth_count) * tooth_tangential_width_factor, belt_width_mm], center=true);
      }
    }

    // Bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=hub_length_mm + 2*flange_thickness_mm + belt_width_mm + 4*overlap_mm, center=true);

    // Set Screw Holes
    if (set_screw_diameter_mm > 0) {
      if (set_screw_count >= 1) {
        rotate([0, 90, 0])
          translate([0, 0, set_screw_z_offset_mm])
          cylinder(r=set_screw_diameter_mm/2, h=set_screw_length_mm, center=true);
      }
      if (set_screw_count == 2) {
        rotate([90, 0, 0])
          translate([0, 0, set_screw_z_offset_mm])
          cylinder(r=set_screw_diameter_mm/2, h=set_screw_length_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();