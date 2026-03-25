// Parameters
bbox_x = 0.01; //[0.005:0.02:0.0001]
bbox_y = 0.01; //[0.005:0.02:0.0001]
bbox_z = 0.03; //[0.015:0.06:0.0001]
main_D = 0.01; //[0.005:0.02:0.0001]
main_H = 0.022; //[0.011:0.044:0.0001]
boss_D = 0.006; //[0.003:0.012:0.0001]
boss_H = 0.008; //[0.004:0.016:0.0001]
hole_square_W = 0.003; //[0.0015:0.006:0.0001]
rim_amp = 0.0006; //[0.0003:0.0012:0.00001]
rim_teeth = 12; //[6:24:1]
facet_sides = 8; //[6:16:1]
shoulder_H = 0.002; //[0.001:0.004:0.0001]
overlap = 0.0005; //[0.0002:0.001:0.0001]
chamfer_H = 0.0006; //[0.0003:0.0012:0.00001]
fillet_r = 0.0004; //[0.0002:0.0008:0.00001]
knurl_depth = 0.00025; //[0.0001:0.0005:0.00001]
knurl_count = 12; //[6:24:1]

// Base Shapes
module main_barrel() {
  cylinder(h=main_H, r=main_D/2, center=true);
}

module coaxial_boss() {
  translate([0, 0, main_H/2 + boss_H/2 - overlap])
    cylinder(h=boss_H, r=boss_D/2, center=true);
}

module rounded_shoulder_transition() {
  translate([0, 0, main_H/2 - shoulder_H/2 + overlap])
    cylinder(h=shoulder_H, r1=main_D/2, r2=boss_D/2, center=true);
}

module scalloped_outer_rim() {
  rotate_extrude($fn=rim_teeth)
    translate([main_D/2 - rim_amp, 0, -main_H/2 + rim_amp])
      circle(r=rim_amp);
}

module faceted_sides() {
  rotate([0, 0, 360/facet_sides/2])
    for (i = [0:facet_sides-1])
      rotate([0, 0, i*360/facet_sides])
        translate([main_D*0.92/2, 0, 0])
          cube([main_D*0.92, main_D*0.92, main_H], center=true);
}

module edge_chamfers_top_cut() {
  translate([0, 0, main_H/2 - chamfer_H/2])
    cylinder(h=chamfer_H, r1=main_D/2 + overlap, r2=main_D/2 - chamfer_H, center=true);
}

module edge_chamfers_bottom_cut() {
  translate([0, 0, -main_H/2 + chamfer_H/2])
    cylinder(h=chamfer_H, r1=main_D/2 - chamfer_H, r2=main_D/2 + overlap, center=true);
}

module decorative_knurl_texture_groove_x() {
  for (i = [0:knurl_count-1])
    rotate([0, 0, i*360/knurl_count])
      translate([0, main_D/2 + overlap, 0])
        cube([main_D + 2*overlap, knurl_depth, main_H*0.7], center=true);
}

module decorative_knurl_texture_groove_y() {
  for (i = [0:knurl_count-1])
    rotate([0, 0, i*360/knurl_count])
      translate([main_D/2 + overlap, 0, 0])
        cube([knurl_depth, main_D + 2*overlap, main_H*0.7], center=true);
}

module central_square_through_hole() {
  cube([hole_square_W, hole_square_W, bbox_z + 2*overlap], center=true);
}

module micro_fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Operations
module main_plus_boss() {
  union() {
    main_barrel();
    coaxial_boss();
    rounded_shoulder_transition();
  }
}

module add_scalloped_outer_rim() {
  union() {
    main_plus_boss();
    scalloped_outer_rim();
  }
}

module apply_faceted_sides_intersection() {
  intersection() {
    add_scalloped_outer_rim();
    faceted_sides();
  }
}

module apply_edge_chamfers() {
  difference() {
    apply_faceted_sides_intersection();
    edge_chamfers_top_cut();
    edge_chamfers_bottom_cut();
  }
}

module apply_decorative_knurl_texture() {
  difference() {
    apply_edge_chamfers();
    decorative_knurl_texture_groove_x();
    decorative_knurl_texture_groove_y();
  }
}

module apply_micro_fillet_details() {
  minkowski() {
    apply_decorative_knurl_texture();
    micro_fillet_sphere();
  }
}

module subtract_central_square_through_hole() {
  difference() {
    apply_micro_fillet_details();
    central_square_through_hole();
  }
}

// Final Output
subtract_central_square_through_hole();