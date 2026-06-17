// Parameters
bbox_x = 60; //[30:120:0.01]
bbox_y = 59.56; //[29.78:119.12:0.01]
thickness_z = 11.8; //[5.9:23.6:0.01]
outer_rx = 30; //[15:60:0.01]
outer_ry = 29.78; //[14.89:59.56:0.01]
bore_d = 40; //[20:55:0.01]
notch_count = 6; //[3:24:1]
notch_depth_radial = 3; //[1.5:6:0.01]
notch_width_tangential = 6; //[3:12:0.01]
notch_overlap = 1; //[0.5:2:0.01]
chamfer_size = 0.6; //[0:2:0.01]
fillet_r = 0.8; //[0:3:0.01]
lead_in_bevel = 0.6; //[0:2:0.01]
eps = 0.2; //[0.05:0.5:0.01]

// Base Shapes
module outer_oval_cyl() {
  scale([1, outer_ry/outer_rx, 1])
    cylinder(r=outer_rx, h=thickness_z, center=true);
}

module outer_bbox_limit() {
  cube([bbox_x, bbox_y, thickness_z], center=true);
}

module central_through_bore() {
  cylinder(r=bore_d/2, h=thickness_z + 2*eps, center=true);
}

module notch_cutter_base() {
  translate([bore_d/2 + (notch_depth_radial + notch_overlap)/2 - notch_overlap, 0, 0])
    cube([notch_depth_radial + notch_overlap, notch_width_tangential, thickness_z + 2*eps], center=true);
}

module notch_bevel_wedge() {
  translate([bore_d/2 + lead_in_bevel/2, 0, thickness_z/2 - lead_in_bevel/2])
    rotate([0, 90, 0])
      cylinder(r1=lead_in_bevel, r2=0, h=notch_width_tangential, center=true);
}

module edge_chamfer_top_outer() {
  translate([0, 0, thickness_z/2 - chamfer_size/2])
    rotate([90, 0, 0])
      cylinder(r1=chamfer_size, r2=0, h=bbox_x, center=true);
}

module edge_chamfer_bottom_outer() {
  translate([0, 0, -thickness_z/2 + chamfer_size/2])
    rotate([90, 0, 0])
      cylinder(r1=chamfer_size, r2=0, h=bbox_x, center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r);
}

// Operations
module outer_profile_bounded() {
  intersection() {
    outer_oval_cyl();
    outer_bbox_limit();
  }
}

module outer_annulus_body() {
  difference() {
    outer_profile_bounded();
    central_through_bore();
  }
}

module inner_notch_cutters() {
  union() {
    for (i = [0:notch_count-1]) {
      rotate([0, 0, i*360/notch_count])
        notch_cutter_base();
    }
  }
}

module notch_bevel_cutters() {
  union() {
    for (i = [0:notch_count-1]) {
      rotate([0, 0, i*360/notch_count])
        notch_bevel_wedge();
    }
  }
}

module ring_with_notches() {
  difference() {
    outer_annulus_body();
    inner_notch_cutters();
    notch_bevel_cutters();
  }
}

module ring_with_chamfers() {
  difference() {
    ring_with_notches();
    edge_chamfer_top_outer();
    edge_chamfer_bottom_outer();
  }
}

// Final Output
minkowski() {
  ring_with_chamfers();
  fillet_sphere();
}