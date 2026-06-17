// Parameters
body_L = 73.6; //[36.8:147.2:0.1]
body_W = 28.7; //[14.35:57.4:0.1]
body_T = 3.0; //[1.5:6.0:0.1]
bezel_margin = 2.0; //[1.0:4.0:0.1]
bezel_T = 1.0; //[0.5:2.0:0.1]
window_L = 69.6; //[34.8:139.2:0.1]
window_W = 24.7; //[12.35:49.4:0.1]
window_recess = 0.5; //[0.2:1.5:0.1]
mount_hole_d = 2.6; //[1.5:5.0:0.1]
mount_edge_margin = 3.0; //[1.5:6.0:0.1]
connector_L = 20.0; //[10.0:40.0:0.1]
connector_W = 6.0; //[3.0:12.0:0.1]
connector_T = 4.0; //[2.0:8.0:0.1]
connector_inset = 1.0; //[0.5:3.0:0.1]
pcb_detail_T = 0.6; //[0.3:1.5:0.1]
pcb_detail_margin = 1.5; //[0.5:4.0:0.1]
corner_fillet_r = 1.2; //[0.5:3.0:0.1]
minkowski_eps = 0.6; //[0.2:1.5:0.1]

// Base Shapes
module body_core_box() {
  cube([body_L - 2*corner_fillet_r, body_W - 2*corner_fillet_r, body_T - 2*corner_fillet_r], center=true);
}

module body_fillet_sphere() {
  sphere(r=corner_fillet_r, center=true);
}

module bezel_outer() {
  translate([0, 0, body_T/2 - bezel_T/2])
    cube([body_L, body_W, bezel_T], center=true);
}

module bezel_inner_cut() {
  translate([0, 0, body_T/2 - bezel_T/2])
    cube([body_L - 2*bezel_margin, body_W - 2*bezel_margin, bezel_T + 2*minkowski_eps], center=true);
}

module window_recess_cut() {
  translate([0, 0, body_T/2 - window_recess/2])
    cube([window_L, window_W, window_recess + 2*minkowski_eps], center=true);
}

module active_window_solid() {
  translate([0, 0, body_T/2 - window_recess/2])
    cube([window_L, window_W, window_recess], center=true);
}

module mount_hole_cyl() {
  cylinder(h=body_T + 2*minkowski_eps, r=mount_hole_d/2, center=true);
}

module connector_header() {
  translate([0, 0, -body_T/2 - connector_T/2 + connector_inset])
    cube([connector_L, connector_W, connector_T], center=true);
}

module pcb_detail_plate() {
  translate([0, 0, -body_T/2 + pcb_detail_T/2 - minkowski_eps])
    cube([body_L - 2*pcb_detail_margin, body_W - 2*pcb_detail_margin, pcb_detail_T], center=true);
}

// Operations
module corner_fillets_minkowski() {
  minkowski() {
    body_core_box();
    body_fillet_sphere();
  }
}

module front_bezel_frame() {
  difference() {
    bezel_outer();
    bezel_inner_cut();
  }
}

module front_bezel_with_window_recess() {
  difference() {
    front_bezel_frame();
    window_recess_cut();
  }
}

module mounting_holes() {
  union() {
    translate([body_L/2 - mount_edge_margin, body_W/2 - mount_edge_margin, 0]) mount_hole_cyl();
    translate([-(body_L/2 - mount_edge_margin), body_W/2 - mount_edge_margin, 0]) mount_hole_cyl();
    translate([body_L/2 - mount_edge_margin, -(body_W/2 - mount_edge_margin), 0]) mount_hole_cyl();
    translate([-(body_L/2 - mount_edge_margin), -(body_W/2 - mount_edge_margin), 0]) mount_hole_cyl();
  }
}

module display_module_body_with_holes() {
  difference() {
    corner_fillets_minkowski();
    mounting_holes();
  }
}

module pcb_detailing() {
  union() {
    pcb_detail_plate();
    connector_header();
  }
}

module complete_module() {
  union() {
    display_module_body_with_holes();
    front_bezel_with_window_recess();
    active_window_solid();
    pcb_detailing();
  }
}

// Final Output
complete_module();