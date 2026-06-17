// Parameters
across_flats = 7.0; //[3.5:14.0:0.1]
thickness = 2.2; //[1.1:4.4:0.1]
hole_diameter = 4.0; //[2.0:8.0:0.1]
chamfer_size = 0.3; //[0.1:0.8:0.05]
overlap = 0.6; //[0.2:1.5:0.1]
hex_circumradius = 4.041; //[2.0:8.5:0.001]
thread_major_diameter = 4.0; //[2.0:8.0:0.1]
thread_minor_diameter = 3.4; //[1.6:7.0:0.1]
thread_pitch = 0.7; //[0.4:1.5:0.05]
thread_groove_depth = 0.25; //[0.1:0.6:0.05]
thread_groove_width = 0.35; //[0.15:0.8:0.05]
thread_groove_count = 3; //[1:8:1]
marking_radius = 0.35; //[0.15:0.8:0.05]
marking_depth = 0.15; //[0.05:0.4:0.05]
fillet_radius = 0.2; //[0.05:0.6:0.05]

// Hexagonal Nut Body
module hex_nut_body() {
  linear_extrude(height = thickness, center = true) {
    polygon(points = [
      [hex_circumradius, 0],
      [hex_circumradius / 2, hex_circumradius * 0.8660254038],
      [-hex_circumradius / 2, hex_circumradius * 0.8660254038],
      [-hex_circumradius, 0],
      [-hex_circumradius / 2, -hex_circumradius * 0.8660254038],
      [hex_circumradius / 2, -hex_circumradius * 0.8660254038]
    ]);
  }
}

// Through Hole
module through_hole() {
  cylinder(r = hole_diameter / 2, h = thickness + 2 * overlap, center = true);
}

// Edge Chamfers
module edge_chamfers() {
  union() {
    translate([0, 0, thickness / 2 - chamfer_size / 2 + overlap / 2])
      cylinder(r1 = hex_circumradius + overlap, r2 = 0, h = chamfer_size, center = true);
    translate([0, 0, -thickness / 2 + chamfer_size / 2 - overlap / 2])
      rotate([180, 0, 0])
      cylinder(r1 = hex_circumradius + overlap, r2 = 0, h = chamfer_size, center = true);
  }
}

// Thread Groove Unit
module thread_groove_unit() {
  rotate_extrude() translate([thread_major_diameter / 2 - thread_groove_depth, 0, 0])
    circle(r = thread_groove_depth);
}

// Thread Groove Cutter
module thread_groove_cutter(z_offset) {
  translate([thread_major_diameter / 2 - thread_groove_depth, 0, z_offset])
    cube([thread_groove_width, thread_major_diameter + 2 * thread_groove_depth + 2 * overlap, thread_groove_width], center = true);
}

// Thread Detail
module thread_detail() {
  union() {
    for (i = [0:thread_groove_count-1]) {
      translate([0, 0, -((thread_groove_count-1) * thread_pitch / 2) + i * thread_pitch])
        difference() {
          thread_groove_unit();
          thread_groove_cutter(0);
        }
    }
  }
}

// Surface Marking
module surface_marking() {
  translate([hex_circumradius * 0.55, 0, thickness / 2 - marking_depth + overlap / 2])
    sphere(r = marking_radius, center = true);
}

// Fillet Kernel
module fillet_kernel() {
  sphere(r = fillet_radius, center = true);
}

// Final Nut with Features
module nut_with_features() {
  difference() {
    hex_nut_body();
    through_hole();
    edge_chamfers();
    thread_detail();
    surface_marking();
  }
}

// Final Output with Fillets
minkowski() {
  nut_with_features();
  fillet_kernel();
}