// A mains transformer, 120.0mm x 88.0mm x 120.0mm
// One connected solid (union with intentional overlaps)

overall_width_mm  = 120; //[60:240:1]
overall_depth_mm  = 88;  //[44:176:1]
overall_height_mm = 120; //[60:240:1]

foot_thickness_mm = 6;   //[3:12:1]
foot_width_ratio  = 1;   //[0.85:1.1:0.01]
foot_depth_ratio  = 0.9; //[0.7:1:0.01]

lamination_width_ratio  = 0.75; //[0.55:0.9:0.01]
lamination_depth_ratio  = 0.7;  //[0.5:0.85:0.01]
lamination_height_ratio = 0.65; //[0.45:0.8:0.01]

bobbin_width_ratio  = 0.55; //[0.35:0.75:0.01]
bobbin_depth_ratio  = 0.85; //[0.6:1:0.01]
bobbin_height_ratio = 0.45; //[0.25:0.65:0.01]

connect_overlap_mm = 1; //[0.5:2:0.1]

// Derived dimensions
foot_w = overall_width_mm  * foot_width_ratio;
foot_d = overall_depth_mm  * foot_depth_ratio;
foot_h = foot_thickness_mm;

lam_w = overall_width_mm   * lamination_width_ratio;
lam_d = overall_depth_mm   * lamination_depth_ratio;
lam_h = overall_height_mm  * lamination_height_ratio;

bob_w = overall_width_mm   * bobbin_width_ratio;
bob_d = overall_depth_mm   * bobbin_depth_ratio;
bob_h = overall_height_mm  * bobbin_height_ratio;

// Z placement (bottom of transformer at z = -overall_height_mm/2)
z_bottom = -overall_height_mm/2;

// Ensure the stack fits within overall height by scaling the upper blocks if needed
stack_h = foot_h + lam_h + bob_h;
scale_z = (stack_h > overall_height_mm) ? (overall_height_mm / stack_h) : 1;

lam_h_s = lam_h * scale_z;
bob_h_s = bob_h * scale_z;

// Clamp overlap to avoid inverted placement
ov = min(connect_overlap_mm, min(foot_h, min(lam_h_s, bob_h_s)) * 0.45);

// Component modules
module mounting_foot_plate() {
  translate([0, 0, z_bottom + foot_h/2])
    cube([foot_w, foot_d, foot_h], center=true);
}

module lamination_core_block() {
  // Sits on top of foot with slight overlap into foot
  translate([0, 0, z_bottom + foot_h + lam_h_s/2 - ov])
    cube([lam_w, lam_d, lam_h_s], center=true);
}

module bobbin_coil_block() {
  // Sits on top of lamination with slight overlap into lamination
  translate([0, 0, z_bottom + foot_h + lam_h_s + bob_h_s/2 - ov])
    cube([bob_w, bob_d, bob_h_s], center=true);
}

// Complete transformer assembly (one connected solid)
union() {
  mounting_foot_plate();
  lamination_core_block();
  bobbin_coil_block();
}