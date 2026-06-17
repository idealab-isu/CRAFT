// Parameters
L = 100; //[50:200:1]
ID = 6; //[3:12:0.1]
t = 0.3; //[0.15:0.6:0.05]
OD = 6.6; //[3.3:13.2:0.1]
shrink_ratio = 2; //[1.2:4:0.1]
ID_shrunk = 3; //[1.5:6:0.1]
overlap = 1; //[0.5:2:0.1]
chamfer_len = 1.2; //[0.6:2.4:0.1]
edge_round_r = 0.4; //[0.2:0.8:0.05]
mark_band_w = 8; //[4:16:0.5]
mark_band_t = 0.15; //[0.05:0.3:0.05]
post_ref_w = 6; //[3:12:0.5]
post_ref_t = 0.2; //[0.1:0.5:0.05]

// Base Shapes
module sleeve_outer_cyl() {
  cylinder(h=L, r=OD/2, center=true);
}

module inner_bore_cyl() {
  cylinder(h=L + 2*overlap, r=ID/2, center=true);
}

module chamfer_cut_top_cone() {
  translate([0, 0, L/2 - chamfer_len/2 + overlap/2])
    cylinder(h=chamfer_len, r1=OD/2 + overlap, r2=0, center=true);
}

module chamfer_cut_bottom_cone() {
  translate([0, 0, -L/2 + chamfer_len/2 - overlap/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_len, r1=OD/2 + overlap, r2=0, center=true);
}

module edge_round_top_torus() {
  translate([0, 0, L/2 - edge_round_r])
    rotate_extrude()
    translate([OD/2 - edge_round_r, 0, 0])
    circle(r=edge_round_r);
}

module edge_round_bottom_torus() {
  translate([0, 0, -L/2 + edge_round_r])
    rotate_extrude()
    translate([OD/2 - edge_round_r, 0, 0])
    circle(r=edge_round_r);
}

module printed_marking_band_outer() {
  cylinder(h=mark_band_w, r=OD/2 + mark_band_t, center=true);
}

module printed_marking_band_inner_clear() {
  cylinder(h=mark_band_w + 2*overlap, r=OD/2 - overlap, center=true);
}

module post_shrink_ref_outer() {
  cylinder(h=post_ref_w, r=(ID_shrunk/2) + post_ref_t, center=true);
}

module post_shrink_ref_inner() {
  cylinder(h=post_ref_w + 2*overlap, r=ID_shrunk/2, center=true);
}

module post_shrink_ref_attach_spoke() {
  translate([((ID_shrunk/2 + post_ref_t) + (ID/2))/2 - overlap/2, 0, 0])
    cube([(ID/2 - (ID_shrunk/2 + post_ref_t)) + overlap, post_ref_t*2, post_ref_w], center=true);
}

// Operations
module sleeve_tube() {
  difference() {
    sleeve_outer_cyl();
    inner_bore_cyl();
  }
}

module end_chamfers() {
  difference() {
    sleeve_tube();
    chamfer_cut_top_cone();
    chamfer_cut_bottom_cone();
  }
}

module cut_edge_rounding() {
  difference() {
    end_chamfers();
    edge_round_top_torus();
    edge_round_bottom_torus();
  }
}

module printed_marking_band() {
  difference() {
    printed_marking_band_outer();
    printed_marking_band_inner_clear();
  }
}

module post_shrink_reference_state_ring() {
  difference() {
    post_shrink_ref_outer();
    post_shrink_ref_inner();
  }
}

module post_shrink_reference_state() {
  union() {
    post_shrink_reference_state_ring();
    post_shrink_ref_attach_spoke();
  }
}

// Final Model
module complete_model() {
  union() {
    cut_edge_rounding();
    printed_marking_band();
    post_shrink_reference_state();
  }
}

// Render the final output
complete_model();