// Parameters
plate_width_mm = 86; //[43:172:1]
plate_height_mm = 86; //[43:172:1]
plate_thickness_mm = 7; //[3.5:14:0.5]
top_taper_width_mm = 80; //[60:86:0.5]
top_taper_height_mm = 80; //[60:86:0.5]
rear_cavity_depth_mm = 25; //[12.5:50:1]
wall_thickness_mm = 2; //[1:4:0.25]
pin_hole_live_neutral_spacing_mm = 22.2; //[11.1:44.4:0.1]
pin_hole_live_neutral_width_mm = 7; //[3.5:14:0.1]
pin_hole_live_neutral_height_mm = 4.5; //[2.25:9:0.1]
pin_hole_earth_width_mm = 4.5; //[2.25:9:0.1]
pin_hole_earth_height_mm = 8.5; //[4.25:17:0.1]
pin_hole_depth_mm = 8; //[4:16:0.5]
mounting_screw_hole_clearance_diameter_mm = 4; //[2:8:0.1]
mounting_screw_centres_mm = 60.3; //[30.15:120.6:0.1]
counterbore_depth_mm = 2.5; //[1.25:5:0.1]
counterbore_diameter_mm = 8; //[4:16:0.1]
switch_offset_x_mm = 18; //[0:30:0.5]
switch_offset_y_mm = 18; //[0:30:0.5]
switch_recess_width_mm = 28; //[14:56:0.5]
switch_recess_height_mm = 18; //[9:36:0.5]
switch_recess_depth_mm = 1.2; //[0.6:2.4:0.1]
socket_offset_y_mm = -6; //[-15:15:0.5]
earth_offset_y_mm = 11.1; //[6:16:0.1]
live_neutral_offset_y_mm = -11.1; //[-16:-6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Mains Socket - Detailed Geometry
module mains_socket() {
  color("White") {
    difference() {
      // Faceplate body
      hull() {
        translate([0, 0, 0])
          cube([plate_width_mm, plate_height_mm, plate_thickness_mm], center=true);
        translate([0, 0, 0])
          cube([top_taper_width_mm, top_taper_height_mm, plate_thickness_mm], center=true);
      }
      // Rear cavity
      translate([0, 0, -plate_thickness_mm/2 - rear_cavity_depth_mm/2 + overlap_mm])
        cube([plate_width_mm - 2*wall_thickness_mm, plate_height_mm - 2*wall_thickness_mm, rear_cavity_depth_mm], center=true);
    }
  }
}

// Mains Socket Earth Position - Detailed Geometry
module mains_socket_earth_position() {
  color("Gray") {
    translate([0, socket_offset_y_mm + earth_offset_y_mm, plate_thickness_mm/2 - (pin_hole_depth_mm + overlap_mm)/2])
      cube([pin_hole_earth_width_mm, pin_hole_earth_height_mm, pin_hole_depth_mm + overlap_mm], center=true);
  }
}

// Mains Socket Holes - Detailed Geometry
module mains_socket_holes() {
  color("Gray") {
    union() {
      // Live pin hole
      translate([-pin_hole_live_neutral_spacing_mm/2, socket_offset_y_mm + live_neutral_offset_y_mm, plate_thickness_mm/2 - (pin_hole_depth_mm + overlap_mm)/2])
        cube([pin_hole_live_neutral_width_mm, pin_hole_live_neutral_height_mm, pin_hole_depth_mm + overlap_mm], center=true);
      // Neutral pin hole
      translate([pin_hole_live_neutral_spacing_mm/2, socket_offset_y_mm + live_neutral_offset_y_mm, plate_thickness_mm/2 - (pin_hole_depth_mm + overlap_mm)/2])
        cube([pin_hole_live_neutral_width_mm, pin_hole_live_neutral_height_mm, pin_hole_depth_mm + overlap_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  mains_socket();
  mains_socket_earth_position();
  mains_socket_holes();
  // Mounting screw holes
  color("Black") {
    union() {
      translate([0, mounting_screw_centres_mm/2, -rear_cavity_depth_mm/2])
        cylinder(r=mounting_screw_hole_clearance_diameter_mm/2, h=plate_thickness_mm + rear_cavity_depth_mm + 2*overlap_mm, center=true);
      translate([0, -mounting_screw_centres_mm/2, -rear_cavity_depth_mm/2])
        cylinder(r=mounting_screw_hole_clearance_diameter_mm/2, h=plate_thickness_mm + rear_cavity_depth_mm + 2*overlap_mm, center=true);
    }
  }
  // Mounting screw counterbores
  color("Black") {
    union() {
      translate([0, mounting_screw_centres_mm/2, plate_thickness_mm/2 - (counterbore_depth_mm + overlap_mm)/2])
        cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true);
      translate([0, -mounting_screw_centres_mm/2, plate_thickness_mm/2 - (counterbore_depth_mm + overlap_mm)/2])
        cylinder(r=counterbore_diameter_mm/2, h=counterbore_depth_mm + overlap_mm, center=true);
    }
  }
  // Switch recess
  color("Gray") {
    translate([switch_offset_x_mm, switch_offset_y_mm, plate_thickness_mm/2 - (switch_recess_depth_mm + overlap_mm)/2])
      cube([switch_recess_width_mm, switch_recess_height_mm, switch_recess_depth_mm + overlap_mm], center=true);
  }
}

assembly();