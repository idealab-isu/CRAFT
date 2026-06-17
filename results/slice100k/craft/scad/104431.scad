// Parameters
bbox_x = 0.8; //[0.4:1.6:0.01]
bbox_y = 0.8; //[0.4:1.6:0.01]
bbox_z = 2.0; //[1.0:4.0:0.01]
mid_w = 0.8; //[0.4:1.6:0.01]
end_w = 0.72; //[0.36:1.44:0.01]
chamfer = 0.06; //[0.02:0.12:0.005]
taper_h = 0.4; //[0.2:0.8:0.01]
overlap = 0.01; //[0.005:0.05:0.005]
panel_inset = 0.02; //[0.005:0.06:0.005]
panel_margin = 0.12; //[0.06:0.24:0.005]
micro_fillet_r = 0.01; //[0.005:0.03:0.001]
texture_amp = 0.003; //[0.0:0.02:0.001]

// Base Shapes
module main_prismatic_body_mid() {
  cube([mid_w, mid_w, bbox_z - 2 * taper_h], center = true);
}

module top_taper_zone() {
  translate([0, 0, (bbox_z / 2 - taper_h / 2) - overlap])
    cylinder(h = taper_h, r1 = mid_w / 2, r2 = end_w / 2, center = true);
}

module bottom_taper_zone() {
  translate([0, 0, (-bbox_z / 2 + taper_h / 2) + overlap])
    cylinder(h = taper_h, r1 = end_w / 2, r2 = mid_w / 2, center = true);
}

module vertical_edge_chamfers() {
  cube([mid_w - 2 * chamfer, mid_w - 2 * chamfer, bbox_z + 2 * overlap], center = true);
}

module subtle_inset_panel_effect() {
  cube([mid_w - 2 * panel_margin, mid_w - 2 * panel_margin, bbox_z - 2 * panel_margin], center = true);
}

module micro_fillet_edges() {
  sphere(r = micro_fillet_r, center = true);
}

module surface_texture() {
  sphere(r = texture_amp, center = true);
}

// Operations
module mid_bulge_taper_profile() {
  union() {
    main_prismatic_body_mid();
    top_taper_zone();
    bottom_taper_zone();
  }
}

module chamfered_body() {
  intersection() {
    mid_bulge_taper_profile();
    vertical_edge_chamfers();
  }
}

module inset_panel_body() {
  difference() {
    chamfered_body();
    translate([0, 0, 0]) subtle_inset_panel_effect();
  }
}

// Final Output
module final_with_surface_texture() {
  minkowski() {
    minkowski() {
      inset_panel_body();
      micro_fillet_edges();
    }
    surface_texture();
  }
}

// Render the final output
final_with_surface_texture();