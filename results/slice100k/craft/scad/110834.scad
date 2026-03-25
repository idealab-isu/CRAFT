// Parameters
bbox_x = 21.25; //[10.63:42.5:0.01]
bbox_y = 21.13; //[10.57:42.26:0.01]
H_total = 10.0; //[5.0:20.0:0.01]
flange_Dx = 21.25; //[10.63:42.5:0.01]
flange_Dy = 21.13; //[10.57:42.26:0.01]
flange_t = 2.0; //[1.0:4.0:0.01]
body_D = 16.0; //[8.0:32.0:0.01]
body_h = 8.0; //[4.0:16.0:0.01]
bore_D = 8.0; //[4.0:16.0:0.01]
bore_offset_x = 2.5; //[0.0:5.0:0.01]
bore_offset_y = 0.0; //[-5.0:5.0:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
step_relief_h = 0.6; //[0.2:1.5:0.01]
step_relief_radial = 0.4; //[0.1:1.0:0.01]
chamfer_h = 0.6; //[0.2:1.5:0.01]
chamfer_radial = 0.6; //[0.2:1.5:0.01]
fillet_r = 0.5; //[0.2:1.5:0.01]
mark_flat_depth = 0.8; //[0.3:2.0:0.01]
mark_flat_width = 6.0; //[3.0:12.0:0.01]

// Base Shapes
module outer_body_cylinder() {
  translate([0, 0, -H_total/2 + body_h/2])
    cylinder(r=body_D/2, h=body_h, center=true);
}

module flange_lip_base_cyl() {
  translate([0, 0, H_total/2 - flange_t/2])
    cylinder(r=flange_Dx/2, h=flange_t, center=true);
}

module eccentric_through_bore() {
  translate([bore_offset_x, bore_offset_y, 0])
    cylinder(r=bore_D/2, h=H_total + 2*overlap, center=true);
}

module body_to_flange_step_interface_ring() {
  translate([0, 0, H_total/2 - flange_t - step_relief_h/2])
    cylinder(r=body_D/2 + step_relief_radial, h=step_relief_h + 2*overlap, center=true);
}

module body_to_flange_step_interface_inner_clear() {
  translate([0, 0, H_total/2 - flange_t - step_relief_h/2])
    cylinder(r=body_D/2 - step_relief_radial, h=step_relief_h + 4*overlap, center=true);
}

module edge_chamfer_top_outer_cone() {
  translate([0, 0, H_total/2 - chamfer_h/2])
    cylinder(r1=flange_Dx/2 + chamfer_radial, r2=0, h=chamfer_h + 2*overlap, center=true);
}

module edge_chamfer_bottom_outer_cone() {
  translate([0, 0, -H_total/2 + chamfer_h/2])
    cylinder(r1=body_D/2 + chamfer_radial, r2=0, h=chamfer_h + 2*overlap, center=true);
}

module marking_notch_or_flat_box() {
  translate([flange_Dx/2 - mark_flat_depth/2, 0, H_total/2 - flange_t/2])
    cube([mark_flat_depth + 2*overlap, mark_flat_width, flange_t + 2*overlap], center=true);
}

module edge_fillets_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module flange_lip_scale_to_ellipse() {
  scale([1, flange_Dy/flange_Dx, 1])
    flange_lip_base_cyl();
}

module outer_solid_union() {
  union() {
    outer_body_cylinder();
    flange_lip_scale_to_ellipse();
  }
}

module step_interface_ring_diff() {
  difference() {
    body_to_flange_step_interface_ring();
    body_to_flange_step_interface_inner_clear();
  }
}

module outer_with_step_interface() {
  difference() {
    outer_solid_union();
    step_interface_ring_diff();
  }
}

module outer_with_chamfers() {
  difference() {
    outer_with_step_interface();
    edge_chamfer_top_outer_cone();
    edge_chamfer_bottom_outer_cone();
  }
}

module outer_with_mark_flat() {
  difference() {
    outer_with_chamfers();
    marking_notch_or_flat_box();
  }
}

module outer_with_bore() {
  difference() {
    outer_with_mark_flat();
    eccentric_through_bore();
  }
}

// Final Output
minkowski() {
  outer_with_bore();
  edge_fillets_sphere();
}