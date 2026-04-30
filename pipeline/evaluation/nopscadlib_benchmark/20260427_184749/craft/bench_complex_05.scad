// Parameters
leadscrew_major_diameter_mm = 8; //[4:16:0.1]
leadscrew_clearance_diameter_mm = 9; //[6:18:0.1]
nut_outer_diameter_mm = 22; //[11:44:0.1]
nut_length_mm = 30; //[15:60:0.1]
housing_width_mm = 50; //[25:100:0.5]
housing_height_mm = 40; //[20:80:0.5]
housing_depth_mm = 30; //[15:60:0.5]
nut_pocket_diameter_mm = 22.2; //[11.1:44.4:0.1]
nut_pocket_depth_mm = 30.2; //[15.1:60.4:0.1]
anti_rotation_flat_width_mm = 20; //[10:40:0.1]
preload_travel_mm = 1.5; //[0.5:3:0.1]
preload_screw_count = 2; //[1:4:1]
preload_screw_clearance_diameter_mm = 4.3; //[3:6:0.1]
spring_pocket_diameter_mm = 8; //[4:16:0.1]
spring_pocket_depth_mm = 10; //[5:20:0.1]
rail_mount_hole_diameter_mm = 4.3; //[3:6:0.1]
rail_mount_hole_spacing_x_mm = 20; //[10:40:0.5]
rail_mount_hole_spacing_y_mm = 30; //[15:60:0.5]
mount_hole_edge_margin_mm = 6; //[3:12:0.5]
counterbore_diameter_mm = 8; //[6:14:0.1]
counterbore_depth_mm = 3; //[1:8:0.1]
material_clearance_mm = 0.2; //[0.05:0.6:0.05]
min_wall_thickness_mm = 3; //[1.5:6:0.1]
overlap_mm = 1; //[0.5:2:0.1]

// Base Shapes
module main_housing_block() {
  translate([0, 0, 0])
    cube([housing_width_mm, housing_height_mm, housing_depth_mm], center=true);
}

module t8_nut_pocket_cyl() {
  translate([0, 0, 0])
    cylinder(h=nut_pocket_depth_mm + 2*overlap_mm, r=nut_pocket_diameter_mm/2, center=true);
}

module anti_rotation_flat_cut() {
  translate([0, 0, 0])
    cube([nut_pocket_diameter_mm, nut_pocket_diameter_mm - anti_rotation_flat_width_mm, nut_pocket_depth_mm + 2*overlap_mm], center=true);
}

module leadscrew_clearance_bore() {
  translate([0, 0, 0])
    cylinder(h=housing_depth_mm + 2*overlap_mm, r=leadscrew_clearance_diameter_mm/2, center=true);
}

module split_slot_for_preload() {
  translate([0, 0, 0])
    cube([nut_pocket_diameter_mm + 2*min_wall_thickness_mm, preload_travel_mm + material_clearance_mm, housing_depth_mm + 2*overlap_mm], center=true);
}

module preload_screw_hole() {
  rotate([0, 90, 0])
    translate([0, 0, 0])
      cylinder(h=housing_width_mm + 2*overlap_mm, r=preload_screw_clearance_diameter_mm/2, center=true);
}

module spring_pocket() {
  rotate([0, 90, 0])
    translate([0, 0, 0])
      cylinder(h=spring_pocket_depth_mm + overlap_mm, r=spring_pocket_diameter_mm/2, center=true);
}

module rail_mount_through_hole() {
  translate([0, 0, 0])
    cylinder(h=housing_depth_mm + 2*overlap_mm, r=rail_mount_hole_diameter_mm/2, center=true);
}

module rail_mount_counterbore() {
  translate([0, 0, 0])
    cylinder(h=counterbore_depth_mm + overlap_mm, r=counterbore_diameter_mm/2, center=true);
}

module access_slot_for_adjustment() {
  translate([0, 0, 0])
    cube([housing_width_mm - 2*mount_hole_edge_margin_mm, preload_screw_clearance_diameter_mm + 2*material_clearance_mm, housing_depth_mm/2], center=true);
}

