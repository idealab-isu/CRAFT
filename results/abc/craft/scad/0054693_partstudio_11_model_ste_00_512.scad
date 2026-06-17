// Parameters
L = 3.14; //[1.57:6.28:0.01]
W = 1.61; //[0.805:3.22:0.01]
H = 0.51; //[0.255:1.02:0.01]
corner_clip = 0.22; //[0.11:0.44:0.01]
outer_chamfer = 0.06; //[0.03:0.12:0.005]
frame_margin = 0.18; //[0.09:0.36:0.01]
recess_depth = 0.12; //[0.06:0.24:0.01]
frame_height = 0.06; //[0.03:0.12:0.005]
panel_corner_clip = 0.12; //[0.06:0.24:0.01]
micro_fillet = 0.02; //[0.01:0.04:0.002]
bottom_micro_chamfer = 0.02; //[0.01:0.05:0.002]
overlap = 0.01; //[0.005:0.05:0.001]

// Base Plate Body
module base_plate_body() {
  cube([L, W, H], center=true);
}

// Clipped Corners Planform Cuts
module clipped_corners_planform_cut(x, y) {
  translate([x, y, 0])
  rotate([0, 0, 45])
  cube([corner_clip*2, corner_clip*2, H + overlap*2], center=true);
}

// Outer Edge Chamfer Sphere
module outer_edge_chamfer_sphere() {
  sphere(r=outer_chamfer);
}

// Top Face Recessed Panel Block
module top_face_recessed_panel_block() {
  translate([0, 0, H/2 - (recess_depth + overlap)/2])
  cube([L - 2*frame_margin, W - 2*frame_margin, recess_depth + overlap], center=true);
}

// Panel Corner Angle Cuts
module panel_corner_angle_cut(x, y) {
  translate([x, y, H/2 - recess_depth/2])
  rotate([0, 0, 45])
  cube([panel_corner_clip*2, panel_corner_clip*2, recess_depth + overlap*2], center=true);
}

// Top Face Raised Border Frame Outer
module top_face_raised_border_frame_outer() {
  translate([0, 0, H/2 - frame_height/2])
  cube([L - 2*outer_chamfer, W - 2*outer_chamfer, frame_height], center=true);
}

// Top Face Raised Border Frame Inner Void
module top_face_raised_border_frame_inner_void() {
  translate([0, 0, H/2 - frame_height/2])
  cube([L - 2*frame_margin, W - 2*frame_margin, frame_height + overlap*2], center=true);
}

// Micro Fillet Rounding Sphere
module micro_fillet_rounding_sphere() {
  sphere(r=micro_fillet);
}

// Bottom Face Micro Chamfer Sphere
module bottom_face_micro_chamfer_sphere() {
  sphere(r=bottom_micro_chamfer);
}

// Main Geometry
module final_geometry() {
  difference() {
    base_plate_body();
    clipped_corners_planform_cut(L/2 - corner_clip, W/2 - corner_clip);
    clipped_corners_planform_cut(-L/2 + corner_clip, W/2 - corner_clip);
    clipped_corners_planform_cut(L/2 - corner_clip, -W/2 + corner_clip);
    clipped_corners_planform_cut(-L/2 + corner_clip, -W/2 + corner_clip);
  }
}

// Apply Chamfers and Fillets
module apply_chamfers_and_fillets() {
  minkowski() {
    final_geometry();
    outer_edge_chamfer_sphere();
  }
}

// Top Face Recessed Panel with Corner Cuts
module top_face_recessed_panel_with_corner_cuts() {
  difference() {
    apply_chamfers_and_fillets();
    top_face_recessed_panel_block();
    panel_corner_angle_cut((L - 2*frame_margin)/2 - panel_corner_clip, (W - 2*frame_margin)/2 - panel_corner_clip);
    panel_corner_angle_cut(-(L - 2*frame_margin)/2 + panel_corner_clip, (W - 2*frame_margin)/2 - panel_corner_clip);
    panel_corner_angle_cut((L - 2*frame_margin)/2 - panel_corner_clip, -(W - 2*frame_margin)/2 + panel_corner_clip);
    panel_corner_angle_cut(-(L - 2*frame_margin)/2 + panel_corner_clip, -(W - 2*frame_margin)/2 + panel_corner_clip);
  }
}

// Top Face Raised Border Frame
module top_face_raised_border_frame() {
  difference() {
    top_face_raised_border_frame_outer();
    top_face_raised_border_frame_inner_void();
  }
}

// Body Plus Frame
module body_plus_frame() {
  union() {
    top_face_recessed_panel_with_corner_cuts();
    top_face_raised_border_frame();
  }
}

// Final Output with Micro Fillet and Bottom Chamfer
minkowski() {
  minkowski() {
    body_plus_frame();
    micro_fillet_rounding_sphere();
  }
  bottom_face_micro_chamfer_sphere();
}