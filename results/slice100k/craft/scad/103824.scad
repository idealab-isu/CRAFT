// Parameters
bbox_x = 22.15; //[11.08:44.3:0.01]
bbox_y = 24.3; //[12.15:48.6:0.01]
bbox_z = 79; //[39.5:158:0.1]
wall_t = 2; //[1:4:0.1]
channel_w = 16; //[8:20.15:0.1]
channel_d = 14; //[7:22.3:0.1]
back_round_r = 11.075; //[5.54:22.15:0.01]
front_open_w = 14; //[6:20.15:0.1]
pin_hole_d = 4; //[2:8:0.1]
pin_feature_len = 6; //[3:12:0.1]
pin_z_upper = 58; //[39.5:75:0.1]
pin_z_lower = 21; //[4:39.5:0.1]
pin_y_offset_from_inner_face = 0; //[-2:2:0.1]
tab_len = 2; //[1:6:0.1]
tab_thk = 1.5; //[0.8:3:0.1]
tab_z_pos = 39.5; //[10:69:0.1]
tab_z_h = 10; //[4:20:0.1]
overlap = 1; //[0.5:2:0.1]
pin_clear = 0.2; //[0:0.6:0.05]
rib_thk = 1.2; //[0.8:2.5:0.1]
rib_z_h = 8; //[4:16:0.1]
edge_round_r = 0.8; //[0.3:2:0.1]

// Base Shapes
module u_channel_body_outer_box() {
  cube([bbox_x, bbox_y, bbox_z], center=true);
}

module rounded_outer_back_cyl() {
  rotate([90, 0, 0])
    cylinder(r=back_round_r, h=bbox_z, center=true);
}

module open_front_gap_box() {
  translate([0, (bbox_y - channel_d)/2 + overlap, 0])
    cube([front_open_w, bbox_y + overlap*2, bbox_z + overlap*2], center=true);
}

module inner_channel_void_box() {
  translate([0, (bbox_y - channel_d)/2, wall_t/2])
    cube([channel_w, channel_d, bbox_z - wall_t], center=true);
}

module side_wall_pin_feature(pos_x, pos_z) {
  translate([pos_x, -bbox_y/2 + wall_t + pin_hole_d/2 + pin_y_offset_from_inner_face, pos_z])
    rotate([0, 90, 0])
      cylinder(r=(pin_hole_d + pin_clear)/2, h=pin_feature_len, center=true);
}

module front_edge_tab(pos_x) {
  translate([pos_x, bbox_y/2 - tab_thk/2, tab_z_pos - bbox_z/2])
    cube([tab_len, tab_thk, tab_z_h], center=true);
}

module boss_reinforcement_rib(pos_x, pos_z) {
  translate([pos_x, -bbox_y/2 + wall_t + rib_thk/2, pos_z])
    cube([wall_t + overlap*2, rib_thk, rib_z_h], center=true);
}

// Operations
module u_channel_body_outer_union() {
  union() {
    u_channel_body_outer_box();
    rounded_outer_back_cyl();
  }
}

module u_channel_body() {
  intersection() {
    u_channel_body_outer_union();
    u_channel_body_outer_box();
  }
}

module u_channel_body_hollowed() {
  difference() {
    u_channel_body();
    inner_channel_void_box();
    open_front_gap_box();
  }
}

module tabs_union_raw() {
  union() {
    front_edge_tab(-front_open_w/2 + tab_len/2 - overlap);
    front_edge_tab(front_open_w/2 - tab_len/2 + overlap);
  }
}

module edge_rounding_on_tabs() {
  minkowski() {
    tabs_union_raw();
    sphere(r=edge_round_r);
  }
}

module boss_reinforcement_ribs() {
  union() {
    boss_reinforcement_rib(-channel_w/2 - wall_t/2, pin_z_upper - bbox_z/2);
    boss_reinforcement_rib(channel_w/2 + wall_t/2, pin_z_upper - bbox_z/2);
    boss_reinforcement_rib(-channel_w/2 - wall_t/2, pin_z_lower - bbox_z/2);
    boss_reinforcement_rib(channel_w/2 + wall_t/2, pin_z_lower - bbox_z/2);
  }
}

module clip_with_tabs_and_ribs() {
  union() {
    u_channel_body_hollowed();
    edge_rounding_on_tabs();
    boss_reinforcement_ribs();
  }
}

module pin_holes_all() {
  union() {
    side_wall_pin_feature(-channel_w/2 - wall_t/2, pin_z_upper - bbox_z/2);
    side_wall_pin_feature(channel_w/2 + wall_t/2, pin_z_upper - bbox_z/2);
    side_wall_pin_feature(-channel_w/2 - wall_t/2, pin_z_lower - bbox_z/2);
    side_wall_pin_feature(channel_w/2 + wall_t/2, pin_z_lower - bbox_z/2);
  }
}

module clip_with_pin_holes() {
  difference() {
    clip_with_tabs_and_ribs();
    pin_holes_all();
  }
}

module draft_angles() {
  union() {
    clip_with_pin_holes();
  }
}

// Final Output
draft_angles();