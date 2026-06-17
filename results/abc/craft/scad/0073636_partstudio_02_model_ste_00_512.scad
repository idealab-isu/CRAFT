// Dimension-calibrated (target: 0.40 x 0.78 x 0.45 mm)
scale([0.963903, 1.728425, 0.951719])
{
// Parameters
bbox_L = 0.78; //[0.39:1.56:0.01]
bbox_W = 0.4; //[0.2:0.8:0.01]
bbox_H = 0.45; //[0.225:0.9:0.01]
arm_thk = 0.12; //[0.06:0.24:0.005]
arm_depth = 0.2; //[0.1:0.4:0.005]
h_arm_len = 0.78; //[0.39:1.56:0.01]
v_arm_len = 0.45; //[0.225:0.9:0.01]
joint_overlap_L = 0.12; //[0.06:0.24:0.005]
joint_overlap_H = 0.12; //[0.06:0.24:0.005]
gusset_len = 0.14; //[0.07:0.28:0.005]
gusset_h = 0.14; //[0.07:0.28:0.005]
gusset_depth = 0.2; //[0.1:0.4:0.005]
end_thicken_len = 0.16; //[0.08:0.32:0.005]
end_thicken_extra_thk = 0.06; //[0.03:0.12:0.005]
overlap_eps = 0.001; //[0.0005:0.01:0.0005]
chamfer_size = 0.02; //[0.01:0.05:0.001]
fillet_r = 0.015; //[0.005:0.04:0.001]

// Base Shapes
module horizontal_arm() {
  translate([h_arm_len/2, arm_depth/2, arm_thk/2])
    cube([h_arm_len, arm_depth, arm_thk], center=true);
}

module vertical_arm() {
  translate([arm_thk/2, arm_depth/2, v_arm_len/2])
    cube([arm_thk, arm_depth, v_arm_len], center=true);
}

module right_angle_joint() {
  translate([joint_overlap_L/2, arm_depth/2, joint_overlap_H/2])
    cube([joint_overlap_L, arm_depth, joint_overlap_H], center=true);
}

module inner_corner_gusset() {
  translate([gusset_len/2, gusset_depth/2, gusset_h/2])
    rotate([90, 0, 0])
      linear_extrude(height=gusset_depth, center=true)
        polygon(points=[[0, 0], [gusset_len, 0], [0, gusset_h]]);
}

module horizontal_end_thickening() {
  translate([h_arm_len - end_thicken_len/2, arm_depth/2, arm_thk + end_thicken_extra_thk/2 - overlap_eps])
    cube([end_thicken_len, arm_depth, end_thicken_extra_thk], center=true);
}

module edge_chamfer_wedge_joint() {
  translate([chamfer_size/2, arm_depth/2, chamfer_size/2])
    rotate([90, 0, 0])
      linear_extrude(height=arm_depth + 2*overlap_eps, center=true)
        polygon(points=[[0, 0], [chamfer_size, 0], [0, chamfer_size]]);
}

module edge_chamfer_wedge_end() {
  translate([h_arm_len - chamfer_size/2, arm_depth/2, arm_thk + end_thicken_extra_thk - chamfer_size/2])
    rotate([90, 180, 0])
      linear_extrude(height=arm_depth + 2*overlap_eps, center=true)
        polygon(points=[[0, 0], [chamfer_size, 0], [0, chamfer_size]]);
}

module fillet_sphere() {
  translate([0, 0, 0])
    sphere(r=fillet_r, center=true);
}

// Operations
module arms_union() {
  union() {
    horizontal_arm();
    vertical_arm();
    right_angle_joint();
    inner_corner_gusset();
    horizontal_end_thickening();
  }
}

module edge_chamfers() {
  difference() {
    arms_union();
    edge_chamfer_wedge_joint();
    edge_chamfer_wedge_end();
  }
}

// Final Output
minkowski() {
  edge_chamfers();
  fillet_sphere();
}
}
