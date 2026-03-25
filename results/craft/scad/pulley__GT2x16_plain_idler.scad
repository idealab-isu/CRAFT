// Parameters
pulley_type = 0; //[0:1:1]
teeth_count = 20; //[10:60:1]
outer_diameter_mm = 16; //[8:32:0.5]
belt_pitch_mm = 2; //[1:5:0.1]
belt_width_mm = 6; //[3:20:0.5]
bore_diameter_mm = 5; //[2:12:0.1]
hub_diameter_mm = 12; //[6:24:0.5]
hub_length_mm = 10; //[5:25:0.5]
flange_diameter_mm = 18; //[10:36:0.5]
flange_thickness_mm = 1; //[0.5:3:0.1]
has_flanges = 1; //[0:1:1]
set_screw_count = 1; //[0:2:1]
set_screw_diameter_mm = 3; //[1.5:6:0.1]
set_screw_z_offset_mm = 5; //[0:20:0.5]
overlap_mm = 1; //[0.5:2:0.1]
tooth_depth_mm = 1.2; //[0.6:2.5:0.1]
tooth_width_mm = 1.2; //[0.6:3:0.1]
idler_groove_depth_mm = 1; //[0:3:0.1]
idler_groove_radius_mm = 1.5; //[0.5:4:0.1]
rim_thickness_radial_mm = 2; //[1:6:0.1]

// Pulley module
module pulley() {
  color("Silver") {
    // Pulley body and hub
    union() {
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=hub_length_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=hub_diameter_mm/2, h=hub_length_mm, center=true);
    }

    // Rim base
    difference() {
      translate([0, 0, 0])
        cylinder(r=outer_diameter_mm/2, h=belt_width_mm, center=true);
      translate([0, 0, 0])
        cylinder(r=bore_diameter_mm/2, h=hub_length_mm + 2*overlap_mm, center=true);
    }

    // Timing teeth or idler groove
    if (pulley_type == 0) {
      // Timing teeth
      for (i = [0:teeth_count-1]) {
        rotate([0, 0, i*360/teeth_count])
          translate([outer_diameter_mm/2 - tooth_depth_mm/2, 0, 0])
          cube([tooth_depth_mm + overlap_mm, tooth_width_mm, belt_width_mm], center=true);
      }
    } else {
      // Idler groove
      difference() {
        translate([0, 0, 0])
          cylinder(r=outer_diameter_mm/2, h=belt_width_mm, center=true);
        scale([idler_groove_radius_mm/(outer_diameter_mm/2 - idler_groove_depth_mm),
               idler_groove_radius_mm/(outer_diameter_mm/2 - idler_groove_depth_mm),
               belt_width_mm/(2*idler_groove_radius_mm)])
          rotate_extrude() translate([outer_diameter_mm/2 - idler_groove_depth_mm, 0, 0])
          circle(r=idler_groove_radius_mm);
      }
    }

    // Flanges
    if (has_flanges) {
      union() {
        translate([0, 0, belt_width_mm/2 + flange_thickness_mm/2 - overlap_mm])
          cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
        translate([0, 0, -belt_width_mm/2 - flange_thickness_mm/2 + overlap_mm])
          cylinder(r=flange_diameter_mm/2, h=flange_thickness_mm, center=true);
      }
    }

    // Set screw holes
    if (set_screw_count > 0) {
      difference() {
        translate([hub_diameter_mm/2 - overlap_mm, 0, -hub_length_mm/2 + set_screw_z_offset_mm])
          rotate([0, 90, 0])
          cylinder(r=set_screw_diameter_mm/2, h=hub_diameter_mm + outer_diameter_mm + 2*overlap_mm, center=true);
        if (set_screw_count == 2) {
          translate([hub_diameter_mm/2 - overlap_mm, 0, -hub_length_mm/2 + set_screw_z_offset_mm])
            rotate([0, 90, 90])
            cylinder(r=set_screw_diameter_mm/2, h=hub_diameter_mm + outer_diameter_mm + 2*overlap_mm, center=true);
        }
      }
    }
  }
}

// Assembly
module assembly() {
  pulley();
}

assembly();