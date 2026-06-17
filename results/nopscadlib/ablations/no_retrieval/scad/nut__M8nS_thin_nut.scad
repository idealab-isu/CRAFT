// Parameters
across_flats = 13.0; //[6.5:26.0:0.1]
thickness = 4.0; //[2.0:8.0:0.1]
hole_diameter = 8.0; //[4.0:16.0:0.1]
chamfer_size = 0.5; //[0.2:1.5:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
hex_circumradius = 7.505; //[3.75:15.01:0.001]
thread_minor_diameter = 7.2; //[6.0:7.8:0.1]
thread_groove_depth = 0.25; //[0.1:0.6:0.05]
thread_groove_count = 6; //[3:12:1]
fillet_radius = 0.3; //[0.0:1.0:0.05]

// Hexagonal Nut Body
module hex_nut_body() {
  linear_extrude(height = thickness, center = true)
    polygon(points = [
      [hex_circumradius, 0],
      [hex_circumradius / 2, hex_circumradius * 0.8660254038],
      [-hex_circumradius / 2, hex_circumradius * 0.8660254038],
      [-hex_circumradius, 0],
      [-hex_circumradius / 2, -hex_circumradius * 0.8660254038],
      [hex_circumradius / 2, -hex_circumradius * 0.8660254038]
    ]);
}

// Through Hole
module through_hole() {
  cylinder(r = hole_diameter / 2, h = thickness + 2 * overlap, center = true);
}

// Edge Chamfers
module edge_chamfer_top() {
  translate([0, 0, thickness / 2 - chamfer_size / 2])
    cylinder(r1 = hex_circumradius + overlap, r2 = 0, h = chamfer_size, center = true);
}

module edge_chamfer_bottom() {
  translate([0, 0, -thickness / 2 + chamfer_size / 2])
    rotate([180, 0, 0])
    cylinder(r1 = hex_circumradius + overlap, r2 = 0, h = chamfer_size, center = true);
}

// Thread Detail Core
module thread_detail_core() {
  cylinder(r = thread_minor_diameter / 2, h = thickness + 2 * overlap, center = true);
}

// Thread Groove Cutter
module thread_groove_cutter() {
  rotate_extrude()
    translate([thread_minor_diameter / 2 - thread_groove_depth, 0, 0])
    circle(r = thread_groove_depth);
}

// Fillet Sphere
module fillet_sphere() {
  sphere(r = fillet_radius, center = true);
}

// Assemble Nut
module nut() {
  difference() {
    hex_nut_body();
    union() {
      edge_chamfer_top();
      edge_chamfer_bottom();
    }
    through_hole();
    difference() {
      thread_detail_core();
      for (i = [1:thread_groove_count]) {
        translate([0, 0, -thickness / 2 + thickness * (i / (thread_groove_count + 1))])
          thread_groove_cutter();
      }
    }
  }
}

// Final Output with Fillets
minkowski() {
  nut();
  if (fillet_radius > 0) {
    fillet_sphere();
  }
}