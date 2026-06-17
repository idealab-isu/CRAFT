// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 47.0; //[23.5:94.0:0.1]
body_width = 42.3; //[21.15:84.6:0.1]
body_height = 42.3; //[21.15:84.6:0.1]
corner_radius = 2.0; //[1.0:4.0:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.1]
front_boss_diameter = 22.0; //[11.0:44.0:0.1]
front_boss_height = 2.0; //[1.0:6.0:0.1]
mount_hole_spacing = 31.0; //[15.5:62.0:0.1]
mount_hole_diameter = 3.2; //[1.6:6.4:0.1]
rear_cap_thickness = 2.5; //[1.0:6.0:0.1]
eps_overlap = 1.0; //[0.5:2.0:0.1]
mount_hole_depth = 10.0; //[5.0:25.0:0.1]
ttrack_length = 60.0; //[30.0:120.0:0.5]
ttrack_pitch = 20.0; //[10.0:40.0:0.5]
ttrack_height = 12.0; //[6.0:24.0:0.5]
ttrack_slot_height = 6.0; //[3.0:12.0:0.5]
ttrack_top_thickness = 2.0; //[1.0:4.0:0.1]
rail_length = 80.0; //[40.0:160.0:0.5]
rail_pitch = 25.0; //[10.0:50.0:0.5]
rail_hole_count = 4.0; //[2.0:10.0:1.0]
helper_hole_diameter = 3.0; //[1.5:6.0:0.1]
helper_marker_height = 2.0; //[1.0:6.0:0.1]
screw_shank_diameter = 3.0; //[1.5:6.0:0.1]
screw_length = 12.0; //[6.0:30.0:0.5]
screw_head_diameter = 6.0; //[3.0:12.0:0.1]
screw_head_height = 2.5; //[1.0:6.0:0.1]
washer_outer_diameter = 7.0; //[3.5:14.0:0.1]
washer_thickness = 1.0; //[0.5:3.0:0.1]
d_plug_width = 18.0; //[9.0:36.0:0.5]
d_plug_height = 10.0; //[5.0:20.0:0.5]
d_plug_depth = 8.0; //[4.0:16.0:0.5]
internal_anchor_size = 6.0; //[3.0:12.0:0.5]

// --- Top pin/connector parameters (peg/pin near shaft side) ---
top_pin_diameter = 3.0;
top_pin_height   = 8.0;
top_pin_x_offset = 8.0;   // right side of top face (+X)
top_pin_y_offset = 0.0;

// --- Small screw/bolt-like fastener near shaft side (top) ---
top_screw_shank_diameter = 2.5;
top_screw_length         = 8.0;
top_screw_head_diameter  = 5.0;
top_screw_head_height    = 2.0;
top_screw_x_offset       = 14.0;  // near shaft side (+X)
top_screw_y_offset       = 10.0;  // slightly toward +Y

// ---------- Derived Z reference planes (reused to guarantee attachment) ----------
front_face_z      = 0;
front_face_top_z  = front_face_z + face_thickness/2;
front_face_bot_z  = front_face_z - face_thickness/2;

// Body is placed behind the front face; its front is slightly overlapped into the face
body_center_z     = -(face_thickness/2 + body_length/2 - eps_overlap);
body_front_z      = body_center_z + body_length/2;  // should be -face_thickness/2 + eps_overlap
body_back_z       = body_center_z - body_length/2;

// Modules
module motor_body() {
  color("Black")
    translate([0, 0, body_center_z])
      cube([body_width, body_height, body_length], center=true);
}

module front_face() {
  color("Black")
    translate([0, 0, front_face_z])
      cube([face_width, face_width, face_thickness], center=true);
}

module front_boss_or_register() {
  color("Silver")
    translate([0, 0, front_face_top_z + front_boss_height/2 - eps_overlap])
      cylinder(r=front_boss_diameter/2, h=front_boss_height, center=true);
}

