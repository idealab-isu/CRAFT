// Parameters
nominal_d = 50; //[25:100:1]
socket_id = 50.5; //[45:60:0.1]
wall_t = 2.5; //[1.2:5:0.1]
socket_len = 35; //[20:70:1]
end_wall_t = 3; //[1.5:8:0.1]
stop_shoulder_h = 2; //[1:6:0.1]
lead_in_chamfer = 1.5; //[0.5:4:0.1]
overlap = 1; //[0.5:2:0.1]
rib_count = 12; //[6:24:1]
rib_height = 0.8; //[0.3:2:0.1]
rib_width = 3; //[1.5:6:0.1]
rib_band_len = 18; //[8:30:1]
label_band_h = 0.4; //[0.2:1.2:0.1]
label_band_len = 10; //[5:20:1]
fillet_r = 0.6; //[0.2:1.5:0.1]

// Base Shapes
module cap_socket_body_outer() {
  cylinder(h = (socket_len + end_wall_t), r = (socket_id/2 + wall_t), center = true);
}

module cap_socket_body_inner_void() {
  translate([0, 0, -end_wall_t/2 - overlap/2])
    cylinder(h = (socket_len + overlap), r = (socket_id/2), center = true);
}

module lead_in_chamfer_outer() {
  translate([0, 0, - (socket_len + end_wall_t)/2 + lead_in_chamfer/2])
    cylinder(h = lead_in_chamfer, r1 = (socket_id/2 + wall_t), r2 = (socket_id/2 + wall_t + lead_in_chamfer), center = true);
}

module lead_in_chamfer_inner() {
  translate([0, 0, - (socket_len + end_wall_t)/2 + lead_in_chamfer/2])
    cylinder(h = lead_in_chamfer, r1 = (socket_id/2), r2 = (socket_id/2 + lead_in_chamfer), center = true);
}

module internal_stop_shoulder_ring() {
  translate([0, 0, (socket_len + end_wall_t)/2 - end_wall_t - stop_shoulder_h/2 + overlap])
    cylinder(h = stop_shoulder_h, r = (socket_id/2 + wall_t), center = true);
}

module internal_stop_shoulder_void() {
  translate([0, 0, (socket_len + end_wall_t)/2 - end_wall_t - stop_shoulder_h/2 + overlap])
    cylinder(h = (stop_shoulder_h + 2*overlap), r = (socket_id/2 - wall_t), center = true);
}

module outer_label_band_cyl() {
  translate([0, 0, (socket_len + end_wall_t)/2 - end_wall_t - label_band_len/2])
    cylinder(h = label_band_len, r = (socket_id/2 + wall_t + label_band_h), center = true);
}

module outer_grip_rib_proto() {
  translate([(socket_id/2 + wall_t + rib_height/2 - overlap), 0, - (socket_len + end_wall_t)/2 + lead_in_chamfer + rib_band_len/2])
    cube([rib_height, rib_width, rib_band_len], center = true);
}

module edge_fillet_sphere() {
  sphere(r = fillet_r, center = true);
}

// Operations
module cap_socket_body_shell() {
  difference() {
    cap_socket_body_outer();
    cap_socket_body_inner_void();
  }
}

module lead_in_chamfer_solid() {
  difference() {
    lead_in_chamfer_outer();
    lead_in_chamfer_inner();
  }
}

module cap_socket_with_chamfer() {
  union() {
    cap_socket_body_shell();
    lead_in_chamfer_solid();
  }
}

module internal_stop_shoulder() {
  difference() {
    internal_stop_shoulder_ring();
    internal_stop_shoulder_void();
  }
}

module cap_with_stop() {
  union() {
    cap_socket_with_chamfer();
    internal_stop_shoulder();
  }
}

module outer_label_band() {
  union() {
    cap_with_stop();
    outer_label_band_cyl();
  }
}

module outer_grip_ribs() {
  union() {
    for (i = [0:rib_count-1]) {
      rotate([0, 0, i*360/rib_count])
        outer_grip_rib_proto();
    }
  }
}

module cap_with_ribs_and_band() {
  union() {
    outer_label_band();
    outer_grip_ribs();
  }
}

// Final Output
minkowski() {
  cap_with_ribs_and_band();
  edge_fillet_sphere();
}