// Parameters
bbox_X = 31.86; //[15.93:63.72:0.01]
bbox_Y = 61.15; //[30.58:122.3:0.01]
bbox_Z = 5.5; //[2.75:11:0.01]
plate_thk = 5.5; //[2.75:11:0.01]
tab_W = 31.86; //[15.93:63.72:0.01]
tab_L = 20; //[10:40:0.01]
tab_end_R = 15.93; //[7.965:31.86:0.01]
web_W = 16; //[8:32:0.01]
web_L = 21.15; //[10.58:42.3:0.01]
web_offset_X = 6; //[0:12:0.01]
hole_sq = 4; //[2:8:0.01]
hole_tip_margin = 5; //[2.5:10:0.01]
recess_L = 10; //[5:20:0.01]
recess_W = 18; //[9:36:0.01]
recess_depth = 1; //[0.5:2:0.01]
recess_from_transition = 2; //[1:4:0.01]
overlap = 1; //[0.5:2:0.01]
fillet_r = 1.5; //[0.5:3:0.01]
marking_depth = 0.3; //[0.1:0.8:0.01]
marking_r = 3; //[1.5:6:0.01]

// Base Shapes
module end_tab_left_rect() {
  translate([0, -(bbox_Y/2 - tab_L/2), 0])
    cube([tab_W, tab_L - tab_end_R, plate_thk], center=true);
}

module end_tab_left_round() {
  translate([0, -(bbox_Y/2 - tab_end_R), 0])
    cylinder(r=tab_end_R, h=plate_thk, center=true);
}

module end_tab_right_rect() {
  translate([0, (bbox_Y/2 - tab_L/2), 0])
    cube([tab_W, tab_L - tab_end_R, plate_thk], center=true);
}

module end_tab_right_round() {
  translate([0, (bbox_Y/2 - tab_end_R), 0])
    cylinder(r=tab_end_R, h=plate_thk, center=true);
}

module central_web_offset() {
  translate([web_offset_X, 0, 0])
    cube([web_W, web_L + 2*overlap, plate_thk], center=true);
}

module additional_rounding_at_web_transitions() {
  translate([web_offset_X, 0, 0])
    cylinder(r=web_W/2, h=plate_thk, center=true);
}

module square_hole_left() {
  translate([0, -(bbox_Y/2 - hole_tip_margin), 0])
    cube([hole_sq, hole_sq, plate_thk + 2*overlap], center=true);
}

module square_hole_right() {
  translate([0, (bbox_Y/2 - hole_tip_margin), 0])
    cube([hole_sq, hole_sq, plate_thk + 2*overlap], center=true);
}

module recess_step_left() {
  translate([web_offset_X/2, -(web_L/2 + recess_from_transition + recess_L/2), plate_thk/2 - recess_depth/2])
    cube([recess_W, recess_L, recess_depth + overlap], center=true);
}

module recess_step_right() {
  translate([web_offset_X/2, (web_L/2 + recess_from_transition + recess_L/2), plate_thk/2 - recess_depth/2])
    cube([recess_W, recess_L, recess_depth + overlap], center=true);
}

module surface_markings() {
  translate([web_offset_X, 0, plate_thk/2 - marking_depth/2])
    cylinder(r=marking_r, h=marking_depth + overlap, center=true);
}

module edge_fillets_chamfers_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module end_tab_left() {
  union() {
    end_tab_left_rect();
    end_tab_left_round();
  }
}

module end_tab_right() {
  union() {
    end_tab_right_rect();
    end_tab_right_round();
  }
}

module link_plate_outline() {
  union() {
    end_tab_left();
    end_tab_right();
    central_web_offset();
    additional_rounding_at_web_transitions();
  }
}

module link_plate_with_holes() {
  difference() {
    link_plate_outline();
    square_hole_left();
    square_hole_right();
  }
}

module link_plate_with_recesses() {
  difference() {
    link_plate_with_holes();
    recess_step_left();
    recess_step_right();
    surface_markings();
  }
}

// Final Output
minkowski() {
  link_plate_with_recesses();
  edge_fillets_chamfers_sphere();
}