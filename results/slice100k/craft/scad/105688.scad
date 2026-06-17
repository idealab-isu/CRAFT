// Parameters
L = 78.5; //[39.25:157:0.1]
W_max = 19.5; //[9.75:39:0.01]
D_max = 18.88; //[9.44:37.76:0.01]
outer_rx = 9.75; //[4.875:19.5:0.01]
outer_ry = 9.44; //[4.72:18.88:0.01]
bore_r = 6.5; //[3.25:13:0.01]
slit_w = 2; //[0.8:4:0.01]
notch_depth = 0.6; //[0.2:1.2:0.01]
notch_height = 1.5; //[0.6:3:0.01]
notch_z_span = 18; //[9:36:0.1]
notch_count = 3; //[1:7:1]
overlap = 1; //[0.5:2:0.1]
flat_x = 0.9; //[0.3:2:0.01]
flat_y = 0.7; //[0.3:2:0.01]
slit_leadin = 1.2; //[0.5:3:0.01]
slit_leadin_z = 6; //[2:15:0.1]
edge_chamfer = 0.6; //[0.2:1.5:0.01]
edge_fillet_r = 0.5; //[0.2:1.2:0.01]

// Base Shapes
module outer_sleeve_body_raw() {
  linear_extrude(height=L, center=true)
    polygon(points=[
      [outer_rx, 0],
      [outer_rx*0.9239, outer_ry*0.3827],
      [outer_rx*0.7071, outer_ry*0.7071],
      [outer_rx*0.3827, outer_ry*0.9239],
      [0, outer_ry],
      [-outer_rx*0.3827, outer_ry*0.9239],
      [-outer_rx*0.7071, outer_ry*0.7071],
      [-outer_rx*0.9239, outer_ry*0.3827],
      [-outer_rx, 0],
      [-outer_rx*0.9239, -outer_ry*0.3827],
      [-outer_rx*0.7071, -outer_ry*0.7071],
      [-outer_rx*0.3827, -outer_ry*0.9239],
      [0, -outer_ry],
      [outer_rx*0.3827, -outer_ry*0.9239],
      [outer_rx*0.7071, -outer_ry*0.7071],
      [outer_rx*0.9239, -outer_ry*0.3827]
    ]);
}

module inner_bore() {
  cylinder(r=bore_r, h=L + 2*overlap, center=true);
}

module full_length_axial_slit() {
  translate([0, 0, 0])
    cube([W_max + 2*overlap, slit_w, L + 2*overlap], center=true);
}

module outer_corner_flattening_to_squareish_profile_xpos() {
  translate([W_max/2 - flat_x, 0, 0])
    cube([flat_x*2, D_max + 2*overlap, L + 2*overlap], center=true);
}

module outer_corner_flattening_to_squareish_profile_xneg() {
  translate([-(W_max/2 - flat_x), 0, 0])
    cube([flat_x*2, D_max + 2*overlap, L + 2*overlap], center=true);
}

module outer_corner_flattening_to_squareish_profile_ypos() {
  translate([0, D_max/2 - flat_y, 0])
    cube([W_max + 2*overlap, flat_y*2, L + 2*overlap], center=true);
}

module outer_corner_flattening_to_squareish_profile_yneg() {
  translate([0, -(D_max/2 - flat_y), 0])
    cube([W_max + 2*overlap, flat_y*2, L + 2*overlap], center=true);
}

module internal_relief_notch_band(pos, z_offset) {
  translate([bore_r - notch_depth/2, pos * (slit_w/2 + notch_height/2 - overlap), z_offset])
    cube([notch_depth + overlap, notch_height, notch_z_span], center=true);
}

module lead_in_taper_slit_edge_end(pos) {
  translate([0, 0, pos * (L/2 - slit_leadin_z/2)])
    rotate([pos * 90, 0, 0])
    cylinder(r1=slit_w/2 + edge_chamfer, r2=0, h=slit_leadin_z, center=true);
}

module edge_chamfers_end_wedge(pos) {
  translate([0, 0, pos * (L/2 - edge_chamfer)])
    rotate([0, 45, 0])
    cube([W_max + 2*overlap, D_max + 2*overlap, edge_chamfer*2], center=true);
}

module edge_fillets_kernel_sphere() {
  sphere(r=edge_fillet_r, center=true);
}

// Operations
module outer_sleeve_body_flattened_x() {
  difference() {
    outer_sleeve_body_raw();
    outer_corner_flattening_to_squareish_profile_xpos();
    outer_corner_flattening_to_squareish_profile_xneg();
  }
}

module outer_sleeve_body_flattened_xy() {
  difference() {
    outer_sleeve_body_flattened_x();
    outer_corner_flattening_to_squareish_profile_ypos();
    outer_corner_flattening_to_squareish_profile_yneg();
  }
}

module outer_sleeve_body_minus_bore() {
  difference() {
    outer_sleeve_body_flattened_xy();
    inner_bore();
  }
}

module outer_sleeve_body_minus_bore_minus_slit() {
  difference() {
    outer_sleeve_body_minus_bore();
    full_length_axial_slit();
  }
}

module outer_sleeve_body_with_internal_relief_notches_near_slit() {
  difference() {
    outer_sleeve_body_minus_bore_minus_slit();
    internal_relief_notch_band(1, 0);
    internal_relief_notch_band(-1, 0);
    internal_relief_notch_band(1, L/4);
    internal_relief_notch_band(-1, L/4);
    internal_relief_notch_band(1, -L/4);
    internal_relief_notch_band(-1, -L/4);
  }
}

module outer_sleeve_body_with_lead_in_tapers_on_slit_edges() {
  difference() {
    outer_sleeve_body_with_internal_relief_notches_near_slit();
    lead_in_taper_slit_edge_end(1);
    lead_in_taper_slit_edge_end(-1);
  }
}

module outer_sleeve_body_with_edge_chamfers() {
  difference() {
    outer_sleeve_body_with_lead_in_tapers_on_slit_edges();
    edge_chamfers_end_wedge(1);
    edge_chamfers_end_wedge(-1);
  }
}

module outer_sleeve_body_with_edge_fillets() {
  minkowski() {
    outer_sleeve_body_with_edge_chamfers();
    edge_fillets_kernel_sphere();
  }
}

// Final Output
module complete_model_union() {
  union() {
    outer_sleeve_body_with_edge_fillets();
  }
}

// Render the final model
complete_model_union();