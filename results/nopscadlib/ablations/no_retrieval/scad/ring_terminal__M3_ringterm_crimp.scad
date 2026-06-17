// Parameters
tongue_L = 18; //[9:36:1]
tongue_W = 10; //[5:20:1]
tongue_T = 1.2; //[0.6:2.4:0.1]
ring_OD = 10; //[6:20:0.5]
ring_ID = 5.2; //[3:10:0.1]
barrel_L = 12; //[6:24:1]
barrel_OD = 6; //[3:12:0.5]
barrel_ID = 3.5; //[1.5:8:0.1]
transition_L = 3; //[1.5:6:0.5]
overlap = 0.8; //[0.3:2:0.1]
sleeve_L = 10; //[0:25:1]
sleeve_T = 1.0; //[0.5:2.5:0.1]
mark_d = 0.6; //[0.2:1.2:0.1]
mark_r = 0.8; //[0.4:1.6:0.1]

// Base Shapes
module tongue_plate() {
  translate([0, 0, 0])
    cube([tongue_L, tongue_W, tongue_T], center=true);
}

module ring_outer() {
  translate([-tongue_L/2 + ring_OD/2, 0, 0])
    cylinder(h=tongue_T, r=ring_OD/2, center=true);
}

module ring_hole() {
  translate([-tongue_L/2 + ring_OD/2, 0, 0])
    cylinder(h=tongue_T + 2*overlap, r=ring_ID/2, center=true);
}

module wire_barrel() {
  translate([tongue_L/2 + barrel_L/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=barrel_L, r=barrel_OD/2, center=true);
}

module barrel_bore() {
  translate([tongue_L/2 + barrel_L/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=barrel_L + 2*overlap, r=barrel_ID/2, center=true);
}

module tongue_to_barrel_transition() {
  translate([tongue_L/2 - transition_L/2, 0, 0])
    cube([transition_L, tongue_W, tongue_T], center=true);
}

module transition_rounder() {
  translate([tongue_L/2 - transition_L/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=transition_L, r=barrel_OD/2, center=true);
}

module insulation_sleeve_outer() {
  translate([tongue_L/2 + sleeve_L/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=sleeve_L, r=barrel_OD/2 + sleeve_T, center=true);
}

module insulation_sleeve_inner() {
  translate([tongue_L/2 + sleeve_L/2 - overlap, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=sleeve_L + 2*overlap, r=barrel_OD/2, center=true);
}

module stamp_mark_1() {
  translate([tongue_L/2 + barrel_L/2 - overlap, barrel_OD/2 - mark_r, 0])
    sphere(r=mark_r, center=true);
}

module stamp_mark_2() {
  translate([tongue_L/2 + barrel_L/2 - overlap, -(barrel_OD/2 - mark_r), 0])
    sphere(r=mark_r, center=true);
}

// Operations
module tongue_with_ring_outer_union() {
  union() {
    tongue_plate();
    ring_outer();
  }
}

module tongue_solid() {
  difference() {
    tongue_with_ring_outer_union();
    ring_hole();
  }
}

module transition_hull() {
  hull() {
    tongue_to_barrel_transition();
    transition_rounder();
  }
}

module metal_outer_union() {
  union() {
    tongue_solid();
    transition_hull();
    wire_barrel();
  }
}

module metal_hollowed() {
  difference() {
    metal_outer_union();
    barrel_bore();
  }
}

module stamping_marks() {
  difference() {
    metal_hollowed();
    stamp_mark_1();
    stamp_mark_2();
  }
}

module insulation_sleeve() {
  difference() {
    insulation_sleeve_outer();
    insulation_sleeve_inner();
  }
}

module chamfers_fillets() {
  union() {
    stamping_marks();
    insulation_sleeve();
  }
}

// Final Output
chamfers_fillets();