// Parameters
bbox_x = 0.04; //[0.02:0.08:0.001]
bbox_y = 0.03; //[0.015:0.06:0.001]
bbox_z = 0.16; //[0.08:0.32:0.001]
body_len = 0.16; //[0.08:0.32:0.001]
body_w = 0.04; //[0.02:0.08:0.001]
body_t = 0.03; //[0.015:0.06:0.001]
corner_r = 0.004; //[0.002:0.008:0.0005]
curve_sag = 0.004; //[0.0:0.008:0.0005]
reinforce_len = 0.05; //[0.025:0.1:0.001]
reinforce_w = 0.038; //[0.019:0.076:0.001]
reinforce_t = 0.03; //[0.015:0.06:0.001]
window_len = 0.045; //[0.0225:0.09:0.001]
window_w = 0.022; //[0.011:0.044:0.001]
window_t = 0.032; //[0.016:0.064:0.001]
window_gap = 0.01; //[0.005:0.02:0.001]
end_margin = 0.015; //[0.0075:0.03:0.001]
end_hole_d = 0.006; //[0.003:0.012:0.0005]
end_chamfer = 0.004; //[0.002:0.008:0.0005]
overlap = 0.001; //[0.0005:0.002:0.0005]
facet_z = 0.04; //[0.02:0.08:0.005]
bevel = 0.0015; //[0.0005:0.003:0.0005]

// Main strap body
module main_strap_body() {
  cube([body_w - 2*corner_r, body_t - 2*corner_r, body_len - 2*corner_r], center=true);
}

// Edge fillets sphere
module edge_fillets_sphere() {
  sphere(r=corner_r, center=true);
}

// Central thickened reinforcement
module central_thickened_reinforcement() {
  cube([reinforce_w - 2*corner_r, reinforce_t - 2*corner_r, reinforce_len - 2*corner_r], center=true);
}

// Window cutouts
module window_cutout_1() {
  translate([0, 0, -(window_gap/2 + window_len/2)])
    cube([window_w, window_t, window_len], center=true);
}

module window_cutout_2() {
  translate([0, 0, (window_gap/2 + window_len/2)])
    cube([window_w, window_t, window_len], center=true);
}

// Cosmetic bevels on windows
module cosmetic_bevels_on_windows_1() {
  translate([0, 0, -(window_gap/2 + window_len/2)])
    cube([window_w + 2*bevel, window_t + 2*bevel, window_len + 2*bevel], center=true);
}

module cosmetic_bevels_on_windows_2() {
  translate([0, 0, (window_gap/2 + window_len/2)])
    cube([window_w + 2*bevel, window_t + 2*bevel, window_len + 2*bevel], center=true);
}

// End holes
module end_hole_1() {
  translate([0, 0, -(body_len/2 - end_margin)])
    rotate([90, 0, 0])
      cylinder(r=end_hole_d/2, h=body_t + 2*overlap, center=true);
}

module end_hole_2() {
  translate([0, 0, (body_len/2 - end_margin)])
    rotate([90, 0, 0])
      cylinder(r=end_hole_d/2, h=body_t + 2*overlap, center=true);
}

// End chamfers or rounds
module end_chamfers_or_rounds_wedge_pos() {
  translate([0, 0, (body_len/2 - end_chamfer/2)])
    rotate([0, 45, 0])
      cube([body_w + 2*overlap, body_t + 2*overlap, end_chamfer*2], center=true);
}

module end_chamfers_or_rounds_wedge_neg() {
  translate([0, 0, -(body_len/2 - end_chamfer/2)])
    rotate([0, -45, 0])
      cube([body_w + 2*overlap, body_t + 2*overlap, end_chamfer*2], center=true);
}

// Midsection faceted steps
module midsection_faceted_steps_seg1() {
  translate([0, curve_sag, -facet_z])
    cube([body_w - 2*corner_r, body_t - 2*corner_r, facet_z], center=true);
}

module midsection_faceted_steps_seg2() {
  translate([0, curve_sag/2, 0])
    cube([body_w - 2*corner_r, body_t - 2*corner_r, facet_z], center=true);
}

module midsection_faceted_steps_seg3() {
  translate([0, curve_sag, facet_z])
    cube([body_w - 2*corner_r, body_t - 2*corner_r, facet_z], center=true);
}

// Main body with edge fillets
module main_body_with_edge_fillets() {
  minkowski() {
    main_strap_body();
    edge_fillets_sphere();
  }
}

// Reinforcement with edge fillets
module reinforcement_with_edge_fillets() {
  minkowski() {
    central_thickened_reinforcement();
    edge_fillets_sphere();
  }
}

// Overall curvature
module overall_curvature() {
  hull() {
    midsection_faceted_steps_seg1();
    midsection_faceted_steps_seg2();
    midsection_faceted_steps_seg3();
  }
}

// Final model
module final_model() {
  difference() {
    union() {
      union() {
        main_body_with_edge_fillets();
        overall_curvature();
      }
      reinforcement_with_edge_fillets();
    }
    window_cutout_1();
    window_cutout_2();
    cosmetic_bevels_on_windows_1();
    cosmetic_bevels_on_windows_2();
    end_hole_1();
    end_hole_2();
    end_chamfers_or_rounds_wedge_pos();
    end_chamfers_or_rounds_wedge_neg();
  }
}

// Render the final model
color("Silver") final_model();