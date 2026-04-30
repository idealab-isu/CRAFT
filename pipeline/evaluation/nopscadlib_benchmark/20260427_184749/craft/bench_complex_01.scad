// Parameters
belt_width_mm = 6; //[3:12:1]
bearing_od_mm = 22; //[11:44:1]
bearing_id_mm = 8; //[4:16:1]
bearing_width_mm = 7; //[4:14:1]
idler_bolt_diameter_mm = 8; //[5:10:0.5]
pivot_bolt_diameter_mm = 5; //[3:8:0.5]
pivot_to_idler_center_distance_mm = 35; //[20:70:1]
arm_thickness_mm = 8; //[4:16:1]
arm_width_mm = 16; //[8:32:1]
base_thickness_mm = 8; //[4:16:1]
base_length_mm = 50; //[25:100:1]
base_width_mm = 30; //[15:60:1]
mount_hole_spacing_x_mm = 20; //[10:40:1]
mount_hole_diameter_mm = 5.2; //[3.5:7:0.1]
spring_free_length_mm = 20; //[10:40:1]
spring_outer_diameter_mm = 10; //[6:20:1]
spring_travel_mm = 6; //[2:12:1]
spring_preload_mm = 2; //[0:6:0.5]
spring_anchor_offset_mm = 12; //[6:24:1]
max_arm_rotation_deg = 25; //[10:45:1]
min_arm_rotation_deg = -5; //[-20:0:1]
belt_clearance_mm = 2; //[1:5:0.5]
bearing_side_clearance_mm = 0.5; //[0.2:1.5:0.1]
print_clearance_mm = 0.3; //[0.15:0.6:0.05]
overlap_mm = 1; //[0.5:2:0.1]
stop_block_thickness_mm = 6; //[3:12:1]

// Base bracket plate
module base_bracket_plate() {
  translate([0, 0, 0])
    cube([base_length_mm, base_width_mm, base_thickness_mm], center=true);
}

// Pivot axle mount block
module pivot_axle_mount_block() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm, 0, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*1.2)/2 - overlap_mm])
    cube([arm_thickness_mm*1.6, arm_width_mm*1.6, base_thickness_mm + arm_thickness_mm*1.2], center=true);
}

// Pivot hole cylinder
module pivot_hole_cyl() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm, 0, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*1.2)/2 - overlap_mm])
    rotate([90, 0, 0])
      cylinder(r=(pivot_bolt_diameter_mm + print_clearance_mm)/2, h=arm_width_mm*2.2, center=true);
}

// Mount hole cylinder
module mount_hole_cyl() {
  translate([0, 0, 0])
    cylinder(r=mount_hole_diameter_mm/2, h=base_thickness_mm + overlap_mm*2, center=true);
}

// Arm body box
module arm_body_box() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + (pivot_to_idler_center_distance_mm + bearing_od_mm/2 + arm_thickness_mm)/2 - overlap_mm, 0, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*1.2)/2 - overlap_mm])
    cube([pivot_to_idler_center_distance_mm + bearing_od_mm/2 + arm_thickness_mm, arm_width_mm, arm_thickness_mm], center=true);
}

// Arm pivot hole cylinder
module arm_pivot_hole_cyl() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm, 0, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*1.2)/2 - overlap_mm])
    rotate([90, 0, 0])
      cylinder(r=(pivot_bolt_diameter_mm + print_clearance_mm)/2, h=arm_width_mm + overlap_mm*2, center=true);
}

// Idler boss cylinder
module idler_boss_cyl() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + pivot_to_idler_center_distance_mm, 0, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*1.2)/2 - overlap_mm])
    rotate([0, 90, 0])
      cylinder(r=bearing_od_mm/2 + arm_thickness_mm*0.35, h=arm_thickness_mm, center=true);
}

// Idler bolt hole cylinder
module idler_bolt_hole_cyl() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + pivot_to_idler_center_distance_mm, 0, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*1.2)/2 - overlap_mm])
    rotate([90, 0, 0])
      cylinder(r=(idler_bolt_diameter_mm + print_clearance_mm)/2, h=arm_width_mm + overlap_mm*2, center=true);
}

