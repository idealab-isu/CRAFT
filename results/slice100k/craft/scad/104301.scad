// Parameters
L = 105.06; //[52.53:210.12:0.01]
W = 9.72;   //[4.86:19.44:0.01]
H = 12;     //[6:24:0.01]

hole_count = 6;          //[2:20:1]
hole_d = 4;              //[2:8:0.01]
hole_pitch = 14;         //[7:28:0.01]
hole_edge_margin = 10;   //[5:20:0.01]

fork_slot_len = 18;      //[9:36:0.01]
fork_slot_w = 5;         //[2.5:10:0.01]
tine_w = 2.36;           //[1.18:4.72:0.01]

op_overlap = 1;          //[0.5:2:0.1]
hole_cut_extra = 2;      //[1:6:0.1]
slot_cut_extra = 2;      //[1:6:0.1]

// Main bar body
module main_bar_body() {
  cube([L, W, H], center=true);
}

// Through holes (axis along Y, so holes go through width W)
module through_hole(x_offset) {
  translate([x_offset, 0, 0])
    rotate([90, 0, 0])
      cylinder(h=W + hole_cut_extra, r=hole_d/2, center=true, $fn=48);
}

module through_hole_pattern() {
  for (i = [0:hole_count-1])
    through_hole(-L/2 + hole_edge_margin + i*hole_pitch);
}

// Fork slot: rectangular opening between tines, open to the end (at +X)
module fork_end_u_slot() {
  // Slot starts at the end face x=+L/2 and extends inward by fork_slot_len
  translate([L/2 - fork_slot_len/2, 0, 0])
    cube([fork_slot_len + op_overlap, fork_slot_w, H + slot_cut_extra], center=true);
}

// Complete model (single connected solid)
module complete_model() {
  difference() {
    main_bar_body();
    through_hole_pattern();
    fork_end_u_slot(); // creates the fork opening between two tines
  }
}

complete_model();