// Parameters
pipe_OD = 160; //[80:320:1]
socket_ID = 160.5; //[80.25:321:0.1]
wall_t = 4; //[2:8:0.1]
cap_length = 70; //[35:140:1]
end_thickness = 5; //[2.5:10:0.1]
insertion_depth = 45; //[20:90:1]
shoulder_t = 3; //[1.5:6:0.1]
shoulder_radial = 2; //[1:6:0.1]
chamfer_len = 2; //[1:6:0.1]
chamfer_ang = 30; //[15:60:1]
rib_count = 12; //[6:24:1]
rib_height = 2; //[1:6:0.1]
rib_width = 8; //[4:16:0.1]
rib_length = 40; //[20:80:1]
rib_end_margin = 10; //[5:25:1]
o_ring_cs = 4; //[2:8:0.1]
o_ring_groove_depth = 2.2; //[1:5:0.1]
o_ring_groove_width = 4.5; //[2:10:0.1]
o_ring_pos_from_open = 18; //[8:40:1]
outer_edge_fillet_r = 1.5; //[0.5:4:0.1]
overlap = 1; //[0.5:2:0.1]
eps = 0.2; //[0.05:0.5:0.05]

// Base Shapes
module cap_body_outer() {
  cylinder(h = cap_length, r = (socket_ID/2 + wall_t), center = true);
}

module socket_interface_void() {
  translate([0, 0, cap_length/2 - (cap_length - end_thickness + eps)/2])
    cylinder(h = (cap_length - end_thickness + eps), r = (socket_ID/2), center = true);
}

module closed_end_solid() {
  translate([0, 0, -cap_length/2 + end_thickness/2])
    cylinder(h = end_thickness, r = (socket_ID/2 + wall_t), center = true);
}

module internal_stop_shoulder_ring() {
  translate([0, 0, cap_length/2 - insertion_depth - shoulder_t/2])
    cylinder(h = shoulder_t, r = (socket_ID/2), center = true);
}

module internal_stop_shoulder_bore_cut() {
  translate([0, 0, cap_length/2 - insertion_depth - shoulder_t/2])
    cylinder(h = (shoulder_t + eps), r = (socket_ID/2 - shoulder_radial), center = true);
}

module lead_in_chamfer_cut() {
  translate([0, 0, cap_length/2 - (chamfer_len + eps)/2])
    cylinder(h = (chamfer_len + eps), r1 = (socket_ID/2 + chamfer_len), r2 = (socket_ID/2), center = true);
}

module o_ring_groove_cut() {
  translate([0, 0, cap_length/2 - o_ring_pos_from_open])
    cylinder(h = (o_ring_groove_width + eps), r = (socket_ID/2 + o_ring_groove_depth), center = true);
}

module rib_blank() {
  translate([(socket_ID/2 + wall_t + rib_height/2 - overlap), 0, cap_length/2 - rib_length/2 - rib_end_margin])
    cube([rib_height, rib_width, rib_length], center = true);
}

module rib(index) {
  rotate([0, 0, index * 360 / rib_count])
    rib_blank();
}

module outer_edge_fillet_sphere() {
  sphere(r = outer_edge_fillet_r, center = true);
}

// Operations
module cap_body_shell_pre() {
  difference() {
    cap_body_outer();
    socket_interface_void();
  }
}

module cap_body_shell() {
  union() {
    cap_body_shell_pre();
    closed_end_solid();
  }
}

module internal_stop_shoulder() {
  difference() {
    internal_stop_shoulder_ring();
    internal_stop_shoulder_bore_cut();
  }
}

module cap_with_shoulder() {
  union() {
    cap_body_shell();
    internal_stop_shoulder();
  }
}

module cap_with_chamfer() {
  difference() {
    cap_with_shoulder();
    lead_in_chamfer_cut();
  }
}

module cap_with_o_ring_groove() {
  difference() {
    cap_with_chamfer();
    o_ring_groove_cut();
  }
}

module external_ribs() {
  union() {
    for (i = [0:rib_count-1]) {
      rib(i);
    }
  }
}

module cap_with_ribs() {
  union() {
    cap_with_o_ring_groove();
    external_ribs();
  }
}

module outer_edge_fillet() {
  minkowski() {
    cap_with_ribs();
    outer_edge_fillet_sphere();
  }
}

module complete_model() {
  outer_edge_fillet();
}

// Final Output
complete_model();