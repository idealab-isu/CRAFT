// Parameters
rail_L = 100; //[50:200:1]
rail_W = 7; //[3.5:14:0.1]
rail_H = 5; //[2.5:10:0.1]
hole_d = 2; //[1:4:0.1]
hole_pitch = 20; //[10:40:1]
hole_edge_offset = 10; //[5:20:1]
hole_count = 5; //[2:9:1]
overlap = 1; //[0.5:2:0.1]
chamfer_edge = 0.6; //[0.3:1.2:0.1]
chamfer_end = 0.8; //[0.4:1.6:0.1]
carriage_L = 18; //[10:36:1]
carriage_W = 12; //[8:24:1]
carriage_H = 8; //[5:16:1]
carriage_clearance = 0.2; //[0.1:0.6:0.05]

// Rail Body
module rail_body() {
  color("Silver")
  cube([rail_L, rail_W, rail_H], center=true);
}

// Mounting Holes
module mounting_hole(pos) {
  translate(pos)
    cylinder(h=rail_H + 2*overlap, r=hole_d/2, center=true);
}

module mounting_holes_pattern() {
  union() {
    for (i = [0:hole_count-1]) {
      mounting_hole([-rail_L/2 + hole_edge_offset + i*hole_pitch, 0, 0]);
    }
  }
}

// Edge Chamfers
module edge_chamfer_wedge_y_pos() {
  translate([0, rail_W/2 - chamfer_edge/2 + overlap/2, rail_H/2 - chamfer_edge/2 + overlap/2])
    rotate([45, 0, 0])
    cube([rail_L + 2*overlap, chamfer_edge, chamfer_edge], center=true);
}

module edge_chamfer_wedge_y_neg() {
  translate([0, -rail_W/2 + chamfer_edge/2 - overlap/2, rail_H/2 - chamfer_edge/2 + overlap/2])
    rotate([45, 0, 0])
    cube([rail_L + 2*overlap, chamfer_edge, chamfer_edge], center=true);
}

module edge_chamfers() {
  union() {
    edge_chamfer_wedge_y_pos();
    edge_chamfer_wedge_y_neg();
  }
}

// End Chamfers
module end_chamfer_wedge_x_pos() {
  translate([rail_L/2 - chamfer_end/2 + overlap/2, 0, rail_H/2 - chamfer_end/2 + overlap/2])
    rotate([0, 45, 0])
    cube([chamfer_end, rail_W + 2*overlap, chamfer_end], center=true);
}

module end_chamfer_wedge_x_neg() {
  translate([-rail_L/2 + chamfer_end/2 - overlap/2, 0, rail_H/2 - chamfer_end/2 + overlap/2])
    rotate([0, 45, 0])
    cube([chamfer_end, rail_W + 2*overlap, chamfer_end], center=true);
}

module end_chamfers() {
  union() {
    end_chamfer_wedge_x_pos();
    end_chamfer_wedge_x_neg();
  }
}

// Carriage Block Placeholder
module carriage_block_placeholder() {
  color("DimGray")
  translate([0, 0, rail_H/2 + carriage_H/2 - overlap])
    cube([carriage_L, carriage_W, carriage_H], center=true);
}

// Complete Model
module complete_model() {
  difference() {
    difference() {
      difference() {
        rail_body();
        mounting_holes_pattern();
      }
      edge_chamfers();
    }
    end_chamfers();
  }
  carriage_block_placeholder();
}

// Final Output
complete_model();