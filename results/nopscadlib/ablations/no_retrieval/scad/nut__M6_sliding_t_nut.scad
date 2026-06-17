// Parameters
screw_d = 6.0; //[3.0:12.0:0.1]
hex_af = 8.0; //[4.0:16.0:0.1]
thickness = 6.6; //[3.3:13.2:0.1]
hole_clearance_d = 6.6; //[6.0:8.0:0.1]
t_body_L = 16.0; //[8.0:32.0:0.1]
t_body_W = 12.0; //[6.0:24.0:0.1]
t_neck_W = 8.0; //[4.0:16.0:0.1]
t_neck_H = 2.5; //[1.0:5.0:0.1]
chamfer = 0.5; //[0.2:1.5:0.1]
edge_fillet_r = 0.6; //[0.2:1.5:0.1]
serration_pitch = 1.2; //[0.6:2.4:0.1]
serration_depth = 0.4; //[0.1:1.0:0.05]
serration_count = 9; //[3:21:1]
thread_pilot_d = 5.0; //[4.0:6.0:0.1]
thread_pilot_enable = 0; //[0:1:1]
overlap = 0.8; //[0.5:2.0:0.1]

// Base Shapes
module t_slot_nut_body_main_block() {
  cube([t_body_L, t_body_W, thickness], center=true);
}

module t_slot_nut_body_neck_block() {
  translate([0, 0, thickness/2 + t_neck_H/2 - overlap])
    cube([t_body_L, t_neck_W, t_neck_H], center=true);
}

module central_screw_hole_clearance() {
  translate([0, 0, t_neck_H/2 - overlap/2])
    cylinder(h=thickness + t_neck_H + 2*overlap, r=hole_clearance_d/2, center=true);
}

module central_screw_hole_thread_pilot() {
  translate([0, 0, t_neck_H/2 - overlap/2])
    cylinder(h=thickness + t_neck_H + 2*overlap, r=thread_pilot_d/2, center=true);
}

module hex_across_flats_profile_prism() {
  translate([0, 0, 0])
    linear_extrude(height=thickness, center=true)
      polygon(points=[
        [hex_af/2, 0],
        [hex_af/4, hex_af*0.4330127019],
        [-hex_af/4, hex_af*0.4330127019],
        [-hex_af/2, 0],
        [-hex_af/4, -hex_af*0.4330127019],
        [hex_af/4, -hex_af*0.4330127019]
      ]);
}

module lead_in_chamfer_top_cone() {
  translate([0, 0, thickness/2 - chamfer])
    cylinder(h=chamfer*2, r1=hole_clearance_d/2 + chamfer, r2=0, center=true);
}

module lead_in_chamfer_bottom_cone() {
  translate([0, 0, -thickness/2 + chamfer])
    cylinder(h=chamfer*2, r1=hole_clearance_d/2 + chamfer, r2=0, center=true);
}

module serration_groove(pos) {
  translate([pos, 0, -thickness/2 + serration_depth/2])
    cube([serration_pitch*0.6, t_body_W + 2*overlap, serration_depth + 2*overlap], center=true);
}

module edge_fillet_kernel_sphere() {
  sphere(r=edge_fillet_r, center=true);
}

// Operations
module t_slot_nut_body_union() {
  union() {
    t_slot_nut_body_main_block();
    t_slot_nut_body_neck_block();
  }
}

module knurling_or_serrations_union() {
  union() {
    for (i = [0:serration_count-1]) {
      serration_groove(-(serration_count-1)*serration_pitch/2 + i*serration_pitch);
    }
  }
}

module lead_in_chamfers_union() {
  union() {
    lead_in_chamfer_top_cone();
    lead_in_chamfer_bottom_cone();
  }
}

module central_screw_hole_selected() {
  if (thread_pilot_enable == 0)
    central_screw_hole_clearance();
  else
    central_screw_hole_thread_pilot();
}

module t_slot_nut_body_with_hole_and_features_raw() {
  difference() {
    t_slot_nut_body_union();
    central_screw_hole_selected();
    lead_in_chamfers_union();
    knurling_or_serrations_union();
  }
}

module edge_fillets_minkowski() {
  minkowski() {
    t_slot_nut_body_with_hole_and_features_raw();
    edge_fillet_kernel_sphere();
  }
}

module final_t_slot_nut_model() {
  union() {
    edge_fillets_minkowski();
    hex_across_flats_profile_prism();
  }
}

// Final Output
final_t_slot_nut_model();