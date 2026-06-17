// Parameters
rail_L = 100; //[50:200:1]
rail_W = 12; //[6:24:0.5]
rail_H = 8; //[4:16:0.5]
edge_chamfer = 0.8; //[0.4:1.6:0.1]
chamfer_inset = 0.6; //[0.3:1.2:0.1]
hole_count = 4; //[2:8:1]
end_margin = 12; //[6:24:1]
hole_r = 1.7; //[1.2:2.5:0.1]
csk_r = 3.2; //[2.4:4.5:0.1]
csk_depth = 1.6; //[0.8:3.0:0.1]
raceway_r = 1.2; //[0.6:2.0:0.1]
raceway_depth = 0.8; //[0.4:1.6:0.1]
raceway_z = 2.6; //[1.5:4.0:0.1]
op_overlap = 1; //[0.5:2:0.1]
end_face_thk = 0.8; //[0.4:1.6:0.1]

// Base Shapes
module rail_body_raw() {
  cube([rail_W, rail_L, rail_H], center=true);
}

module rail_body_inset() {
  cube([rail_W - 2*chamfer_inset, rail_L - 2*chamfer_inset, rail_H - 2*chamfer_inset], center=true);
}

module end_face_posY() {
  translate([0, rail_L/2 - end_face_thk/2, 0])
    cube([rail_W, end_face_thk, rail_H], center=true);
}

module end_face_negY() {
  translate([0, -rail_L/2 + end_face_thk/2, 0])
    cube([rail_W, end_face_thk, rail_H], center=true);
}

module mount_hole(posY) {
  translate([0, posY, 0])
    rotate([90, 0, 0])
      cylinder(h=rail_H + 2*op_overlap, r=hole_r, center=true);
}

module countersink(posY) {
  translate([0, posY, rail_H/2 - (csk_depth + op_overlap)/2])
    rotate([90, 0, 0])
      cylinder(h=csk_depth + op_overlap, r=csk_r, center=true);
}

module raceway_groove(xPos) {
  translate([xPos, 0, -rail_H/2 + raceway_z])
    cylinder(h=rail_L + 2*op_overlap, r=raceway_r, center=true);
}

module engraved_markings_placeholder() {
  translate([0, 0, rail_H/2 - (rail_H/20)/2])
    cube([rail_W - 2*chamfer_inset, rail_L/5, rail_H/20], center=true);
}

// Operations
module chamfers_fillets() {
  hull() {
    rail_body_raw();
    rail_body_inset();
  }
}

module end_faces() {
  union() {
    end_face_posY();
    end_face_negY();
  }
}

module rail_plus_end_faces() {
  union() {
    chamfers_fillets();
    end_faces();
  }
}

module mounting_holes() {
  union() {
    mount_hole(-rail_L/2 + end_margin);
    mount_hole(-rail_L/2 + end_margin + (rail_L - 2*end_margin)/3);
    mount_hole(-rail_L/2 + end_margin + 2*(rail_L - 2*end_margin)/3);
    mount_hole(rail_L/2 - end_margin);
  }
}

module countersinks() {
  union() {
    countersink(-rail_L/2 + end_margin);
    countersink(-rail_L/2 + end_margin + (rail_L - 2*end_margin)/3);
    countersink(-rail_L/2 + end_margin + 2*(rail_L - 2*end_margin)/3);
    countersink(rail_L/2 - end_margin);
  }
}

module raceway_grooves() {
  union() {
    raceway_groove(-rail_W/2 + raceway_depth);
    raceway_groove(rail_W/2 - raceway_depth);
  }
}

module holes_and_grooves() {
  union() {
    mounting_holes();
    countersinks();
    raceway_grooves();
  }
}

module rail_body() {
  difference() {
    rail_plus_end_faces();
    holes_and_grooves();
  }
}

module engraved_markings() {
  difference() {
    rail_body();
    engraved_markings_placeholder();
  }
}

// Final Output
color("Silver") engraved_markings();