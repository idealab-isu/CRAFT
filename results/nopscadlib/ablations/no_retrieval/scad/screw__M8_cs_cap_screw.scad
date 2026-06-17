// Parameters
thread_major_d = 8; //[4:16:0.1]
length_under_head = 10; //[5:20:0.5]
head_d = 16; //[8:32:0.5]
head_h = 8; //[4:16:0.5]
socket_hex_af = 6; //[3:12:0.1]
socket_depth = 4; //[2:8:0.1]
thread_pitch = 1.25; //[0.5:3:0.05]
overlap = 1; //[0.5:2:0.1]
thread_minor_d = 6.6; //[3.3:13.2:0.1]
thread_relief_d = 7.2; //[3.6:14.4:0.1]
thread_relief_w = 1.2; //[0.6:2.4:0.1]
thread_runout_len = 1.5; //[0.8:3:0.1]
lead_in_len = 1.2; //[0.6:2.4:0.1]
head_top_chamfer_h = 0.8; //[0.4:1.6:0.1]
head_top_chamfer_d2 = 14.4; //[7.2:28.8:0.1]
underhead_fillet_r = 0.8; //[0.4:1.6:0.1]
thread_ring_h = 0.6; //[0.3:1.2:0.05]
thread_ring_count = 6; //[3:16:1]
thread_ring_radial = 0.35; //[0.15:0.8:0.05]

// Base Shapes
module socket_head() {
  translate([0, 0, length_under_head + head_h/2 - overlap])
    cylinder(h = head_h, r = head_d/2, center = true);
}

module threaded_shank_core() {
  translate([0, 0, length_under_head/2])
    cylinder(h = length_under_head, r = thread_minor_d/2, center = true);
}

module thread_ring(pos) {
  translate([0, 0, pos])
    cylinder(h = thread_ring_h, r = thread_minor_d/2 + thread_ring_radial, center = true);
}

module thread_rings_union() {
  union() {
    for (i = [0:thread_ring_count-1]) {
      thread_ring(thread_runout_len + (i+0.5)*(length_under_head - thread_runout_len - lead_in_len)/thread_ring_count);
    }
  }
}

module thread_runout() {
  translate([0, 0, length_under_head - thread_runout_len/2])
    cylinder(h = thread_runout_len, r = thread_major_d/2, center = true);
}

module lead_in_chamfer() {
  translate([0, 0, lead_in_len/2])
    cylinder(h = lead_in_len, r1 = thread_major_d/2, r2 = thread_minor_d/2, center = true);
}

module head_top_chamfer() {
  translate([0, 0, length_under_head + head_h - head_top_chamfer_h/2 - overlap])
    cylinder(h = head_top_chamfer_h, r1 = head_d/2, r2 = head_top_chamfer_d2/2, center = true);
}

module underhead_bearing_face() {
  translate([0, 0, length_under_head - overlap/2])
    cylinder(h = overlap, r = head_d/2, center = true);
}

module thread_relief_outer() {
  translate([0, 0, length_under_head - thread_runout_len - thread_relief_w/2])
    cylinder(h = thread_relief_w, r = thread_major_d/2, center = true);
}

module thread_relief_inner() {
  translate([0, 0, length_under_head - thread_runout_len - thread_relief_w/2])
    cylinder(h = thread_relief_w + overlap, r = thread_relief_d/2, center = true);
}

module underhead_fillet_torus() {
  translate([0, 0, length_under_head - underhead_fillet_r])
    rotate_extrude() translate([thread_major_d/2 + underhead_fillet_r, 0])
      circle(r = underhead_fillet_r);
}

module hex_socket_recess() {
  translate([0, 0, length_under_head + head_h - (socket_depth + overlap)/2 - overlap])
    linear_extrude(height = socket_depth + overlap, center = true)
      polygon(points = [
        [socket_hex_af/2, 0],
        [socket_hex_af/4, socket_hex_af*0.4330127019],
        [-socket_hex_af/4, socket_hex_af*0.4330127019],
        [-socket_hex_af/2, 0],
        [-socket_hex_af/4, -socket_hex_af*0.4330127019],
        [socket_hex_af/4, -socket_hex_af*0.4330127019]
      ]);
}

// Operations
module thread_relief_groove() {
  difference() {
    thread_relief_outer();
    thread_relief_inner();
  }
}

module threaded_shank() {
  union() {
    threaded_shank_core();
    thread_rings_union();
    thread_runout();
    lead_in_chamfer();
  }
}

module screw_body_pre_socket() {
  union() {
    socket_head();
    head_top_chamfer();
    underhead_bearing_face();
    threaded_shank();
    underhead_fillet_torus();
  }
}

module screw_body_with_relief() {
  difference() {
    screw_body_pre_socket();
    thread_relief_groove();
  }
}

// Final Model
difference() {
  screw_body_with_relief();
  hex_socket_recess();
}