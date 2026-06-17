// Parameters
socket_style_old = 1; //[0:1:1]
switched = 0; //[0:1:1]
include_earth_terminal_position = 1; //[0:1:1]
include_panel_cutout_reference = 0; //[0:1:1]
plate_width = 86; //[60:172:1]
plate_height = 86; //[60:172:1]
plate_thickness = 9; //[5:18:1]
front_lip_thickness = 2; //[1:5:1]
wall_thickness = 2.5; //[1.5:6:0.5]
rear_cavity_depth = 6.5; //[3:13:0.5]
edge_margin = 6; //[3:12:1]
overlap = 1; //[0.5:2:0.5]
pin_hole_depth = 12; //[8:24:1]
pin_hole_clearance = 0.3; //[0:1:0.1]
live_neutral_pitch_x = 22.2; //[18:30:0.1]
live_neutral_y = -11.1; //[-16:-6:0.1]
earth_y = 11.1; //[6:16:0.1]
ln_hole_width = 7; //[5:10:0.1]
ln_hole_height = 4.5; //[3:7:0.1]
earth_hole_width = 4.5; //[3:7:0.1]
earth_hole_height = 8.5; //[6:12:0.1]
screw_pitch_y = 60.3; //[45:90:0.1]
screw_clear_diameter = 3.8; //[3:5:0.1]
counterbore_diameter = 8; //[6:12:0.1]
counterbore_depth = 2.5; //[1:6:0.1]
earth_ref_boss_diameter = 8; //[4:16:0.5]
earth_ref_boss_height = 2; //[1:6:0.5]
earth_ref_inset = 8; //[4:20:0.5]

// Mains Socket - complete geometry
module mains_socket() {
  color("White") {
    difference() {
      // Faceplate body
      cube([plate_width, plate_height, plate_thickness], center=true);
      
      // Rear hollow cavity
      translate([0, 0, -plate_thickness/2 + rear_cavity_depth/2 + overlap/2])
        cube([plate_width - 2*edge_margin, plate_height - 2*edge_margin, rear_cavity_depth + overlap], center=true);
      
      // Pin apertures
      union() {
        translate([-live_neutral_pitch_x/2, live_neutral_y, plate_thickness/2 - (pin_hole_depth + overlap)/2])
          cube([ln_hole_width + pin_hole_clearance, ln_hole_height + pin_hole_clearance, pin_hole_depth + overlap], center=true);
        translate([live_neutral_pitch_x/2, live_neutral_y, plate_thickness/2 - (pin_hole_depth + overlap)/2])
          cube([ln_hole_width + pin_hole_clearance, ln_hole_height + pin_hole_clearance, pin_hole_depth + overlap], center=true);
        translate([0, earth_y, plate_thickness/2 - (pin_hole_depth + overlap)/2])
          cube([earth_hole_width + pin_hole_clearance, earth_hole_height + pin_hole_clearance, pin_hole_depth + overlap], center=true);
      }
      
      // Mounting screw holes
      union() {
        translate([0, screw_pitch_y/2, 0])
          cylinder(h=plate_thickness + 2*overlap, r=screw_clear_diameter/2, center=true);
        translate([0, -screw_pitch_y/2, 0])
          cylinder(h=plate_thickness + 2*overlap, r=screw_clear_diameter/2, center=true);
      }
      
      // Counterbores
      union() {
        translate([0, screw_pitch_y/2, plate_thickness/2 - (counterbore_depth + overlap)/2])
          cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
        translate([0, -screw_pitch_y/2, plate_thickness/2 - (counterbore_depth + overlap)/2])
          cylinder(h=counterbore_depth + overlap, r=counterbore_diameter/2, center=true);
      }
    }
  }
}

// Mains Socket Earth Position - complete geometry
module mains_socket_earth_position() {
  color("Silver") {
    scale([include_earth_terminal_position, include_earth_terminal_position, include_earth_terminal_position]) {
      translate([-plate_width/2 + earth_ref_inset, -plate_height/2 + earth_ref_inset, -plate_thickness/2 - earth_ref_boss_height/2 + overlap])
        cylinder(h=earth_ref_boss_height, r=earth_ref_boss_diameter/2, center=true);
    }
  }
}

// Mains Socket Holes - complete geometry
module mains_socket_holes() {
  // This module is integrated into the mains_socket() as part of the difference operation
}

// Assembly
module assembly() {
  mains_socket();
  mains_socket_earth_position();
}

assembly();