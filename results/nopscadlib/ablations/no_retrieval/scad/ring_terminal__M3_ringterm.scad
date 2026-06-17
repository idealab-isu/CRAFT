// Parameters
tongue_L = 20; //[10:40:1]
tongue_W = 12; //[6:24:1]
tongue_T = 1.5; //[0.8:3:0.1]
ring_hole_D = 6.5; //[3.5:13:0.1]
ring_outer_D = 12; //[7:24:0.5]
barrel_L = 18; //[9:36:1]
barrel_OD = 6; //[3:12:0.1]
barrel_ID = 4; //[2:10:0.1]
transition_L = 6; //[3:12:0.5]
entry_chamfer_L = 1; //[0.5:3:0.1]
entry_chamfer_DeltaD = 1; //[0.2:3:0.1]
overlap = 1; //[0.5:2:0.1]
inspection_window_L = 6; //[3:12:0.5]
inspection_window_W = 2.5; //[1:6:0.1]
inspection_window_offset_from_entry = 5; //[2:12:0.5]
crimp_indent_count = 2; //[1:4:1]
crimp_indent_D = 1.2; //[0.6:2.5:0.1]
crimp_indent_depth = 0.6; //[0.2:1.5:0.1]
edge_round_r = 0.6; //[0.2:1.5:0.1]

// Base Shapes
module tongue_plate() {
  translate([ring_outer_D/2 + tongue_L/2 - overlap, 0, 0])
    cube([tongue_L, tongue_W, tongue_T], center=true);
}

module ring_outer_cyl() {
  translate([0, 0, 0])
    cylinder(r=ring_outer_D/2, h=tongue_T, center=true);
}

module ring_hole() {
  translate([0, 0, 0])
    cylinder(r=ring_hole_D/2, h=tongue_T + 2*overlap, center=true);
}

module wire_barrel_outer() {
  translate([ring_outer_D/2 + tongue_L - overlap + transition_L - overlap + barrel_L/2, 0, 0])
    rotate([0, 90, 0])
    cylinder(r=barrel_OD/2, h=barrel_L, center=true);
}

module wire_barrel_inner() {
  translate([ring_outer_D/2 + tongue_L - overlap + transition_L - overlap + barrel_L/2, 0, 0])
    rotate([0, 90, 0])
    cylinder(r=barrel_ID/2, h=barrel_L + 2*overlap, center=true);
}

module tongue_to_barrel_transition() {
  translate([ring_outer_D/2 + tongue_L - overlap + transition_L/2, 0, 0])
    rotate([0, 90, 0])
    cylinder(r1=barrel_OD/2, r2=barrel_OD/2, h=transition_L, center=true);
}

module transition_inner_bore() {
  translate([ring_outer_D/2 + tongue_L - overlap + transition_L/2, 0, 0])
    rotate([0, 90, 0])
    cylinder(r=barrel_ID/2, h=transition_L + 2*overlap, center=true);
}

module barrel_wire_entry_chamfer() {
  translate([ring_outer_D/2 + tongue_L - overlap + transition_L - overlap + entry_chamfer_L/2, 0, 0])
    rotate([0, 90, 0])
    cylinder(r1=(barrel_ID + entry_chamfer_DeltaD)/2, r2=barrel_ID/2, h=entry_chamfer_L, center=true);
}

module inspection_window() {
  translate([ring_outer_D/2 + tongue_L - overlap + transition_L - overlap + inspection_window_offset_from_entry, 0, 0])
    cube([inspection_window_L, inspection_window_W, barrel_OD + 2*overlap], center=true);
}

module crimp_indent_mark_1() {
  translate([ring_outer_D/2 + tongue_L - overlap + transition_L - overlap + barrel_L*(1/3), 0, barrel_OD/2 - crimp_indent_depth/2])
    rotate([90, 0, 0])
    cylinder(r=crimp_indent_D/2, h=crimp_indent_depth + 2*overlap, center=true);
}

module crimp_indent_mark_2() {
  translate([ring_outer_D/2 + tongue_L - overlap + transition_L - overlap + barrel_L*(2/3), 0, barrel_OD/2 - crimp_indent_depth/2])
    rotate([90, 0, 0])
    cylinder(r=crimp_indent_D/2, h=crimp_indent_depth + 2*overlap, center=true);
}

module edge_fillet_rounding_sphere() {
  translate([0, 0, 0])
    sphere(r=edge_round_r, center=true);
}

module manufacturer_text_stamp() {
  translate([ring_outer_D/2 + tongue_L/2, 0, tongue_T/2 - (tongue_T/3)/2])
    cube([tongue_L/4, tongue_W/3, tongue_T/3], center=true);
}

// Operations
module tongue_with_ring_outer() {
  union() {
    ring_outer_cyl();
    tongue_plate();
  }
}

module tongue_with_ring_hole() {
  difference() {
    tongue_with_ring_outer();
    ring_hole();
  }
}

module barrel_hollow() {
  difference() {
    wire_barrel_outer();
    wire_barrel_inner();
  }
}

module transition_hollow() {
  difference() {
    tongue_to_barrel_transition();
    transition_inner_bore();
  }
}

module main_solid_pre_features() {
  union() {
    tongue_with_ring_hole();
    transition_hollow();
    barrel_hollow();
  }
}

module main_solid_with_entry_chamfer() {
  difference() {
    main_solid_pre_features();
    barrel_wire_entry_chamfer();
  }
}

module main_solid_with_window() {
  difference() {
    main_solid_with_entry_chamfer();
    inspection_window();
  }
}

module main_solid_with_crimp_indents() {
  difference() {
    main_solid_with_window();
    crimp_indent_mark_1();
    crimp_indent_mark_2();
  }
}

module main_solid_with_stamp_deboss() {
  difference() {
    main_solid_with_crimp_indents();
    manufacturer_text_stamp();
  }
}

module edge_fillet_rounding() {
  minkowski() {
    main_solid_with_stamp_deboss();
    edge_fillet_rounding_sphere();
  }
}

// Final Output
edge_fillet_rounding();