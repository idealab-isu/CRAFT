// Parameters
bbox_x = 60.0; //[30.0:120.0:0.1]
bbox_y = 60.56; //[30.28:121.12:0.1]
thickness_z = 11.8; //[5.9:23.6:0.1]
outer_diameter_x = 60.0; //[30.0:120.0:0.1]
outer_diameter_y = 60.56; //[30.28:121.12:0.1]
inner_diameter = 40.0; //[20.0:80.0:0.1]
notch_count = 8; //[3:24:1]
notch_width_tangential = 6.0; //[2.0:12.0:0.1]
notch_depth_radial = 3.0; //[1.0:8.0:0.1]
tab_count = 2; //[1:2:1]
tab_width_tangential = 6.0; //[2.0:14.0:0.1]
tab_radial_extension = 2.0; //[0.5:6.0:0.1]
tab_gap_tangential = 2.0; //[0.5:10.0:0.1]
tab_angle_center_deg = 0.0; //[-180.0:180.0:1.0]
overlap = 1.0; //[0.5:2.0:0.1]
edge_chamfer = 0.6; //[0.0:2.0:0.1]
tab_rounding_radius = 0.8; //[0.0:3.0:0.1]

// Base Shapes
module annular_ring_body_outer_cyl() {
  cylinder(r=outer_diameter_x/2, h=thickness_z, center=true);
}

module central_through_bore_cyl() {
  cylinder(r=inner_diameter/2, h=thickness_z + 2*overlap, center=true);
}

module notch_cut_box_base() {
  translate([inner_diameter/2 + (notch_depth_radial + overlap)/2 - overlap, 0, 0])
    cube([notch_depth_radial + overlap, notch_width_tangential, thickness_z + 2*overlap], center=true);
}

module tab1_box_base() {
  translate([outer_diameter_x/2 + (tab_radial_extension + overlap)/2 - overlap, (tab_gap_tangential/2 + tab_width_tangential/2), 0])
    cube([tab_radial_extension + overlap, tab_width_tangential, thickness_z], center=true);
}

module tab2_box_base() {
  translate([outer_diameter_x/2 + (tab_radial_extension + overlap)/2 - overlap, -(tab_gap_tangential/2 + tab_width_tangential/2), 0])
    cube([tab_radial_extension + overlap, tab_width_tangential, thickness_z], center=true);
}

module edge_chamfers_or_fillets_sphere() {
  sphere(r=edge_chamfer, center=true);
}

module tab_rounding_sphere() {
  sphere(r=tab_rounding_radius, center=true);
}

// Operations
module annular_ring_body() {
  difference() {
    annular_ring_body_outer_cyl();
    central_through_bore_cyl();
  }
}

module inner_diameter_rectangular_notches_array() {
  union() {
    for (i = [0:notch_count-1]) {
      rotate([0, 0, i*360/notch_count])
        notch_cut_box_base();
    }
  }
}

module annular_ring_with_notches() {
  difference() {
    annular_ring_body();
    inner_diameter_rectangular_notches_array();
  }
}

module outer_rim_key_tabs_pair_unrot() {
  union() {
    tab1_box_base();
    tab2_box_base();
  }
}

module outer_rim_key_tabs_pair() {
  rotate([0, 0, tab_angle_center_deg])
    outer_rim_key_tabs_pair_unrot();
}

module tab_rounding() {
  minkowski() {
    outer_rim_key_tabs_pair();
    tab_rounding_sphere();
  }
}

module ring_with_tabs() {
  union() {
    annular_ring_with_notches();
    tab_rounding();
  }
}

module edge_chamfers_or_fillets() {
  minkowski() {
    ring_with_tabs();
    edge_chamfers_or_fillets_sphere();
  }
}

// Final Output
edge_chamfers_or_fillets();