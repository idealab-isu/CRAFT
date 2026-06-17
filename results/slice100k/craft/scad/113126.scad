// Parameters
bbox_x = 31.8; //[15.9:63.6:0.1]
bbox_y = 31.8; //[15.9:63.6:0.1]
bbox_z = 15.8; //[7.9:31.6:0.1]
cutout_x = 22.0; //[11.0:44.0:0.1]
cutout_y = 24.0; //[12.0:48.0:0.1]
cutout_z = 12.0; //[6.0:24.0:0.1]
web_t = 4.9; //[2.45:9.8:0.1]
jaw_t = 3.9; //[1.95:7.8:0.1]
cutout_offset_x = 2.45; //[0.0:6.0:0.05]
lug_x = 4.0; //[2.0:8.0:0.1]
lug_y = 8.0; //[4.0:16.0:0.1]
lug_z = 3.0; //[1.5:6.0:0.1]
lug_offset_y = 0.0; //[-8.0:8.0:0.1]
lug_offset_z = 0.0; //[-4.0:4.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
relief_r = 1.2; //[0.6:2.4:0.1]
mount_hole_r = 1.6; //[0.8:3.2:0.1]
mount_hole_edge_margin = 5.0; //[2.5:10.0:0.1]
chamfer_r = 0.8; //[0.4:1.6:0.1]

// Base Shapes
module outer_block() {
  cube([bbox_x, bbox_y, bbox_z], center=true);
}

module internal_rectangular_cutout() {
  translate([cutout_offset_x, 0, 0])
    cube([cutout_x, cutout_y, cutout_z], center=true);
}

module internal_corner_relief_cyl(pos) {
  translate(pos)
    rotate([90, 0, 0])
      cylinder(r=relief_r, h=bbox_y + 2*overlap, center=true);
}

module protruding_lug_stop() {
  translate([bbox_x/2 + lug_x/2 - overlap, lug_offset_y, lug_offset_z])
    cube([lug_x, lug_y, lug_z], center=true);
}

module mounting_hole(pos) {
  translate(pos)
    cylinder(r=mount_hole_r, h=bbox_z + 2*overlap, center=true);
}

module edge_fillet_chamfer_sphere() {
  sphere(r=chamfer_r, center=true);
}

module jaw_mask_box() {
  cube([bbox_x + 2*overlap, bbox_y + 2*overlap, 2*jaw_t], center=true);
}

module web_mask_box() {
  translate([-bbox_x/2 + web_t/2, 0, 0])
    cube([web_t + 2*overlap, bbox_y + 2*overlap, bbox_z + 2*overlap], center=true);
}

// Operations
module internal_corner_relief_union() {
  union() {
    internal_corner_relief_cyl([cutout_offset_x + cutout_x/2, 0, cutout_z/2]);
    internal_corner_relief_cyl([cutout_offset_x + cutout_x/2, 0, -cutout_z/2]);
    internal_corner_relief_cyl([cutout_offset_x - cutout_x/2, 0, cutout_z/2]);
    internal_corner_relief_cyl([cutout_offset_x - cutout_x/2, 0, -cutout_z/2]);
  }
}

module cutout_with_relief() {
  union() {
    internal_rectangular_cutout();
    internal_corner_relief_union();
  }
}

module u_channel_jaws_side_web_raw() {
  difference() {
    outer_block();
    cutout_with_relief();
  }
}

module mounting_holes_union() {
  union() {
    mounting_hole([-bbox_x/2 + mount_hole_edge_margin, -bbox_y/2 + mount_hole_edge_margin, 0]);
    mounting_hole([-bbox_x/2 + mount_hole_edge_margin, bbox_y/2 - mount_hole_edge_margin, 0]);
    mounting_hole([bbox_x/2 - mount_hole_edge_margin, -bbox_y/2 + mount_hole_edge_margin, 0]);
    mounting_hole([bbox_x/2 - mount_hole_edge_margin, bbox_y/2 - mount_hole_edge_margin, 0]);
  }
}

module u_channel_jaws_side_web_with_holes() {
  difference() {
    u_channel_jaws_side_web_raw();
    mounting_holes_union();
  }
}

module u_channel_jaws() {
  intersection() {
    u_channel_jaws_side_web_with_holes();
    jaw_mask_box();
  }
}

module side_web() {
  intersection() {
    u_channel_jaws_side_web_with_holes();
    web_mask_box();
  }
}

module bracket_with_lug() {
  union() {
    u_channel_jaws_side_web_with_holes();
    protruding_lug_stop();
  }
}

// Final Output
minkowski() {
  bracket_with_lug();
  edge_fillet_chamfer_sphere();
}