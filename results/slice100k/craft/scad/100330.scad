// Parameters
L = 61.15; //[30.58:122.3:0.01]
W = 31.86; //[15.93:63.72:0.01]
T = 5.5; //[2.75:11:0.01]
tab_end_radius = 15.93; //[7.965:31.86:0.01]
tab_center_spacing = 30.6; //[15.3:61.2:0.01]
web_width = 14; //[7:28:0.01]
web_offset_y = 4; //[-8:8:0.01]
hole_square = 4; //[2:8:0.01]
hole_offset_from_end = 6; //[3:12:0.01]
recess_L = 10; //[5:20:0.01]
recess_W = 12; //[6:24:0.01]
recess_depth = 1; //[0.5:2:0.01]
recess_offset_from_transition = 2; //[1:4:0.01]
overlap = 1; //[0.5:2:0.01]
eps = 0.2; //[0.05:0.5:0.01]

// Base Shapes
module end_tab_1() {
  translate([-tab_center_spacing/2, 0, 0])
    cylinder(r=tab_end_radius, h=T, center=true);
}

module end_tab_2() {
  translate([tab_center_spacing/2, 0, 0])
    cylinder(r=tab_end_radius, h=T, center=true);
}

module central_offset_web() {
  translate([0, web_offset_y, 0])
    cube([tab_center_spacing + 2*tab_end_radius - overlap, web_width, T], center=true);
}

module square_through_hole_1() {
  translate([-L/2 + hole_offset_from_end, 0, 0])
    cube([hole_square, hole_square, T + 2*eps], center=true);
}

module square_through_hole_2() {
  translate([L/2 - hole_offset_from_end, 0, 0])
    cube([hole_square, hole_square, T + 2*eps], center=true);
}

module recess_step_near_transition_1() {
  translate([-tab_center_spacing/2 + tab_end_radius - recess_offset_from_transition - recess_L/2, web_offset_y/2, T/2 - (recess_depth + eps)/2])
    cube([recess_L, recess_W, recess_depth + eps], center=true);
}

module recess_step_near_transition_2() {
  translate([tab_center_spacing/2 - tab_end_radius + recess_offset_from_transition + recess_L/2, web_offset_y/2, T/2 - (recess_depth + eps)/2])
    cube([recess_L, recess_W, recess_depth + eps], center=true);
}

// Operations
module link_plate_outer_profile() {
  union() {
    central_offset_web();
    end_tab_1();
    end_tab_2();
  }
}

module link_plate_with_holes() {
  difference() {
    link_plate_outer_profile();
    square_through_hole_1();
    square_through_hole_2();
  }
}

module link_plate_with_holes_and_recesses() {
  difference() {
    link_plate_with_holes();
    recess_step_near_transition_1();
    recess_step_near_transition_2();
  }
}

// Final Model
module final_model() {
  link_plate_with_holes_and_recesses();
}

// Render the final model
final_model();