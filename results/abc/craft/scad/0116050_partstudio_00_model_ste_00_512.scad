// Parameters
bbox_x = 0.15; //[0.075:0.3:0.001]
bbox_y = 0.13; //[0.065:0.26:0.001]
bbox_z = 0.08; //[0.04:0.16:0.001]
base_x = 0.15; //[0.075:0.3:0.001]
base_y = 0.13; //[0.065:0.26:0.001]
base_z = 0.03; //[0.015:0.06:0.001]
base_corner_r = 0.015; //[0.0075:0.03:0.0005]
arm_thk_z = 0.02; //[0.01:0.04:0.001]
arm_w = 0.03; //[0.015:0.06:0.001]
elbow_r = 0.03; //[0.015:0.06:0.001]
arm_leg1_len = 0.05; //[0.025:0.1:0.001]
arm_leg2_len = 0.05; //[0.025:0.1:0.001]
end_pad_x = 0.03; //[0.015:0.06:0.001]
end_pad_y = 0.04; //[0.02:0.08:0.001]
end_pad_z = 0.02; //[0.01:0.04:0.001]
boss1_x = 0.02; //[0.01:0.04:0.001]
boss1_y = 0.02; //[0.01:0.04:0.001]
boss1_z = 0.01; //[0.005:0.02:0.001]
boss2_x = 0.02; //[0.01:0.04:0.001]
boss2_y = 0.02; //[0.01:0.04:0.001]
boss2_z = 0.01; //[0.005:0.02:0.001]
overlap = 0.001; //[0.0005:0.002:0.0001]
fillet_r = 0.004; //[0.002:0.008:0.0005]
chamfer_depth = 0.003; //[0.001:0.006:0.0005]
mount_hole_r = 0.006; //[0.003:0.012:0.0005]
mount_hole_offset_x = 0.04; //[0.02:0.07:0.001]

// Base rounded rectangle
module base_block_rounded_rect() {
  hull() {
    translate([-base_x/2 + base_corner_r, base_y/2 - base_corner_r, 0])
      cylinder(r=base_corner_r, h=base_z, center=true);
    translate([base_x/2 - base_corner_r, base_y/2 - base_corner_r, 0])
      cylinder(r=base_corner_r, h=base_z, center=true);
    translate([-base_x/2 + base_corner_r, -base_y/2 + base_corner_r, 0])
      cylinder(r=base_corner_r, h=base_z, center=true);
    translate([base_x/2 - base_corner_r, -base_y/2 + base_corner_r, 0])
      cylinder(r=base_corner_r, h=base_z, center=true);
  }
}

// Cantilever arm with elbow
module cantilever_arm() {
  // Arm leg 1
  translate([0, 0, base_z/2 + arm_leg1_len/2 - overlap])
    cube([arm_thk_z, arm_w, arm_leg1_len], center=true);
  
  // Arm leg 2
  translate([arm_leg2_len/2 - overlap, 0, base_z/2 + arm_leg1_len - arm_thk_z/2])
    cube([arm_leg2_len, arm_w, arm_thk_z], center=true);
  
  // Elbow
  difference() {
    intersection() {
      translate([0, 0, base_z/2 + arm_leg1_len - elbow_r])
        rotate([90, 0, 0])
        cylinder(r=elbow_r + arm_thk_z/2, h=arm_w, center=true);
      translate([(elbow_r + arm_thk_z)/2 - overlap, 0, base_z/2 + arm_leg1_len - elbow_r + (elbow_r + arm_thk_z)/2 - overlap])
        cube([elbow_r + arm_thk_z, arm_w + 2*overlap, elbow_r + arm_thk_z], center=true);
    }
    translate([0, 0, base_z/2 + arm_leg1_len - elbow_r])
      rotate([90, 0, 0])
      cylinder(r=elbow_r - arm_thk_z/2, h=arm_w + 2*overlap, center=true);
  }
}

// End pad
module end_pad() {
  translate([arm_leg2_len - overlap + end_pad_x/2, 0, base_z/2 + arm_leg1_len - arm_thk_z/2])
    cube([end_pad_x, end_pad_y, end_pad_z], center=true);
}

// Bosses
module bosses() {
  // Boss near junction
  translate([0, 0, base_z/2 + boss1_z/2 - overlap])
    cube([boss1_x, boss1_y, boss1_z], center=true);
  
  // Boss near end pad
  translate([arm_leg2_len - overlap + end_pad_x/2, 0, base_z/2 + arm_leg1_len - arm_thk_z/2 + end_pad_z/2 - overlap])
    cube([boss2_x, boss2_y, boss2_z], center=true);
}

// Mounting holes
module mounting_holes() {
  translate([-mount_hole_offset_x, 0, 0])
    cylinder(r=mount_hole_r, h=base_z + 2*overlap, center=true);
  translate([mount_hole_offset_x, 0, 0])
    cylinder(r=mount_hole_r, h=base_z + 2*overlap, center=true);
}

// Chamfers
module chamfers() {
  translate([-base_x/2 + chamfer_depth/2, 0, base_z/2 - chamfer_depth/2])
    rotate([0, 45, 0])
    cube([chamfer_depth, base_y + 2*overlap, chamfer_depth], center=true);
  translate([base_x/2 - chamfer_depth/2, 0, base_z/2 - chamfer_depth/2])
    rotate([0, 45, 0])
    cube([chamfer_depth, base_y + 2*overlap, chamfer_depth], center=true);
}

// Final assembly
difference() {
  union() {
    base_block_rounded_rect();
    bosses();
    minkowski() {
      union() {
        cantilever_arm();
        end_pad();
      }
      sphere(r=fillet_r, center=true);
    }
  }
  chamfers();
  mounting_holes();
}