module debris_relief_channel() {
  rotate([0, 90, 0])
    translate([0, 0, 0])
      cylinder(h=housing_width_mm + 2*overlap_mm, r=leadscrew_clearance_diameter_mm/2 + material_clearance_mm, center=true);
}

module leadscrew_visual() {
  translate([0, 0, 0])
    cylinder(h=housing_depth_mm + 2*min_wall_thickness_mm, r=leadscrew_major_diameter_mm/2, center=true);
}

// Operations
module t8_nut_pocket() {
  difference() {
    t8_nut_pocket_cyl();
    anti_rotation_flat_cut();
  }
}

module preload_screws_pair() {
  union() {
    translate([0, nut_pocket_diameter_mm/2 + min_wall_thickness_mm, 0])
      preload_screw_hole();
    translate([0, -(nut_pocket_diameter_mm/2 + min_wall_thickness_mm), 0])
      preload_screw_hole();
  }
}

module spring_pockets_pair() {
  union() {
    translate([housing_width_mm/2 - spring_pocket_depth_mm/2 - min_wall_thickness_mm, nut_pocket_diameter_mm/2 + min_wall_thickness_mm, 0])
      spring_pocket();
    translate([housing_width_mm/2 - spring_pocket_depth_mm/2 - min_wall_thickness_mm, -(nut_pocket_diameter_mm/2 + min_wall_thickness_mm), 0])
      spring_pocket();
  }
}

module mounting_holes_pattern() {
  union() {
    translate([rail_mount_hole_spacing_x_mm/2, rail_mount_hole_spacing_y_mm/2, 0])
      rail_mount_through_hole();
    translate([-rail_mount_hole_spacing_x_mm/2, rail_mount_hole_spacing_y_mm/2, 0])
      rail_mount_through_hole();
    translate([rail_mount_hole_spacing_x_mm/2, -rail_mount_hole_spacing_y_mm/2, 0])
      rail_mount_through_hole();
    translate([-rail_mount_hole_spacing_x_mm/2, -rail_mount_hole_spacing_y_mm/2, 0])
      rail_mount_through_hole();
  }
}

module counterbores_or_countersinks() {
  union() {
    translate([rail_mount_hole_spacing_x_mm/2, rail_mount_hole_spacing_y_mm/2, housing_depth_mm/2 - counterbore_depth_mm/2])
      rail_mount_counterbore();
    translate([-rail_mount_hole_spacing_x_mm/2, rail_mount_hole_spacing_y_mm/2, housing_depth_mm/2 - counterbore_depth_mm/2])
      rail_mount_counterbore();
    translate([rail_mount_hole_spacing_x_mm/2, -rail_mount_hole_spacing_y_mm/2, housing_depth_mm/2 - counterbore_depth_mm/2])
      rail_mount_counterbore();
    translate([-rail_mount_hole_spacing_x_mm/2, -rail_mount_hole_spacing_y_mm/2, housing_depth_mm/2 - counterbore_depth_mm/2])
      rail_mount_counterbore();
  }
}

module access_slot_pos() {
  translate([0, 0, housing_depth_mm/2 - (housing_depth_mm/2)/2])
    access_slot_for_adjustment();
}

module debris_relief_pos() {
  translate([0, 0, -housing_depth_mm/2 + (leadscrew_clearance_diameter_mm/2 + material_clearance_mm)])
    debris_relief_channel();
}

module linear_rail_mount_interface() {
  difference() {
    main_housing_block();
    t8_nut_pocket();
    leadscrew_clearance_bore();
    split_slot_for_preload();
    preload_screws_pair();
    spring_pockets_pair();
    mounting_holes_pattern();
    counterbores_or_countersinks();
    access_slot_pos();
    debris_relief_pos();
  }
}

// Final Model
union() {
  linear_rail_mount_interface();
  leadscrew_visual();
}