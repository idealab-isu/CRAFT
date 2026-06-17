// Parameters
across_flats = 6.0; //[3.0:12.0:0.1]
thickness = 2.75; //[1.4:5.5:0.05]
screw_diameter = 3.0; //[2.0:6.0:0.1]
hole_diameter = 3.2; //[2.6:4.5:0.05]
t_slot_width = 8.0; //[4.0:16.0:0.1]
t_slot_neck_width = 5.0; //[2.5:10.0:0.1]
t_slot_depth = 1.5; //[0.8:3.0:0.05]
chamfer = 0.3; //[0.1:1.0:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
hex_radius = 3.464; //[1.732:6.928:0.001]
t_slot_length = 12.0; //[6.0:24.0:0.5]
serration_pitch = 1.2; //[0.6:2.4:0.1]
serration_depth = 0.4; //[0.2:1.0:0.05]

// Hexagonal nut body
module nut_body() {
  linear_extrude(height = thickness, center = true) {
    polygon(points = [
      [hex_radius, 0],
      [hex_radius / 2, hex_radius * 0.8660254],
      [-hex_radius / 2, hex_radius * 0.8660254],
      [-hex_radius, 0],
      [-hex_radius / 2, -hex_radius * 0.8660254],
      [hex_radius / 2, -hex_radius * 0.8660254]
    ]);
  }
}

// T-slot profile
module t_slot_profile() {
  translate([0, 0, -thickness / 2 + t_slot_depth / 2 - overlap])
    cube([t_slot_width, t_slot_length, t_slot_depth], center = true);
}

// Center hole
module center_hole() {
  cylinder(r = hole_diameter / 2, h = thickness + 2 * overlap, center = true);
}

// Lead-in chamfers
module lead_in_chamfers() {
  translate([0, 0, thickness / 2 - chamfer])
    rotate([180, 0, 0])
    cylinder(r1 = hole_diameter / 2 + chamfer, r2 = 0, h = 2 * chamfer, center = true);
}

module lead_in_chamfers_bottom() {
  translate([0, 0, -thickness / 2 + chamfer])
    cylinder(r1 = hole_diameter / 2 + chamfer, r2 = 0, h = 2 * chamfer, center = true);
}

// Fillets (edge relief)
module fillets() {
  sphere(r = chamfer, center = true);
}

// Knurling or serrations
module knurling_or_serrations() {
  cube([t_slot_width + 2 * overlap, serration_pitch, serration_depth], center = true);
}

// Engraved size marking
module engraved_size_marking() {
  translate([0, 0, thickness / 2 - chamfer / 2])
    cube([across_flats / 2, across_flats / 3, chamfer], center = true);
}

// Assemble the T-slot nut
module t_slot_nut() {
  difference() {
    minkowski() {
      union() {
        nut_body();
        t_slot_profile();
      }
      fillets();
    }
    center_hole();
    lead_in_chamfers();
    lead_in_chamfers_bottom();
    union() {
      for (i = [-2:2]) {
        translate([0, i * serration_pitch, 0])
          knurling_or_serrations();
      }
    }
    engraved_size_marking();
  }
}

// Final output
t_slot_nut();