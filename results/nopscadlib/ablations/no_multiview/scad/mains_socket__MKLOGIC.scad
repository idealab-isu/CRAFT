// Parameters
faceplate_width = 86; //[60:172:1]
faceplate_height = 86; //[60:172:1]
faceplate_thickness = 9; //[5:18:1]
top_width_taper = 6; //[2:12:1]
edge_rounding_radius = 2; //[0.5:6:0.5]
rear_cavity_depth = 6; //[3:14:1]
rear_cavity_margin = 8; //[4:16:1]
rear_cavity_top_clearance = 14; //[8:28:1]
mounting_hole_pitch = 60.3; //[45:120:0.1]
mounting_hole_clearance_diameter = 3.8; //[3:5:0.1]
countersink_top_diameter = 8.5; //[6:14:0.1]
countersink_depth = 3; //[1:6:0.1]
counterbore_diameter = 0; //[0:14:0.1]
counterbore_depth = 0; //[0:8:0.1]
pin_live_neutral_center_x = 11.1; //[9:14:0.1]
pin_live_neutral_center_y = -11.1; //[-14:-8:0.1]
pin_earth_center_y = 11.1; //[8:14:0.1]
pin_ln_width_x = 7; //[5:10:0.1]
pin_ln_width_y = 4.5; //[3.5:7:0.1]
pin_earth_width_x = 4.5; //[3.5:7:0.1]
pin_earth_width_y = 8.5; //[6:12:0.1]
aperture_cut_depth = 12; //[8:25:1]
switch_offset_x = 18; //[10:30:0.5]
switch_offset_y = 18; //[10:30:0.5]
switch_feature_width = 28; //[18:45:1]
switch_feature_height = 18; //[12:30:1]
switch_feature_depth = 2; //[1:5:0.1]
earth_screw_hole = 1; //[0:1:1]
earth_screw_clearance_diameter = 3.2; //[2.5:4.5:0.1]
earth_screw_countersink_top_diameter = 7.5; //[6:12:0.1]
earth_screw_countersink_depth = 2.5; //[1:5:0.1]
overlap = 1; //[0.5:2:0.1]

// Mains Socket - complete geometry
module mains_socket() {
  color("White") {
    // Faceplate with rounded edges
    difference() {
      minkowski() {
        hull() {
          translate([0, 0, faceplate_thickness/2 - overlap/2])
            cube([faceplate_width, faceplate_height, overlap], center=true);
          translate([0, 0, -faceplate_thickness/2 + overlap/2])
            cube([faceplate_width - 2*top_width_taper, faceplate_height - 2*top_width_taper, overlap], center=true);
        }
        sphere(r=edge_rounding_radius, center=true);
      }
      // Rear cavity
      translate([0, -rear_cavity_top_clearance/2, -faceplate_thickness/2 + (rear_cavity_depth + overlap)/2])
        cube([faceplate_width - 2*rear_cavity_margin, faceplate_height - 2*rear_cavity_margin - rear_cavity_top_clearance, rear_cavity_depth + overlap], center=true);
    }
  }
}

// Mains Socket Holes - complete geometry
module mains_socket_holes() {
  color("Black") {
    union() {
      // Live and Neutral pin apertures
      translate([-pin_live_neutral_center_x, pin_live_neutral_center_y, 0])
        cube([pin_ln_width_x, pin_ln_width_y, aperture_cut_depth], center=true);
      translate([pin_live_neutral_center_x, pin_live_neutral_center_y, 0])
        cube([pin_ln_width_x, pin_ln_width_y, aperture_cut_depth], center=true);
      // Earth pin aperture
      translate([0, pin_earth_center_y, 0])
        cube([pin_earth_width_x, pin_earth_width_y, aperture_cut_depth], center=true);
    }
  }
}

// Mains Socket Earth Position - complete geometry
module mains_socket_earth_position() {
  if (earth_screw_hole) {
    color("Silver") {
      union() {
        // Earth screw hole
        translate([0, pin_earth_center_y, 0])
          cylinder(r=earth_screw_clearance_diameter/2, h=faceplate_thickness + 2*overlap, center=true);
        // Earth screw countersink
        translate([0, pin_earth_center_y, faceplate_thickness/2 - (earth_screw_countersink_depth + overlap)/2])
          cylinder(r1=earth_screw_countersink_top_diameter/2, r2=earth_screw_clearance_diameter/2, h=earth_screw_countersink_depth + overlap, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  mains_socket();
  mains_socket_holes();
  mains_socket_earth_position();
}

assembly();