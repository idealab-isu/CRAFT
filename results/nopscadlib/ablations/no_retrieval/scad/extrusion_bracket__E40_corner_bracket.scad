// Parameters
L1 = 40; //[20:80:1]
L2 = 40; //[20:80:1]
H = 35; //[18:70:1]
t = 5; //[3:10:1]
hole_d = 6; //[3:12:0.5]
hole_edge_offset = 10; //[6:20:1]
hole_spacing = 20; //[10:40:1]
overlap = 1; //[0.5:2:0.5]
gusset_thickness = 5; //[3:10:1]
gusset_leg = 22; //[12:40:1]
csk_d = 11; //[8:18:0.5]
csk_depth = 3; //[1:6:0.5]
edge_chamfer = 1; //[0.5:3:0.5]

// Base Shapes
module bracket_body_L_legA() {
  translate([L1/2, t/2, H/2])
    cube([L1, t, H], center=true);
}

module bracket_body_L_legB() {
  translate([t/2, L2/2, H/2])
    cube([t, L2, H], center=true);
}

module internal_corner_gusset_prism() {
  translate([0, 0, H/2])
    linear_extrude(height=gusset_thickness, center=true)
      polygon(points=[
        [t - overlap, t - overlap],
        [t - overlap + gusset_leg, t - overlap],
        [t - overlap, t - overlap + gusset_leg]
      ]);
}

module mounting_hole_A1() {
  translate([hole_edge_offset, t/2, hole_edge_offset])
    rotate([90, 0, 0])
      cylinder(r=hole_d/2, h=t + 2*overlap, center=true);
}

module mounting_hole_A2() {
  translate([hole_edge_offset + hole_spacing, t/2, hole_edge_offset])
    rotate([90, 0, 0])
      cylinder(r=hole_d/2, h=t + 2*overlap, center=true);
}

module mounting_hole_B1() {
  translate([t/2, hole_edge_offset, hole_edge_offset])
    rotate([0, 90, 0])
      cylinder(r=hole_d/2, h=t + 2*overlap, center=true);
}

module mounting_hole_B2() {
  translate([t/2, hole_edge_offset + hole_spacing, hole_edge_offset])
    rotate([0, 90, 0])
      cylinder(r=hole_d/2, h=t + 2*overlap, center=true);
}

module counterbore_A1() {
  translate([hole_edge_offset, t - csk_depth/2, hole_edge_offset])
    rotate([90, 0, 0])
      cylinder(r=csk_d/2, h=csk_depth + 2*overlap, center=true);
}

module counterbore_A2() {
  translate([hole_edge_offset + hole_spacing, t - csk_depth/2, hole_edge_offset])
    rotate([90, 0, 0])
      cylinder(r=csk_d/2, h=csk_depth + 2*overlap, center=true);
}

module counterbore_B1() {
  translate([t - csk_depth/2, hole_edge_offset, hole_edge_offset])
    rotate([0, 90, 0])
      cylinder(r=csk_d/2, h=csk_depth + 2*overlap, center=true);
}

module counterbore_B2() {
  translate([t - csk_depth/2, hole_edge_offset + hole_spacing, hole_edge_offset])
    rotate([0, 90, 0])
      cylinder(r=csk_d/2, h=csk_depth + 2*overlap, center=true);
}

module edge_chamfer_wedge_legA_top() {
  translate([L1/2, t - edge_chamfer/2, H - edge_chamfer/2])
    rotate([0, 0, 90])
      linear_extrude(height=L1 + 2*overlap, center=true)
        polygon(points=[
          [0, 0],
          [edge_chamfer, 0],
          [0, edge_chamfer]
        ]);
}

module edge_chamfer_wedge_legB_top() {
  translate([t - edge_chamfer/2, L2/2, H - edge_chamfer/2])
    linear_extrude(height=L2 + 2*overlap, center=true)
      polygon(points=[
        [0, 0],
        [edge_chamfer, 0],
        [0, edge_chamfer]
      ]);
}

// Operations
module bracket_body_L() {
  union() {
    bracket_body_L_legA();
    bracket_body_L_legB();
  }
}

module internal_corner_gusset() {
  union() {
    internal_corner_gusset_prism();
    bracket_body_L();
  }
}

module mounting_holes_leg_A() {
  union() {
    mounting_hole_A1();
    mounting_hole_A2();
  }
}

module mounting_holes_leg_B() {
  union() {
    mounting_hole_B1();
    mounting_hole_B2();
  }
}

module countersinks_counterbores() {
  union() {
    counterbore_A1();
    counterbore_A2();
    counterbore_B1();
    counterbore_B2();
  }
}

module edge_fillets_chamfers() {
  union() {
    edge_chamfer_wedge_legA_top();
    edge_chamfer_wedge_legB_top();
  }
}

module bracket_solid_with_gusset() {
  union() {
    bracket_body_L();
    internal_corner_gusset_prism();
  }
}

module bracket_minus_holes() {
  difference() {
    bracket_solid_with_gusset();
    mounting_hole_A1();
    mounting_hole_A2();
    mounting_hole_B1();
    mounting_hole_B2();
  }
}

module bracket_minus_holes_and_counterbores() {
  difference() {
    bracket_minus_holes();
    counterbore_A1();
    counterbore_A2();
    counterbore_B1();
    counterbore_B2();
  }
}

module bracket_minus_holes_counterbores_and_chamfers() {
  difference() {
    bracket_minus_holes_and_counterbores();
    edge_chamfer_wedge_legA_top();
    edge_chamfer_wedge_legB_top();
  }
}

// Final Output
bracket_minus_holes_counterbores_and_chamfers();