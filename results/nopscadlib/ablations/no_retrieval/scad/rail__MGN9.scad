// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 9.0; //[4.5:18.0:0.1]
rail_H = 6.0; //[3.0:12.0:0.1]
hole_d = 3.0; //[1.5:6.0:0.1]
hole_pitch = 25.0; //[12.5:50.0:0.5]
hole_edge_offset = 12.5; //[6.0:25.0:0.5]
hole_count = 4; //[2:8:1]
csk_d = 5.5; //[3.5:11.0:0.1]
csk_angle = 90; //[60:120:1]
hole_cut_H = 8.0; //[6.0:20.0:0.5]
csk_depth = 1.5; //[0.5:3.0:0.1]
edge_chamfer = 0.6; //[0.2:1.5:0.1]
end_chamfer = 1.0; //[0.3:3.0:0.1]
fillet_r = 0.6; //[0.2:1.5:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module rail_body() {
  translate([0, 0, 0])
    cube([rail_L, rail_W, rail_H], center=true);
}

module hole_cyl(pos) {
  translate(pos)
    cylinder(h=hole_cut_H, r=hole_d/2, center=true);
}

module csk_cone(pos) {
  translate(pos)
    cylinder(h=csk_depth, r1=csk_d/2, r2=0, center=true);
}

module edge_chamfer_wedge(pos, rot) {
  translate(pos)
    rotate(rot)
      cube([rail_L + 2*overlap, edge_chamfer, edge_chamfer], center=true);
}

module end_chamfer_wedge(pos, rot) {
  translate(pos)
    rotate(rot)
      cube([end_chamfer, rail_W + 2*overlap, rail_H + 2*overlap], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r);
}

module engraved_markings() {
  translate([0, 0, rail_H/2 - rail_H/40])
    cube([rail_L/5, rail_W/3, rail_H/20], center=true);
}

// Operations
module mounting_holes_pattern() {
  union() {
    hole_cyl([-rail_L/2 + hole_edge_offset, 0, 0]);
    hole_cyl([-rail_L/2 + hole_edge_offset + hole_pitch, 0, 0]);
    hole_cyl([rail_L/2 - hole_edge_offset - hole_pitch, 0, 0]);
    hole_cyl([rail_L/2 - hole_edge_offset, 0, 0]);
    csk_cone([-rail_L/2 + hole_edge_offset, 0, rail_H/2 - csk_depth/2]);
    csk_cone([-rail_L/2 + hole_edge_offset + hole_pitch, 0, rail_H/2 - csk_depth/2]);
    csk_cone([rail_L/2 - hole_edge_offset - hole_pitch, 0, rail_H/2 - csk_depth/2]);
    csk_cone([rail_L/2 - hole_edge_offset, 0, rail_H/2 - csk_depth/2]);
  }
}

module edge_chamfers() {
  union() {
    edge_chamfer_wedge([0, rail_W/2 - edge_chamfer/2, rail_H/2 - edge_chamfer/2], [45, 0, 0]);
    edge_chamfer_wedge([0, -rail_W/2 + edge_chamfer/2, rail_H/2 - edge_chamfer/2], [-45, 0, 0]);
  }
}

module end_chamfers() {
  union() {
    end_chamfer_wedge([rail_L/2 - end_chamfer/2, 0, 0], [0, 45, 0]);
    end_chamfer_wedge([-rail_L/2 + end_chamfer/2, 0, 0], [0, -45, 0]);
  }
}

module corner_fillets() {
  minkowski() {
    rail_body();
    fillet_sphere();
  }
}

module rail_with_holes() {
  difference() {
    corner_fillets();
    mounting_holes_pattern();
  }
}

module rail_with_edge_chamfers() {
  difference() {
    rail_with_holes();
    edge_chamfers();
  }
}

module rail_with_end_chamfers() {
  difference() {
    rail_with_edge_chamfers();
    end_chamfers();
  }
}

module final_rail_model() {
  difference() {
    rail_with_end_chamfers();
    engraved_markings();
  }
}

// Final Output
final_rail_model();