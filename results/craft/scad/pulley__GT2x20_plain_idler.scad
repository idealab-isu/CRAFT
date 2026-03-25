// Parameters
pulley_type = 0; //[0:1:1]
teeth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:1]
belt_pitch_mm = 2; //[1:5:0.5]
width_mm = 6; //[3:20:1]
bore_diameter_mm = 5; //[2:12:0.5]
hub_diameter_mm = 12; //[6:24:1]
hub_length_mm = 10; //[5:25:1]
flange_enabled = 1; //[0:1:1]
flange_diameter_mm = 18; //[10:36:1]
flange_thickness_mm = 1; //[0.5:4:0.5]
set_screw_enabled = 1; //[0:1:1]
set_screw_count = 1; //[1:4:1]
set_screw_diameter_mm = 3; //[2:6:0.5]
set_screw_z_offset_mm = 5; //[0:20:1]
flat_enabled = 0; //[0:1:1]
flat_depth_mm = 0.8; //[0.4:2:0.1]
overlap_mm = 1; //[0.5:2:0.5]
clearance_mm = 0.2; //[0:0.6:0.05]
rim_radius = 8; //[4:16:1]
hub_radius = 6; //[3:12:1]
bore_radius = 2.5; //[1:6:0.5]
tooth_radial_height_mm = 0.8; //[0.4:2:0.1]
tooth_tangential_width_mm = 1.2; //[0.6:3:0.1]

// Pulley module
module pulley() {
  color("Silver") {
    // Pulley body
    cylinder(r=outer_diameter_mm/2, h=width_mm, center=true);

    // Hub
    translate([0, 0, 0])
      cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);

    // Flanges
    if (flange_enabled) {
      translate([0, 0, width_mm/2 + flange_thickness_mm/2 - overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      translate([0, 0, -width_mm/2 - flange_thickness_mm/2 + overlap_mm])
        cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
    }

    // Teeth for timing pulley
    if (pulley_type == 0) {
      for (i = [0:teeth_count-1]) {
        rotate([0, 0, i*360/teeth_count])
          translate([outer_diameter_mm/2 - tooth_radial_height_mm/2, 0, 0])
            cube([tooth_radial_height_mm, tooth_tangential_width_mm, width_mm], center=true);
      }
    }

    // Bore hole
    difference() {
      cylinder(r=bore_diameter_mm/2 + clearance_mm, h=hub_length_mm + width_mm + 2*flange_thickness_mm + 4*overlap_mm, center=true);
      
      // Flat cut for D-bore
      if (flat_enabled) {
        translate([bore_diameter_mm/2 + clearance_mm - flat_depth_mm, 0, 0])
          cube([2*(bore_diameter_mm/2 + clearance_mm), 2*(bore_diameter_mm/2 + clearance_mm), hub_length_mm + width_mm + 2*flange_thickness_mm + 4*overlap_mm], center=true);
      }
    }

    // Set screw holes
    if (set_screw_enabled) {
      for (i = [0:set_screw_count-1]) {
        rotate([0, 0, i*360/set_screw_count])
          translate([0, 0, -hub_length_mm/2 + set_screw_z_offset_mm])
            rotate([0, 90, 0])
              cylinder(r=set_screw_diameter_mm/2 + clearance_mm, h=hub_diameter_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();