// Dimension-calibrated (target: 0.40 x 0.78 x 0.45 mm)
scale([0.956292, 2.561014, 0.939496])
{
// Parameters
bbox_x = 0.78; //[0.39:1.56:0.01]
bbox_y = 0.4; //[0.2:0.8:0.01]
bbox_z = 0.45; //[0.225:0.9:0.01]
arm_w = 0.12; //[0.06:0.24:0.005]
arm_t = 0.1; //[0.05:0.2:0.005]
h_arm_L = 0.78; //[0.39:1.56:0.01]
v_arm_H = 0.45; //[0.225:0.9:0.01]
inside_clear_L = 0.66; //[0.33:1.32:0.01]
inside_clear_H = 0.35; //[0.175:0.7:0.01]
gusset_L = 0.1; //[0.05:0.2:0.005]
gusset_H = 0.1; //[0.05:0.2:0.005]
gusset_T = 0.1; //[0.05:0.2:0.005]
end_thicken_L = 0.14; //[0.07:0.28:0.01]
end_thicken_extra_t = 0.04; //[0.02:0.08:0.005]
overlap = 0.001; //[0.0005:0.01:0.0005]
fillet_r = 0.01; //[0.005:0.03:0.001]
chamfer_r = 0.008; //[0.004:0.02:0.001]

// Base Shapes
module horizontal_arm() {
  translate([h_arm_L/2, 0, arm_t/2])
    cube([h_arm_L, arm_w, arm_t], center=true);
}

module vertical_arm() {
  translate([arm_t/2, 0, v_arm_H/2])
    cube([arm_t, arm_w, v_arm_H], center=true);
}

module right_angle_joint() {
  translate([arm_t/2, 0, arm_t/2])
    cube([arm_t + overlap*2, arm_w, arm_t + overlap*2], center=true);
}

module inside_corner_gusset() {
  translate([0, 0, 0])
    rotate([90, 0, 0])
      linear_extrude(height=gusset_T, center=true)
        polygon(points=[[arm_t, arm_t], [arm_t + gusset_L, arm_t], [arm_t, arm_t + gusset_H]]);
}

module horizontal_end_thickening() {
  translate([h_arm_L - end_thicken_L/2, 0, arm_t + end_thicken_extra_t/2 - overlap])
    cube([end_thicken_L, arm_w, end_thicken_extra_t], center=true);
}

module edge_fillets_sphere() {
  sphere(r=fillet_r, center=true);
}

module edge_chamfers_sphere() {
  sphere(r=chamfer_r, center=true);
}

// Operations
module union_core() {
  union() {
    horizontal_arm();
    vertical_arm();
    right_angle_joint();
    inside_corner_gusset();
    horizontal_end_thickening();
  }
}

// Final Output
module edge_chamfers() {
  minkowski() {
    minkowski() {
      union_core();
      edge_fillets_sphere();
    }
    edge_chamfers_sphere();
  }
}

// Render the final output
edge_chamfers();
}