// Bearing spacer cylinder
module bearing_spacer_cyl() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + pivot_to_idler_center_distance_mm, 0, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*1.2)/2 - overlap_mm])
    rotate([90, 0, 0])
      cylinder(r=bearing_id_mm/2 + print_clearance_mm, h=bearing_width_mm + bearing_side_clearance_mm*2, center=true);
}

// Spring post base cylinder
module spring_post_base_cyl() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + spring_anchor_offset_mm, arm_width_mm*0.9, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*0.6)/2 - overlap_mm])
    cylinder(r=spring_outer_diameter_mm/2 - print_clearance_mm, h=base_thickness_mm + arm_thickness_mm*0.6, center=true);
}

// Spring post arm cylinder
module spring_post_arm_cyl() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + spring_anchor_offset_mm, arm_width_mm*0.9, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*1.2)/2 - overlap_mm])
    cylinder(r=spring_outer_diameter_mm/2 - print_clearance_mm, h=arm_thickness_mm, center=true);
}

// Spring preload adjuster block
module spring_preload_adjuster_block() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + spring_anchor_offset_mm, arm_width_mm*0.9, base_thickness_mm/2])
    cube([arm_thickness_mm*1.2, spring_outer_diameter_mm*1.4, base_thickness_mm], center=true);
}

// Spring adjuster hole cylinder
module spring_adjuster_hole_cyl() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + spring_anchor_offset_mm, arm_width_mm*0.9, base_thickness_mm/2])
    rotate([90, 0, 0])
      cylinder(r=(pivot_bolt_diameter_mm + print_clearance_mm)/2, h=spring_outer_diameter_mm*1.6, center=true);
}

// Belt clearance channel box
module belt_clearance_channel_box() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6)/2 - overlap_mm + (pivot_to_idler_center_distance_mm + bearing_od_mm)/2, 0, base_thickness_mm/2])
    cube([pivot_to_idler_center_distance_mm + bearing_od_mm, belt_width_mm + belt_clearance_mm*2, arm_thickness_mm + base_thickness_mm], center=true);
}

// Stop block max
module stop_block_max() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6) - overlap_mm + stop_block_thickness_mm/2, 0, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*0.8)/2 - overlap_mm])
    cube([stop_block_thickness_mm, arm_width_mm*1.2, base_thickness_mm + arm_thickness_mm*0.8], center=true);
}

// Stop block min
module stop_block_min() {
  translate([-base_length_mm/2 + (arm_thickness_mm*1.6) - overlap_mm + stop_block_thickness_mm/2, arm_width_mm*0.9, base_thickness_mm/2 + (base_thickness_mm + arm_thickness_mm*0.8)/2 - overlap_mm])
    cube([stop_block_thickness_mm, arm_width_mm*1.2, base_thickness_mm + arm_thickness_mm*0.8], center=true);
}

// Base with holes
module base_with_holes() {
  difference() {
    union() {
      base_bracket_plate();
      pivot_axle_mount_block();
      spring_post_base_cyl();
      spring_preload_adjuster_block();
      stop_block_max();
      stop_block_min();
    }
    pivot_hole_cyl();
    translate([-mount_hole_spacing_x_mm/2, 0, 0]) mount_hole_cyl();
    translate([mount_hole_spacing_x_mm/2, 0, 0]) mount_hole_cyl();
    spring_adjuster_hole_cyl();
    belt_clearance_channel_box();
  }
}

// Pivot arm
module pivot_arm() {
  difference() {
    union() {
      arm_body_box();
      idler_boss_cyl();
      spring_post_arm_cyl();
      bearing_spacer_cyl();
    }
    arm_pivot_hole_cyl();
    idler_bolt_hole_cyl();
  }
}

// Tensioner assembly
module tensioner_assembly_union() {
  union() {
    base_with_holes();
    pivot_arm();
  }
}

// Final output
tensioner_assembly_union();