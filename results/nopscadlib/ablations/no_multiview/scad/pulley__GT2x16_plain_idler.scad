// Parameters
pulley_type = 0; //[0:1:1]
teeth_count = 20; //[10:60:1]
outer_diameter_mm = 20; //[10:40:1]
belt_pitch_mm = 2; //[1:5:0.1]
width_mm = 6; //[3:20:1]
bore_diameter_mm = 5; //[2:12:0.5]
hub_diameter_mm = 12; //[6:24:1]
hub_length_mm = 10; //[5:25:1]
flange_diameter_mm = 22; //[12:44:1]
flange_thickness_mm = 1; //[0.5:4:0.5]
set_screw_count = 0; //[0:2:1]
set_screw_diameter_mm = 3; //[2:6:0.5]
set_screw_z_offset_mm = 0; //[-5:5:0.5]
overlap_mm = 1; //[0.5:2:0.5]
tooth_radial_height_mm = 1; //[0.5:3:0.5]
tooth_width_factor = 0.6; //[0.3:0.9:0.05]

// Pulley module
module pulley() {
  color("Silver") {
    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Pulley body
    translate([0, 0, 0])
      cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);

    // Flanges
    if (flange_diameter_mm > 0) {
      translate([0, 0, width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }

    // Teeth (if timing pulley)
    if (pulley_type == 1) {
      for (i = [0:teeth_count-1]) {
        rotate([0, 0, i*360/teeth_count])
          translate([outer_diameter_mm/2 - tooth_radial_height_mm/2, 0, 0])
            cube([tooth_radial_height_mm + overlap_mm, belt_pitch_mm*tooth_width_factor, width_mm], center=true);
      }
    }

    // Shaft bore
    translate([0, 0, 0])
      cylinder(r=bore_diameter_mm/2, h=hub_length_mm + width_mm + 2*flange_thickness_mm + 4*overlap_mm, center=true);

    // Set screw holes
    if (set_screw_count > 0) {
      rotate([0, 90, 0])
        translate([0, 0, set_screw_z_offset_mm])
          cylinder(r=set_screw_diameter_mm/2, h=hub_diameter_mm + 2*overlap_mm, center=true);
    }
    if (set_screw_count > 1) {
      rotate([90, 0, 0])
        translate([0, 0, set_screw_z_offset_mm])
          cylinder(r=set_screw_diameter_mm/2, h=hub_diameter_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();