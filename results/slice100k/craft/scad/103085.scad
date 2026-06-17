// Parameters
L = 55.44; //[27.72:110.88:0.01]
W = 31.55; //[15.78:63.1:0.01]
H = 37.52; //[18.76:75.04:0.01]
beam_h = 12.0; //[6.0:24.0:0.1]
beam_w = 18.0; //[9.0:31.55:0.1]
end_plate_t = 8.0; //[4.0:16.0:0.1]
end_plate_h = 37.52; //[18.76:37.52:0.01]
leg_t = 8.0; //[4.0:16.0:0.1]
leg_h = 20.0; //[10.0:37.52:0.1]
hex_flat = 10.0; //[5.0:20.0:0.1]
hex_axis_h = 40.0; //[20.0:80.0:0.1]
hex_center_x = 27.72; //[0.0:55.44:0.01]
hex_center_y = 15.775; //[0.0:31.55:0.001]
hex_center_z = 6.0; //[0.0:37.52:0.1]
top_slope_drop = 10.0; //[5.0:20.0:0.1]
top_slope_run = 16.0; //[8.0:32.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
fillet_r = 1.2; //[0.6:2.4:0.1]
small_chamfer = 0.8; //[0.4:1.6:0.1]

// Base Shapes
module horizontal_beam() {
  translate([0, 0, -H/2 + beam_h/2])
    cube([L, beam_w, beam_h], center=true);
}

module tall_vertical_end_plate() {
  translate([-L/2 + end_plate_t/2, 0, 0])
    cube([end_plate_t, W, end_plate_h], center=true);
}

module short_vertical_support_leg() {
  translate([L/2 - leg_t/2, 0, -H/2 + leg_h/2])
    cube([leg_t, W, leg_h], center=true);
}

module end_plate_top_chamfer_slope() {
  rotate([0, atan(top_slope_drop/top_slope_run), 0])
    translate([-L/2 + top_slope_run/2 - overlap, 0, H/2 - top_slope_drop/2 + overlap])
      cube([top_slope_run, W + 2*overlap, top_slope_drop], center=true);
}

module through_hex_hole() {
  translate([-L/2 + hex_center_x, -W/2 + hex_center_y, -H/2 + hex_center_z])
    linear_extrude(height=hex_axis_h, center=true)
      polygon(points=[
        [hex_flat/sqrt(3), 0],
        [hex_flat/(2*sqrt(3)), hex_flat/2],
        [-hex_flat/(2*sqrt(3)), hex_flat/2],
        [-hex_flat/sqrt(3), 0],
        [-hex_flat/(2*sqrt(3)), -hex_flat/2],
        [hex_flat/(2*sqrt(3)), -hex_flat/2]
      ]);
}

module small_chamfers_on_external_edges() {
  translate([0, 0, H/2 - small_chamfer/2 + overlap])
    cube([L + 2*overlap, W + 2*overlap, small_chamfer], center=true);
}

module mounting_holes_other_than_hex() {
  translate([L/2 - leg_t/2, 0, -H/2 + beam_h/2])
    rotate([90, 0, 0])
      cylinder(r=2.0, h=W + 2*overlap, center=true);
}

module edge_fillets() {
  sphere(r=fillet_r, center=true);
}

// Operations
module union_main_solids() {
  union() {
    horizontal_beam();
    tall_vertical_end_plate();
    short_vertical_support_leg();
  }
}

module difference_end_plate_slope() {
  difference() {
    union_main_solids();
    end_plate_top_chamfer_slope();
  }
}

module difference_hex_hole() {
  difference() {
    difference_end_plate_slope();
    through_hex_hole();
  }
}

module difference_other_mounting_hole() {
  difference() {
    difference_hex_hole();
    mounting_holes_other_than_hex();
  }
}

module difference_small_chamfers() {
  difference() {
    difference_other_mounting_hole();
    small_chamfers_on_external_edges();
  }
}

module minkowski_edge_fillets() {
  minkowski() {
    difference_small_chamfers();
    edge_fillets();
  }
}

// Final Output
minkowski_edge_fillets();