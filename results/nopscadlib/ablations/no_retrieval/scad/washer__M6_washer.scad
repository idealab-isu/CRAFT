// Parameters
outer_diameter = 12.5; //[6.25:25:0.1]
inner_diameter = 6; //[3:12:0.1]
thickness = 1.5; //[0.75:3:0.1]
edge_chamfer = 0.3; //[0:1.5:0.05]
edge_fillet = 0.2; //[0:1:0.05]
overlap = 0.8; //[0.2:2:0.1]

// Washer Body
module washer_body() {
  cylinder(h=thickness, r=outer_diameter/2, center=true);
}

// Center Through Hole
module center_through_hole() {
  cylinder(h=thickness + 2*overlap, r=inner_diameter/2, center=true);
}

// Outer Chamfers
module outer_chamfer_top() {
  translate([0, 0, thickness/2 - edge_chamfer/2 + overlap/2])
    cylinder(h=edge_chamfer, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

module outer_chamfer_bottom() {
  translate([0, 0, -thickness/2 + edge_chamfer/2 - overlap/2])
    rotate([180, 0, 0])
    cylinder(h=edge_chamfer, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

// Inner Chamfers
module inner_chamfer_top() {
  translate([0, 0, thickness/2 - edge_chamfer/2 + overlap/2])
    cylinder(h=edge_chamfer, r1=inner_diameter/2 + edge_chamfer + overlap, r2=0, center=true);
}

module inner_chamfer_bottom() {
  translate([0, 0, -thickness/2 + edge_chamfer/2 - overlap/2])
    rotate([180, 0, 0])
    cylinder(h=edge_chamfer, r1=inner_diameter/2 + edge_chamfer + overlap, r2=0, center=true);
}

// Outer Fillet Torus
module outer_fillet_torus_top() {
  translate([0, 0, thickness/2 - edge_fillet])
    rotate_extrude()
    translate([outer_diameter/2 - edge_fillet, 0, 0])
    circle(r=edge_fillet);
}

module outer_fillet_torus_bottom() {
  translate([0, 0, -thickness/2 + edge_fillet])
    rotate_extrude()
    translate([outer_diameter/2 - edge_fillet, 0, 0])
    circle(r=edge_fillet);
}

// Inner Fillet Torus
module inner_fillet_torus_top() {
  translate([0, 0, thickness/2 - edge_fillet])
    rotate_extrude()
    translate([inner_diameter/2 + edge_fillet, 0, 0])
    circle(r=edge_fillet);
}

module inner_fillet_torus_bottom() {
  translate([0, 0, -thickness/2 + edge_fillet])
    rotate_extrude()
    translate([inner_diameter/2 + edge_fillet, 0, 0])
    circle(r=edge_fillet);
}

// Edge Chamfers
module edge_chamfers() {
  union() {
    outer_chamfer_top();
    outer_chamfer_bottom();
    inner_chamfer_top();
    inner_chamfer_bottom();
  }
}

// Edge Fillets
module edge_fillets() {
  union() {
    outer_fillet_torus_top();
    outer_fillet_torus_bottom();
    inner_fillet_torus_top();
    inner_fillet_torus_bottom();
  }
}

// Final Washer with Fillets
module washer_with_fillets() {
  union() {
    difference() {
      difference() {
        washer_body();
        center_through_hole();
      }
      edge_chamfers();
    }
    edge_fillets();
  }
}

// Render the final washer
washer_with_fillets();