module output_shaft() {
  color("Silver")
    translate([0, 0, front_face_top_z + shaft_length/2 - eps_overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
}

module rear_cap_face() {
  color("Black")
    // Rear cap sits behind the body and overlaps slightly into it
    translate([0, 0, body_back_z - rear_cap_thickness/2 + eps_overlap])
      cube([body_width, body_height, rear_cap_thickness], center=true);
}

module mounting_holes_pattern() {
  color("DimGray")
    union() {
      translate([ mount_hole_spacing/2,  mount_hole_spacing/2, -(mount_hole_depth/2 - eps_overlap)])
        cylinder(r=mount_hole_diameter/2, h=mount_hole_depth + face_thickness + eps_overlap*2, center=true);
      translate([-mount_hole_spacing/2,  mount_hole_spacing/2, -(mount_hole_depth/2 - eps_overlap)])
        cylinder(r=mount_hole_diameter/2, h=mount_hole_depth + face_thickness + eps_overlap*2, center=true);
      translate([-mount_hole_spacing/2, -mount_hole_spacing/2, -(mount_hole_depth/2 - eps_overlap)])
        cylinder(r=mount_hole_diameter/2, h=mount_hole_depth + face_thickness + eps_overlap*2, center=true);
      translate([ mount_hole_spacing/2, -mount_hole_spacing/2, -(mount_hole_depth/2 - eps_overlap)])
        cylinder(r=mount_hole_diameter/2, h=mount_hole_depth + face_thickness + eps_overlap*2, center=true);
    }
}

// --- FIX: Peg/pin is now attached to the TOP of the motor body with overlap ---
module top_pin_connector() {
  // Attach to top of body (+Z of body): z = body_front_z + top_pin_height/2 - eps_overlap
  // (body_front_z is the body's front plane; using it ensures consistent attachment)
  color("Silver")
    translate([top_pin_x_offset, top_pin_y_offset, body_front_z + top_pin_height/2 - eps_overlap])
      cylinder(r=top_pin_diameter/2, h=top_pin_height, center=true);
}

// --- FIX: Small screw/bolt-like fastener is now created and attached to the TOP of the motor body ---
module top_screw_fastener() {
  // Shank overlaps into the body by eps_overlap to guarantee union connectivity
  shank_z = body_front_z + top_screw_length/2 - eps_overlap;
  head_z  = body_front_z + top_screw_length - eps_overlap + top_screw_head_height/2;

  color("Silver")
    union() {
      translate([top_screw_x_offset, top_screw_y_offset, shank_z])
        cylinder(r=top_screw_shank_diameter/2, h=top_screw_length, center=true);
      translate([top_screw_x_offset, top_screw_y_offset, head_z])
        cylinder(r=top_screw_head_diameter/2, h=top_screw_head_height, center=true);
    }
}

module motor_with_mount_holes() {
  difference() {
    union() {
      motor_body();
      front_face();
      front_boss_or_register();
      output_shaft();
      rear_cap_face();

      // FIXED: both previously floating parts are now included and physically intersect the body
      top_pin_connector();
      top_screw_fastener();
    }
    mounting_holes_pattern();
  }
}

module ttrack_hole_positions() {
  color("Blue")
    union() {
      translate([body_width/2 - eps_overlap,
                 ttrack_length/2 - ((ttrack_length - floor(ttrack_length/ttrack_pitch)*ttrack_pitch)/2 + ttrack_pitch),
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
      translate([body_width/2 - eps_overlap,
                 ttrack_length/2 - ((ttrack_length - floor(ttrack_length/ttrack_pitch)*ttrack_pitch)/2 + ttrack_pitch*2),
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
      translate([body_width/2 - eps_overlap,
                 ttrack_length/2 - ((ttrack_length - floor(ttrack_length/ttrack_pitch)*ttrack_pitch)/2 + ttrack_pitch*3),
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
    }
}

module rail_hole_positions() {
  color("Green")
    union() {
      translate([rail_length/2 - (rail_pitch*(rail_hole_count-1))/2,
                 body_height/2 - eps_overlap,
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
      translate([rail_length/2 - (rail_pitch*(rail_hole_count-1))/2 + rail_pitch,
                 body_height/2 - eps_overlap,
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
      translate([rail_length/2 - (rail_pitch*(rail_hole_count-1))/2 + rail_pitch*2,
                 body_height/2 - eps_overlap,
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
      translate([rail_length/2 - (rail_pitch*(rail_hole_count-1))/2 + rail_pitch*3,
                 body_height/2 - eps_overlap,
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
    }
}

module ttrack_insert_hole_positions() {
  color("Red")
    union() {
      translate([-(body_width/2 - eps_overlap),
                 ttrack_length/2 - ((ttrack_length - floor(ttrack_length/ttrack_pitch)*ttrack_pitch)/2 + ttrack_pitch),
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
      translate([-(body_width/2 - eps_overlap),
                 ttrack_length/2 - ((ttrack_length - floor(ttrack_length/ttrack_pitch)*ttrack_pitch)/2 + ttrack_pitch*2),
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
      translate([-(body_width/2 - eps_overlap),
                 ttrack_length/2 - ((ttrack_length - floor(ttrack_length/ttrack_pitch)*ttrack_pitch)/2 + ttrack_pitch*3),
                 -(face_thickness/2 + body_length/2)])
        cylinder(r=helper_hole_diameter/2, h=helper_marker_height, center=true);
    }
}

module screw_and_washer() {
  // Keep as helper marker geometry; ensure it intersects the front face slightly
  color("Silver")
    union() {
      translate([mount_hole_spacing/2, mount_hole_spacing/2, front_face_top_z + screw_length/2 - eps_overlap])
        cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);
      translate([mount_hole_spacing/2, mount_hole_spacing/2, front_face_top_z + screw_length - eps_overlap + screw_head_height/2])
        cylinder(r=screw_head_diameter/2, h=screw_head_height, center=true);
      translate([mount_hole_spacing/2, mount_hole_spacing/2, front_face_top_z + screw_length - eps_overlap + washer_thickness/2])
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
    }
}

module d_plug_D() {
  // Keep as helper marker geometry; positioned behind rear cap with slight overlap into it
  color("Yellow")
    translate([0, 0, (body_back_z - rear_cap_thickness + eps_overlap) - d_plug_depth/2 + eps_overlap])
      cube([d_plug_width, d_plug_height, d_plug_depth], center=true);
}

module internal_anchor() {
  color("Gray")
    translate([0, 0, -(face_thickness/2 + body_length/2)])
      cube([internal_anchor_size, internal_anchor_size, internal_anchor_size], center=true);
}

module helpers_union() {
  union() {
    internal_anchor();
    ttrack_hole_positions();
    rail_hole_positions();
    ttrack_insert_hole_positions();
    screw_and_washer();
    d_plug_D();
  }
}

module assembly() {
  union() {
    motor_with_mount_holes();
    helpers_union();
  }
}

assembly();