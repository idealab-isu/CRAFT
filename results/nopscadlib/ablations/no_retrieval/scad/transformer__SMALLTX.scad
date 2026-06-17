// Parameters
body_L = 38.0; //[19.0:76.0:0.5]
body_W = 32.0; //[16.0:64.0:0.5]
body_H = 33.0; //[16.5:66.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
fillet_r = 2.0; //[1.0:4.0:0.25]
flange_thk = 2.0; //[1.0:4.0:0.25]
flange_margin = 4.0; //[2.0:8.0:0.5]
hole_d = 4.0; //[2.0:6.0:0.25]
hole_edge_margin = 6.0; //[4.0:10.0:0.5]
wire_r = 1.2; //[0.6:2.4:0.1]
wire_len = 18.0; //[9.0:36.0:0.5]
wire_spacing = 4.0; //[2.0:8.0:0.5]
terminal_L = 18.0; //[9.0:36.0:0.5]
terminal_W = 10.0; //[5.0:20.0:0.5]
terminal_H = 8.0; //[4.0:16.0:0.5]
label_thk = 0.8; //[0.4:1.6:0.1]
label_margin = 3.0; //[1.5:6.0:0.5]

// Base shapes
module transformer_body_base() {
  cube([body_L - 2*fillet_r, body_W - 2*fillet_r, body_H - 2*fillet_r], center=true);
}

module corner_fillets_sphere() {
  sphere(r=fillet_r, center=true);
}

module mounting_flange() {
  cube([body_L + 2*flange_margin, body_W + 2*flange_margin, flange_thk], center=true);
}

module mounting_hole_cyl(pos) {
  translate(pos)
    cylinder(r=hole_d/2, h=flange_thk + 2*overlap, center=true);
}

module terminal_block() {
  cube([terminal_L, terminal_W, terminal_H], center=true);
}

module lead_wire(pos) {
  translate(pos)
    rotate([90, 0, 0])
      cylinder(r=wire_r, h=wire_len, center=true);
}

module label_plate() {
  cube([body_L - 2*label_margin, body_W - 2*label_margin, label_thk], center=true);
}

// Operations
module corner_fillets() {
  minkowski() {
    transformer_body_base();
    corner_fillets_sphere();
  }
}

module body_plus_flange() {
  union() {
    corner_fillets();
    translate([0, 0, -body_H/2 - flange_thk/2 + overlap])
      mounting_flange();
  }
}

module mounting_holes() {
  union() {
    mounting_hole_cyl([(body_L + 2*flange_margin)/2 - hole_edge_margin, (body_W + 2*flange_margin)/2 - hole_edge_margin, -body_H/2 - flange_thk/2 + overlap]);
    mounting_hole_cyl([-((body_L + 2*flange_margin)/2 - hole_edge_margin), (body_W + 2*flange_margin)/2 - hole_edge_margin, -body_H/2 - flange_thk/2 + overlap]);
    mounting_hole_cyl([(body_L + 2*flange_margin)/2 - hole_edge_margin, -((body_W + 2*flange_margin)/2 - hole_edge_margin), -body_H/2 - flange_thk/2 + overlap]);
    mounting_hole_cyl([-((body_L + 2*flange_margin)/2 - hole_edge_margin), -((body_W + 2*flange_margin)/2 - hole_edge_margin), -body_H/2 - flange_thk/2 + overlap]);
  }
}

module flange_with_holes() {
  difference() {
    body_plus_flange();
    mounting_holes();
  }
}

module lead_wires() {
  union() {
    lead_wire([-wire_spacing/2, body_W/2 + wire_len/2 - overlap, -body_H/2 + terminal_H/2]);
    lead_wire([wire_spacing/2, body_W/2 + wire_len/2 - overlap, -body_H/2 + terminal_H/2]);
  }
}

module transformer_complete() {
  union() {
    flange_with_holes();
    translate([0, body_W/2 + terminal_W/2 - overlap, -body_H/2 + terminal_H/2])
      terminal_block();
    lead_wires();
    translate([0, 0, body_H/2 + label_thk/2 - overlap])
      label_plate();
  }
}

// Final output
transformer_complete();