// Parameters
faceplate_width = 86; //[43:172:1]
faceplate_height = 86; //[43:172:1]
overall_depth = 25; //[12:50:1]
faceplate_thickness_edge = 3; //[1.5:6:0.5]
faceplate_thickness_center = 5; //[2.5:10:0.5]
corner_radius = 6; //[3:12:0.5]
top_profile_taper_enabled = 1; //[0:1:1]
top_profile_inset = 2; //[0.5:6:0.5]
taper_overlap = 0.8; //[0.2:2:0.1]
pin_slot_live_neutral_spacing_x = 22.2; //[11.1:44.4:0.1]
pin_slot_live_neutral_offset_y = -11.1; //[-22.2:0:0.1]
pin_slot_earth_offset_y = 11.1; //[0:22.2:0.1]
pin_slot_live_neutral_size_x = 7; //[3.5:14:0.1]
pin_slot_live_neutral_size_y = 4.5; //[2.25:9:0.1]
pin_slot_earth_size_x = 4.5; //[2.25:9:0.1]
pin_slot_earth_size_y = 8.5; //[4.25:17:0.1]
pin_slot_depth = 8; //[4:16:0.5]
rear_cavity_wall_thickness = 2; //[1:4:0.5]
rear_cavity_clearance_cube = 50; //[25:100:1]
rear_cavity_depth = 18; //[9:36:1]
mounting_screw_spacing_y = 60.3; //[30.15:120.6:0.1]
mounting_screw_clearance_diameter = 4; //[2:8:0.1]
countersink_enabled = 1; //[0:1:1]
counterbore_diameter_front = 8; //[4:16:0.1]
counterbore_depth_front = 2; //[1:5:0.1]
counterbore_diameter_back = 0; //[0:16:0.1]
counterbore_depth_back = 0; //[0:6:0.1]
screw_hole_depth_extra = 2; //[1:10:0.5]
eps_overlap = 1; //[0.5:2:0.1]

// Mains Socket - complete geometry
module mains_socket() {
  color("White") {
    // Faceplate with taper
    difference() {
      union() {
        hull() {
          translate([-faceplate_width/2 + corner_radius, faceplate_height/2 - corner_radius, 0])
            cylinder(r=corner_radius, h=faceplate_thickness_edge, center=true);
          translate([faceplate_width/2 - corner_radius, faceplate_height/2 - corner_radius, 0])
            cylinder(r=corner_radius, h=faceplate_thickness_edge, center=true);
          translate([-faceplate_width/2 + corner_radius, -faceplate_height/2 + corner_radius, 0])
            cylinder(r=corner_radius, h=faceplate_thickness_edge, center=true);
          translate([faceplate_width/2 - corner_radius, -faceplate_height/2 + corner_radius, 0])
            cylinder(r=corner_radius, h=faceplate_thickness_edge, center=true);
        }
        if (top_profile_taper_enabled) {
          hull() {
            translate([-(faceplate_width/2 - corner_radius) + top_profile_inset, (faceplate_height/2 - corner_radius) - top_profile_inset, (faceplate_thickness_center - faceplate_thickness_edge)/2 - taper_overlap])
              cylinder(r=max(corner_radius - top_profile_inset, corner_radius*0.3), h=faceplate_thickness_center, center=true);
            translate([(faceplate_width/2 - corner_radius) - top_profile_inset, (faceplate_height/2 - corner_radius) - top_profile_inset, (faceplate_thickness_center - faceplate_thickness_edge)/2 - taper_overlap])
              cylinder(r=max(corner_radius - top_profile_inset, corner_radius*0.3), h=faceplate_thickness_center, center=true);
            translate([-(faceplate_width/2 - corner_radius) + top_profile_inset, -(faceplate_height/2 - corner_radius) + top_profile_inset, (faceplate_thickness_center - faceplate_thickness_edge)/2 - taper_overlap])
              cylinder(r=max(corner_radius - top_profile_inset, corner_radius*0.3), h=faceplate_thickness_center, center=true);
            translate([(faceplate_width/2 - corner_radius) - top_profile_inset, -(faceplate_height/2 - corner_radius) + top_profile_inset, (faceplate_thickness_center - faceplate_thickness_edge)/2 - taper_overlap])
              cylinder(r=max(corner_radius - top_profile_inset, corner_radius*0.3), h=faceplate_thickness_center, center=true);
          }
        }
      }
      // Rear cavity
      translate([0, 0, -faceplate_thickness_edge/2 - rear_cavity_depth/2 + eps_overlap/2])
        cube([rear_cavity_clearance_cube, rear_cavity_clearance_cube, rear_cavity_depth + eps_overlap], center=true);
    }
  }
}

// Mains Socket Holes - complete geometry
module mains_socket_holes() {
  color("Black") {
    // Pin slots
    translate([-pin_slot_live_neutral_spacing_x/2, pin_slot_live_neutral_offset_y, faceplate_thickness_center/2 - pin_slot_depth/2 + eps_overlap/2])
      cube([pin_slot_live_neutral_size_x, pin_slot_live_neutral_size_y, pin_slot_depth + eps_overlap], center=true);
    translate([pin_slot_live_neutral_spacing_x/2, pin_slot_live_neutral_offset_y, faceplate_thickness_center/2 - pin_slot_depth/2 + eps_overlap/2])
      cube([pin_slot_live_neutral_size_x, pin_slot_live_neutral_size_y, pin_slot_depth + eps_overlap], center=true);
    translate([0, pin_slot_earth_offset_y, faceplate_thickness_center/2 - pin_slot_depth/2 + eps_overlap/2])
      cube([pin_slot_earth_size_x, pin_slot_earth_size_y, pin_slot_depth + eps_overlap], center=true);

    // Mounting screw holes
    translate([0, mounting_screw_spacing_y/2, 0])
      cylinder(r=mounting_screw_clearance_diameter/2, h=faceplate_thickness_center + screw_hole_depth_extra + eps_overlap, center=true);
    translate([0, -mounting_screw_spacing_y/2, 0])
      cylinder(r=mounting_screw_clearance_diameter/2, h=faceplate_thickness_center + screw_hole_depth_extra + eps_overlap, center=true);

    // Countersinks/counterbores
    if (countersink_enabled) {
      translate([0, mounting_screw_spacing_y/2, faceplate_thickness_center/2 - counterbore_depth_front/2 + eps_overlap/2])
        cylinder(r=counterbore_diameter_front/2, h=counterbore_depth_front + eps_overlap, center=true);
      translate([0, -mounting_screw_spacing_y/2, faceplate_thickness_center/2 - counterbore_depth_front/2 + eps_overlap/2])
        cylinder(r=counterbore_diameter_front/2, h=counterbore_depth_front + eps_overlap, center=true);
    }
  }
}

// Mains Socket Earth Position - complete geometry
module mains_socket_earth_position() {
  color("Green") {
    translate([-faceplate_width/2 + rear_cavity_wall_thickness + mounting_screw_clearance_diameter, -faceplate_height/2 + rear_cavity_wall_thickness + mounting_screw_clearance_diameter, 0])
      cube([pin_slot_earth_size_x, pin_slot_earth_size_y, pin_slot_depth + eps_overlap], center=true);
  }
}

// Assembly
module assembly() {
  mains_socket();
  mains_socket_holes();
  mains_socket_earth_position();
}

assembly();