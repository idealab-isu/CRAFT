// Parameters
bbox_X = 11.68; //[5.84:23.36:0.01]
bbox_Y = 6.6; //[3.3:13.2:0.01]
bbox_Z = 6.99; //[3.495:13.98:0.01]
cyl_D = 6.6; //[3.3:13.2:0.01]
cyl_H = 6.99; //[3.495:13.98:0.01]
lug_total_span_X = 11.68; //[5.84:23.36:0.01]
lug_radial_len = 2.54; //[1.27:5.08:0.01]
lug_thk_Y = 2.0; //[1.0:4.0:0.01]
lug_H = 3.5; //[1.75:7.0:0.01]
lug_z_center = 0.0; //[-3.495:3.495:0.01]
lug_y_center = 0.0; //[-1.0:1.0:0.01]
fillet_r = 0.3; //[0.15:0.6:0.01]
overlap = 0.8; //[0.2:2.0:0.01]
chamfer_depth = 0.25; //[0.1:0.6:0.01]
mark_r = 0.35; //[0.15:0.8:0.01]
mark_depth = 0.2; //[0.05:0.5:0.01]

// Base Shapes
module cyl_body() {
  translate([0, 0, 0])
    cylinder(h=cyl_H, r=cyl_D/2, center=true);
}

module lug_pos() {
  translate([cyl_D/2 + (lug_radial_len + overlap)/2 - overlap, lug_y_center, lug_z_center])
    cube([lug_radial_len + overlap, lug_thk_Y, lug_H], center=true);
}

module lug_neg() {
  translate([-(cyl_D/2 + (lug_radial_len + overlap)/2 - overlap), lug_y_center, lug_z_center])
    cube([lug_radial_len + overlap, lug_thk_Y, lug_H], center=true);
}

module lug_fillet_sphere_pos_in() {
  translate([cyl_D/2 - overlap, lug_y_center + lug_thk_Y/2 - fillet_r, lug_z_center + lug_H/2 - fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_pos_out() {
  translate([cyl_D/2 + lug_radial_len - overlap, lug_y_center + lug_thk_Y/2 - fillet_r, lug_z_center + lug_H/2 - fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_pos_in2() {
  translate([cyl_D/2 - overlap, lug_y_center - lug_thk_Y/2 + fillet_r, lug_z_center + lug_H/2 - fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_pos_out2() {
  translate([cyl_D/2 + lug_radial_len - overlap, lug_y_center - lug_thk_Y/2 + fillet_r, lug_z_center + lug_H/2 - fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_pos_in3() {
  translate([cyl_D/2 - overlap, lug_y_center + lug_thk_Y/2 - fillet_r, lug_z_center - lug_H/2 + fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_pos_out3() {
  translate([cyl_D/2 + lug_radial_len - overlap, lug_y_center + lug_thk_Y/2 - fillet_r, lug_z_center - lug_H/2 + fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_pos_in4() {
  translate([cyl_D/2 - overlap, lug_y_center - lug_thk_Y/2 + fillet_r, lug_z_center - lug_H/2 + fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_pos_out4() {
  translate([cyl_D/2 + lug_radial_len - overlap, lug_y_center - lug_thk_Y/2 + fillet_r, lug_z_center - lug_H/2 + fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_neg_in() {
  translate([-(cyl_D/2 - overlap), lug_y_center + lug_thk_Y/2 - fillet_r, lug_z_center + lug_H/2 - fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_neg_out() {
  translate([-(cyl_D/2 + lug_radial_len - overlap), lug_y_center + lug_thk_Y/2 - fillet_r, lug_z_center + lug_H/2 - fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_neg_in2() {
  translate([-(cyl_D/2 - overlap), lug_y_center - lug_thk_Y/2 + fillet_r, lug_z_center + lug_H/2 - fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_neg_out2() {
  translate([-(cyl_D/2 + lug_radial_len - overlap), lug_y_center - lug_thk_Y/2 + fillet_r, lug_z_center + lug_H/2 - fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_neg_in3() {
  translate([-(cyl_D/2 - overlap), lug_y_center + lug_thk_Y/2 - fillet_r, lug_z_center - lug_H/2 + fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_neg_out3() {
  translate([-(cyl_D/2 + lug_radial_len - overlap), lug_y_center + lug_thk_Y/2 - fillet_r, lug_z_center - lug_H/2 + fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_neg_in4() {
  translate([-(cyl_D/2 - overlap), lug_y_center - lug_thk_Y/2 + fillet_r, lug_z_center - lug_H/2 + fillet_r])
    sphere(r=fillet_r);
}

module lug_fillet_sphere_neg_out4() {
  translate([-(cyl_D/2 + lug_radial_len - overlap), lug_y_center - lug_thk_Y/2 + fillet_r, lug_z_center - lug_H/2 + fillet_r])
    sphere(r=fillet_r);
}

module chamfer_top_cone() {
  translate([0, 0, cyl_H/2 - chamfer_depth/2])
    cylinder(h=chamfer_depth, r1=cyl_D/2 + lug_radial_len, r2=0, center=true);
}

module chamfer_bot_cone() {
  translate([0, 0, -(cyl_H/2 - chamfer_depth/2)])
    cylinder(h=chamfer_depth, r1=cyl_D/2 + lug_radial_len, r2=0, center=true);
}

module marking_dimple() {
  translate([0, cyl_D/2 - mark_depth, 0])
    sphere(r=mark_r);
}

// Operations
module lug_blend_fillets_pos() {
  hull() {
    lug_fillet_sphere_pos_in();
    lug_fillet_sphere_pos_out();
    lug_fillet_sphere_pos_in2();
    lug_fillet_sphere_pos_out2();
    lug_fillet_sphere_pos_in3();
    lug_fillet_sphere_pos_out3();
    lug_fillet_sphere_pos_in4();
    lug_fillet_sphere_pos_out4();
  }
}

module lug_blend_fillets_neg() {
  hull() {
    lug_fillet_sphere_neg_in();
    lug_fillet_sphere_neg_out();
    lug_fillet_sphere_neg_in2();
    lug_fillet_sphere_neg_out2();
    lug_fillet_sphere_neg_in3();
    lug_fillet_sphere_neg_out3();
    lug_fillet_sphere_neg_in4();
    lug_fillet_sphere_neg_out4();
  }
}

module lug_blend_fillets() {
  union() {
    lug_blend_fillets_pos();
    lug_blend_fillets_neg();
  }
}

module main_union_pre() {
  union() {
    cyl_body();
    lug_pos();
    lug_neg();
    lug_blend_fillets();
  }
}

module edge_chamfers() {
  difference() {
    main_union_pre();
    chamfer_top_cone();
    chamfer_bot_cone();
  }
}

module surface_markings() {
  difference() {
    edge_chamfers();
    marking_dimple();
  }
}

// Final Output
surface_markings();