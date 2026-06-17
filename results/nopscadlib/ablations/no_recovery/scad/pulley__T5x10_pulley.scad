// Parameters
tooth_count = 10; //[5:40:1]
pitch_diameter_mm = 15; //[7.5:30:0.1]
pitch_radius_mm = 7.5; //[3.75:15:0.1]
pulley_width_mm = 10; //[5:30:0.5]
bore_diameter_mm = 5; //[2:12:0.1]
hub_diameter_mm = 18; //[10:36:0.5]
hub_length_mm = 6; //[0:20:0.5]
flange_diameter_mm = 20; //[12:40:0.5]
flange_thickness_mm = 1.5; //[0:5:0.1]
set_screw_count = 1; //[0:2:1]
set_screw_size = 3; //[2:6:0.5]
set_screw_z_mm = 0; //[-20:20:0.5]
tolerance_mm = 0.2; //[0:0.6:0.05]
tooth_radial_height_mm = 1.2; //[0.6:2.4:0.1]
tooth_root_depth_mm = 0.6; //[0.3:1.5:0.1]
tooth_tangential_width_factor = 0.55; //[0.3:0.8:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]

// Pulley - complete geometry
module pulley() {
  color("Silver") {
    // Toothed Pulley Body
    translate([0, 0, 0])
      cylinder(r=pitch_radius_mm + tooth_radial_height_mm, h=pulley_width_mm, center=true);

    // Hub
    translate([0, 0, -hub_length_mm/2])
      cylinder(r=hub_diameter_mm/2, h=pulley_width_mm + hub_length_mm, center=true);

    // Flanges
    if (flange_thickness_mm > 0) {
      translate([0, 0, pulley_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -pulley_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }

    // Central Bore
    translate([0, 0, -hub_length_mm/2])
      cylinder(r=(bore_diameter_mm + tolerance_mm)/2, h=pulley_width_mm + hub_length_mm + 2*flange_thickness_mm + 4*overlap_mm, center=true);
  }
}

// Printed Pulley Teeth - complete geometry
module printed_pulley_teeth() {
  color("DimGray") {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*360/tooth_count])
        translate([pitch_radius_mm + tooth_radial_height_mm/2 - overlap_mm/2, 0, 0])
          cube([tooth_radial_height_mm + tooth_root_depth_mm + overlap_mm, (PI * pitch_diameter_mm / tooth_count) * tooth_tangential_width_factor, pulley_width_mm], center=true);
    }
  }
}

// Printed Pulley Teeth From Profile - complete geometry
module printed_pulley_teeth_from_profile() {
  printed_pulley_teeth();
}

// Printed Pulley GT2 Teeth - complete geometry
module printed_pulley_GT2_teeth() {
  printed_pulley_teeth_from_profile();
}

// Assembly
module assembly() {
  pulley();
  printed_pulley_GT2_teeth();
}

assembly();