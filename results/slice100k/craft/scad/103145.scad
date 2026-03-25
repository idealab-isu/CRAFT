// Dimension-calibrated (target: 60.00 x 60.56 x 11.80 mm)
scale([0.938580, 0.986638, 0.829534])
{
// Parameters
bbox_x = 60.0; //[30.0:120.0:0.1]
bbox_y = 60.56; //[30.28:121.12:0.1]
thickness_z = 11.8; //[5.9:23.6:0.1]
outer_diam_x = 60.0; //[30.0:120.0:0.1]
outer_diam_y = 60.56; //[30.28:121.12:0.1]
inner_diam = 40.0; //[20.0:80.0:0.1]
notch_count = 8; //[3:24:1]
notch_width_tangential = 6.0; //[3.0:12.0:0.1]
notch_depth_radial = 3.0; //[1.0:8.0:0.1]
tab_count = 2; //[2:2:1]
tab_length_radial = 2.5; //[1.0:6.0:0.1]
tab_width_tangential = 6.0; //[3.0:14.0:0.1]
tab_angular_span_deg = 30.0; //[10.0:90.0:1]
overlap = 1.0; //[0.5:2.0:0.1]
outer_round_r = 0.6; //[0.0:2.0:0.1]
notch_relief_r = 0.8; //[0.0:2.5:0.1]
tab_round_r = 0.8; //[0.0:2.5:0.1]
outer_radius = 30.0; //[15.0:60.0:0.1]
inner_radius = 20.0; //[10.0:40.0:0.1]
tab_angle_sep_deg = 12.0; //[2.0:40.0:1]

// Base shapes
module annular_ring_body_outer() {
  cylinder(r=outer_radius, h=thickness_z, center=true);
}

module central_circular_opening() {
  cylinder(r=inner_radius, h=thickness_z + 2*overlap, center=true);
}

module notch_cutter_base() {
  translate([inner_radius + (notch_depth_radial + overlap)/2 - overlap, 0, 0])
    cube([notch_depth_radial + overlap, notch_width_tangential, thickness_z + 2*overlap], center=true);
}

module notch_relief_cyl_base() {
  translate([inner_radius + notch_depth_radial - overlap, notch_width_tangential/2, 0])
    cylinder(r=notch_relief_r, h=thickness_z + 2*overlap, center=true);
}

module tab_base_box() {
  translate([outer_radius + (tab_length_radial + overlap)/2 - overlap, 0, 0])
    cube([tab_length_radial + overlap, tab_width_tangential, thickness_z], center=true);
}

module tab_round_sphere() {
  sphere(r=tab_round_r, center=true);
}

module edge_round_sphere() {
  sphere(r=outer_round_r, center=true);
}

// Operations
module annular_ring_body() {
  difference() {
    annular_ring_body_outer();
    central_circular_opening();
  }
}

module inner_diameter_rectangular_notches() {
  union() {
    for (i = [0:notch_count-1]) {
      rotate([0, 0, i*360/notch_count])
        notch_cutter_base();
    }
  }
}

module notch_corner_reliefs() {
  union() {
    for (i = [0:notch_count-1]) {
      rotate([0, 0, i*360/notch_count]) {
        notch_relief_cyl_base();
        mirror([0, 1, 0])
          notch_relief_cyl_base();
      }
    }
  }
}

module ring_with_notches() {
  difference() {
    annular_ring_body();
    inner_diameter_rectangular_notches();
    notch_corner_reliefs();
  }
}

module outer_rim_key_tabs_pair_raw() {
  union() {
    rotate([0, 0, -tab_angle_sep_deg/2])
      tab_base_box();
    rotate([0, 0, tab_angle_sep_deg/2])
      tab_base_box();
  }
}

module tab_rounding() {
  minkowski() {
    outer_rim_key_tabs_pair_raw();
    tab_round_sphere();
  }
}

module ring_with_tabs() {
  union() {
    ring_with_notches();
    tab_rounding();
  }
}

module edge_chamfers_or_fillets() {
  minkowski() {
    ring_with_tabs();
    edge_round_sphere();
  }
}

// Final output
edge_chamfers_or_fillets();
}
