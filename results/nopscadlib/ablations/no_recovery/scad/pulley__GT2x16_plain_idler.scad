// Parameters
pulley_type_timing = 1; //[0:1:1]
tooth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:0.5]
belt_width_mm = 6; //[3:20:0.5]
bore_diameter_mm = 5; //[2:12:0.5]
hub_diameter_mm = 12; //[6:24:0.5]
hub_length_mm = 10; //[5:25:0.5]
flange_diameter_mm = 18; //[10:40:0.5]
flange_thickness_mm = 1; //[0.5:3:0.25]
flanges_enabled = 1; //[0:1:1]
set_screw_count = 0; //[0:4:1]
set_screw_hole_diameter_mm = 3; //[2:6:0.25]
set_screw_z_offset_mm = 5; //[0:20:0.5]
tooth_radial_height_mm = 1.2; //[0.6:2.5:0.1]
tooth_tangential_width_mm = 1.6; //[0.8:3.0:0.1]
tooth_axial_width_mm = 6; //[3:20:0.5]
rim_wall_radial_thickness_mm = 2; //[1:5:0.25]
overlap_mm = 1; //[0.5:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Pulley module
module pulley() {
  color("Silver") {
    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Outer Rim
    difference() {
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=belt_width_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2 - rim_wall_radial_thickness_mm, h=belt_width_mm + 2*eps_mm, center=true);
    }

    // Teeth or Smooth Crown
    if (pulley_type_timing == 1) {
      for (i = [0:tooth_count-1]) {
        rotate([0, 0, i*360/tooth_count])
          translate([outer_diameter_mm/2 - overlap_mm + tooth_radial_height_mm/2, 0, 0])
            cube([tooth_radial_height_mm, tooth_tangential_width_mm, tooth_axial_width_mm], center=true);
      }
    }

    // Flanges
    if (flanges_enabled == 1) {
      translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -belt_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }

    // Bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=hub_length_mm + 2*eps_mm, center=true);

    // Set Screw Holes
    if (set_screw_count > 0) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 90, i*360/set_screw_count])
          translate([0, 0, -hub_length_mm/2 + set_screw_z_offset_mm])
            cylinder(r=set_screw_hole_diameter_mm/2, h=hub_diameter_mm + 2*eps_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();