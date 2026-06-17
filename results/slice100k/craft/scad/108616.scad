// Parameters
L = 73.0; //[36.5:146.0:0.5]
W_max = 20.0; //[10.0:40.0:0.5]
T = 4.0; //[2.0:8.0:0.25]
handle_L = 45.0; //[22.5:90.0:0.5]
handle_W = 10.0; //[5.0:20.0:0.5]
head_L = 22.0; //[11.0:44.0:0.5]
head_W = 20.0; //[10.0:40.0:0.5]
head_R = 6.0; //[3.0:12.0:0.25]
neck_L = 6.0; //[3.0:12.0:0.5]
window_L = 14.0; //[7.0:28.0:0.5]
window_W = 8.0; //[4.0:16.0:0.5]
hole_D = 3.0; //[1.5:6.0:0.25]
hole_offset_from_window_end = 2.5; //[1.0:5.0:0.25]
hole_offset_from_window_side = 2.5; //[1.0:5.0:0.25]
overlap = 1.0; //[0.5:2.0:0.25]
chamfer_depth = 0.6; //[0.3:1.2:0.1]
hole_chamfer_depth = 0.5; //[0.25:1.0:0.05]
hole_chamfer_D = 4.6; //[3.6:7.0:0.1]

// Base Shapes
module handle_block() {
  translate([-L/2 + handle_L/2, 0, 0])
    cube([handle_L, handle_W, T], center=true);
}

module neck_block() {
  translate([-L/2 + handle_L + neck_L/2 - overlap, 0, 0])
    cube([neck_L, handle_W, T], center=true);
}

module head_core() {
  translate([L/2 - head_L/2, 0, 0])
    cube([head_L - 2*head_R, head_W, T], center=true);
}

module head_side_band_posY() {
  translate([L/2 - head_L/2, 0, 0])
    cube([head_L - 2*head_R, head_W - 2*head_R, T], center=true);
}

module rounded_head_corner_FR() {
  translate([L/2 - head_R, head_W/2 - head_R, 0])
    cylinder(r=head_R, h=T, center=true);
}

module rounded_head_corner_FL() {
  translate([L/2 - head_L + head_R, head_W/2 - head_R, 0])
    cylinder(r=head_R, h=T, center=true);
}

module rounded_head_corner_BR() {
  translate([L/2 - head_R, -head_W/2 + head_R, 0])
    cylinder(r=head_R, h=T, center=true);
}

module rounded_head_corner_BL() {
  translate([L/2 - head_L + head_R, -head_W/2 + head_R, 0])
    cylinder(r=head_R, h=T, center=true);
}

module tapered_neck_transition() {
  linear_extrude(height=T, center=true)
    polygon(points=[
      [-neck_L/2, -handle_W/2],
      [-neck_L/2, handle_W/2],
      [neck_L/2, head_W/2],
      [neck_L/2, -head_W/2]
    ]);
}

module window_cutout() {
  translate([L/2 - head_L/2, 0, 0])
    cube([window_L, window_W, T + 2*overlap], center=true);
}

module through_hole_1() {
  translate([(L/2 - head_L/2) - window_L/2 + hole_offset_from_window_end, window_W/2 + hole_offset_from_window_side, 0])
    cylinder(r=hole_D/2, h=T + 2*overlap, center=true);
}

module through_hole_2() {
  translate([(L/2 - head_L/2) + window_L/2 - hole_offset_from_window_end, -(window_W/2 + hole_offset_from_window_side), 0])
    cylinder(r=hole_D/2, h=T + 2*overlap, center=true);
}

module edge_chamfer_top_cut() {
  translate([0, 0, T/2 - chamfer_depth/2])
    cube([L + 2*overlap, W_max - 2*chamfer_depth, chamfer_depth], center=true);
}

module edge_chamfer_bottom_cut() {
  translate([0, 0, -T/2 + chamfer_depth/2])
    cube([L + 2*overlap, W_max - 2*chamfer_depth, chamfer_depth], center=true);
}

module hole_chamfer_1_top() {
  translate([(L/2 - head_L/2) - window_L/2 + hole_offset_from_window_end, window_W/2 + hole_offset_from_window_side, T/2 - hole_chamfer_depth/2])
    cylinder(r1=hole_chamfer_D/2, r2=hole_D/2, h=hole_chamfer_depth, center=true);
}

module hole_chamfer_1_bottom() {
  translate([(L/2 - head_L/2) - window_L/2 + hole_offset_from_window_end, window_W/2 + hole_offset_from_window_side, -T/2 + hole_chamfer_depth/2])
    cylinder(r1=hole_chamfer_D/2, r2=hole_D/2, h=hole_chamfer_depth, center=true);
}

module hole_chamfer_2_top() {
  translate([(L/2 - head_L/2) + window_L/2 - hole_offset_from_window_end, -(window_W/2 + hole_offset_from_window_side), T/2 - hole_chamfer_depth/2])
    cylinder(r1=hole_chamfer_D/2, r2=hole_D/2, h=hole_chamfer_depth, center=true);
}

module hole_chamfer_2_bottom() {
  translate([(L/2 - head_L/2) + window_L/2 - hole_offset_from_window_end, -(window_W/2 + hole_offset_from_window_side), -T/2 + hole_chamfer_depth/2])
    cylinder(r1=hole_chamfer_D/2, r2=hole_D/2, h=hole_chamfer_depth, center=true);
}

// Operations
module rounded_head_corners() {
  union() {
    head_core();
    head_side_band_posY();
    rounded_head_corner_FR();
    rounded_head_corner_FL();
    rounded_head_corner_BR();
    rounded_head_corner_BL();
  }
}

module tapered_neck_transition_pos() {
  translate([-L/2 + handle_L + neck_L/2 - overlap, 0, 0])
    tapered_neck_transition();
}

module outer_plate_profile() {
  union() {
    handle_block();
    neck_block();
    tapered_neck_transition_pos();
    rounded_head_corners();
  }
}

module outer_plate_with_window() {
  difference() {
    outer_plate_profile();
    window_cutout();
  }
}

module outer_plate_with_window_and_holes() {
  difference() {
    outer_plate_with_window();
    through_hole_1();
    through_hole_2();
  }
}

module outer_plate_with_edge_chamfers() {
  difference() {
    outer_plate_with_window_and_holes();
    edge_chamfer_top_cut();
    edge_chamfer_bottom_cut();
  }
}

module outer_plate_with_hole_chamfers() {
  difference() {
    outer_plate_with_edge_chamfers();
    hole_chamfer_1_top();
    hole_chamfer_1_bottom();
    hole_chamfer_2_top();
    hole_chamfer_2_bottom();
  }
}

// Final Output
outer_plate_with_hole_chamfers();