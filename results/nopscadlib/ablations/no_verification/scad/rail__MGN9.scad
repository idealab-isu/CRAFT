// Parameters
rail_W = 9; //[4.5:18:0.5]
rail_H = 6; //[3:12:0.5]
rail_L = 100; //[50:200:1]
hole_d = 3; //[1.5:6:0.1]
hole_pitch = 25; //[12.5:50:0.5]
hole_edge_offset = 12.5; //[6.25:25:0.5]
hole_count = 4; //[2:8:1]
csk_d = 6; //[3:12:0.1]
csk_angle = 90; //[60:120:1]
overlap = 1; //[0.5:2:0.1]
chamfer_len = 1; //[0.5:2:0.1]
fillet_r = 0.6; //[0.3:1.2:0.05]
mark_depth = 0.2; //[0.1:0.6:0.05]
mark_W = 0.8; //[0.4:1.6:0.05]
mark_L = 6; //[3:12:0.5]
mark_offset_from_end = 8; //[4:16:0.5]

// Rail Body
module rail_body() {
  color("Silver")
  translate([0, 0, 0])
    cube([rail_W, rail_L, rail_H], center=true);
}

// Mounting Holes and Countersinks
module mounting_holes_pattern() {
  for (i = [0:hole_count-1]) {
    translate([0, -rail_L/2 + hole_edge_offset + i*hole_pitch, 0])
      cylinder(h=rail_H + 2*overlap, r=hole_d/2, center=true);
    translate([0, -rail_L/2 + hole_edge_offset + i*hole_pitch, rail_H/2 - ((csk_d - hole_d) / (2*tan((csk_angle/2)*pi/180)) + overlap)/2 + overlap/2])
      cylinder(h=(csk_d - hole_d) / (2*tan((csk_angle/2)*pi/180)) + overlap, r1=csk_d/2, r2=hole_d/2, center=true);
  }
}

// End Chamfers
module end_chamfers() {
  union() {
    translate([0, rail_L/2 - chamfer_len/2 + overlap/2, 0])
      rotate([0, 0, 45])
        cube([rail_W + 2*overlap, chamfer_len, rail_H + 2*overlap], center=true);
    translate([0, -rail_L/2 + chamfer_len/2 - overlap/2, 0])
      rotate([0, 0, 45])
        cube([rail_W + 2*overlap, chamfer_len, rail_H + 2*overlap], center=true);
  }
}

// Engraved Markings
module engraved_markings() {
  union() {
    translate([0, -rail_L/2 + mark_offset_from_end, rail_H/2 - (mark_depth + overlap)/2 + overlap/2])
      cube([mark_W, mark_L, mark_depth + overlap], center=true);
    translate([0, rail_L/2 - mark_offset_from_end, rail_H/2 - (mark_depth + overlap)/2 + overlap/2])
      cube([mark_W, mark_L, mark_depth + overlap], center=true);
  }
}

// Edge Fillets
module edge_fillets() {
  minkowski() {
    difference() {
      rail_body();
      mounting_holes_pattern();
      end_chamfers();
      engraved_markings();
    }
    sphere(r=fillet_r, center=true);
  }
}

// Complete Model
module complete_model() {
  edge_fillets();
}

// Render the final model
complete_model();