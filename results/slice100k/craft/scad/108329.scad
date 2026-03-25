// Parameters
bbox_X = 46.19; //[23.095:92.38:0.01]
bbox_Y = 40; //[20:80:0.01]
bbox_Z = 19; //[9.5:38:0.01]
body_thickness = 19; //[9.5:38:0.01]
hex_flat_to_flat_Y = 40; //[20:80:0.01]
hex_point_to_point_X = 46.19; //[23.095:92.38:0.01]
hole_d = 6; //[3:12:0.01]
hole_offset_X = 0; //[-5:5:0.01]
hole_offset_Y = 0; //[-5:5:0.01]
notch_count = 6; //[3:12:1]
notch_w = 8; //[4:16:0.01]
notch_d = 3; //[1.5:6:0.01]
notch_h = 3; //[1:8:0.01]
notch_z0 = 0; //[-5:5:0.01]
top_relief_w = 18; //[9:36:0.01]
top_relief_d = 10; //[5:20:0.01]
top_relief_h = 4; //[1:9:0.01]
top_relief_offset_X = 6; //[-15:15:0.01]
top_relief_offset_Y = -4; //[-15:15:0.01]
bottom_relief_w = 16; //[8:32:0.01]
bottom_relief_d = 12; //[6:24:0.01]
bottom_relief_h = 3; //[1:9:0.01]
bottom_relief_offset_X = -7; //[-15:15:0.01]
bottom_relief_offset_Y = 5; //[-15:15:0.01]
edge_chamfer = 0.8; //[0.2:2:0.01]
csk_top_d = 10.5; //[7:18:0.01]
csk_top_h = 2.5; //[1:6:0.01]
align_mark_d = 2; //[1:4:0.01]
align_mark_h = 0.8; //[0.3:2:0.01]
overlap = 1; //[0.5:2:0.01]
hex_R = 23.095; //[11.5475:46.19:0.01]
hex_r = 20; //[10:40:0.01]

// Base Shapes
module hex_main_body() {
  linear_extrude(height=body_thickness, center=true) {
    polygon(points=[
      [hex_R, 0],
      [hex_R/2, hex_r],
      [-hex_R/2, hex_r],
      [-hex_R, 0],
      [-hex_R/2, -hex_r],
      [hex_R/2, -hex_r]
    ]);
  }
}

module central_through_hole() {
  translate([hole_offset_X, hole_offset_Y, 0])
    cylinder(r=hole_d/2, h=body_thickness + 2*overlap, center=true);
}

module counterbore_or_countersink_on_hole() {
  translate([hole_offset_X, hole_offset_Y, body_thickness/2 - (csk_top_h + overlap)/2])
    cylinder(r=csk_top_d/2, h=csk_top_h + overlap, center=true);
}

module top_face_asymmetric_relief() {
  translate([top_relief_offset_X, top_relief_offset_Y, body_thickness/2 - (top_relief_h + overlap)/2])
    cube([top_relief_w, top_relief_d, top_relief_h + overlap], center=true);
}

module bottom_face_asymmetric_relief() {
  translate([bottom_relief_offset_X, bottom_relief_offset_Y, -body_thickness/2 + (bottom_relief_h + overlap)/2])
    cube([bottom_relief_w, bottom_relief_d, bottom_relief_h + overlap], center=true);
}

module perimeter_notch(angle) {
  rotate([0, 0, angle])
    translate([hex_R - (notch_d/2) + overlap, 0, notch_z0])
      cube([notch_d + 2*overlap, notch_w, notch_h + 2*overlap], center=true);
}

module edge_chamfer_top() {
  translate([0, 0, body_thickness/2 - edge_chamfer])
    cylinder(r1=hex_R + edge_chamfer, r2=hex_R - edge_chamfer, h=2*edge_chamfer, center=true);
}

module edge_chamfer_bottom() {
  translate([0, 0, -body_thickness/2 + edge_chamfer])
    cylinder(r1=hex_R + edge_chamfer, r2=hex_R - edge_chamfer, h=2*edge_chamfer, center=true);
}

module small_alignment_marks_top_1() {
  translate([hex_r/2, 0, body_thickness/2 - (align_mark_h + overlap)/2])
    cylinder(r=align_mark_d/2, h=align_mark_h + overlap, center=true);
}

module small_alignment_marks_top_2() {
  translate([0, hex_r/2, body_thickness/2 - (align_mark_h + overlap)/2])
    cylinder(r=align_mark_d/2, h=align_mark_h + overlap, center=true);
}

// Operations
module perimeter_rectangular_notches() {
  union() {
    for (i = [0:notch_count-1])
      perimeter_notch(i * 360/notch_count);
  }
}

module small_alignment_marks() {
  union() {
    small_alignment_marks_top_1();
    small_alignment_marks_top_2();
  }
}

module edge_chamfers_fillets() {
  union() {
    edge_chamfer_top();
    edge_chamfer_bottom();
  }
}

module hex_body_minus_hole() {
  difference() {
    hex_main_body();
    central_through_hole();
  }
}

module hex_body_minus_hole_minus_csk() {
  difference() {
    hex_body_minus_hole();
    counterbore_or_countersink_on_hole();
  }
}

module hex_body_minus_notches() {
  difference() {
    hex_body_minus_hole_minus_csk();
    perimeter_rectangular_notches();
  }
}

module hex_body_minus_top_relief() {
  difference() {
    hex_body_minus_notches();
    top_face_asymmetric_relief();
  }
}

module hex_body_minus_bottom_relief() {
  difference() {
    hex_body_minus_top_relief();
    bottom_face_asymmetric_relief();
  }
}

module hex_body_minus_alignment_marks() {
  difference() {
    hex_body_minus_bottom_relief();
    small_alignment_marks();
  }
}

module complete_model() {
  difference() {
    hex_body_minus_alignment_marks();
    edge_chamfers_fillets();
  }
}

// Final Output
complete_model();