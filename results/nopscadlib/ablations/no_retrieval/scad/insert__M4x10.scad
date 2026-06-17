// Parameters
od = 10.0; //[5.0:20.0:0.1]
L = 8.0; //[4.0:16.0:0.1]
id_tap_M4 = 3.3; //[2.0:4.0:0.05]
id_clear_M4 = 4.3; //[4.0:5.5:0.05]
thread_pitch_M4 = 0.7; //[0.5:1.0:0.05]
thread_length = 7.0; //[4.0:8.0:0.1]
chamfer = 0.5; //[0.2:1.5:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
flange_od = 11.0; //[10.0:22.0:0.1]
flange_thk = 0.8; //[0.4:2.0:0.05]
barb_count = 12; //[6:24:1]
barb_radial = 0.6; //[0.2:1.5:0.05]
barb_width = 1.2; //[0.6:3.0:0.1]
barb_height = 5.5; //[2.0:8.0:0.1]
thread_hint_depth = 0.25; //[0.0:0.6:0.05]

// Base shapes
module insert_body() {
  cylinder(h=L, r=od/2, center=true);
}

module installation_flange() {
  translate([0, 0, L/2 + flange_thk/2 - overlap])
    cylinder(h=flange_thk, r=flange_od/2, center=true);
}

module internal_thread_bore() {
  cylinder(h=L + 2*overlap, r=id_tap_M4/2, center=true);
}

module lead_in_chamfer_top() {
  translate([0, 0, L/2 - chamfer/2 + overlap/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer, r1=id_tap_M4/2 + chamfer, r2=0, center=true);
}

module lead_in_chamfer_bottom() {
  translate([0, 0, -L/2 + chamfer/2 - overlap/2])
    cylinder(h=chamfer, r1=id_tap_M4/2 + chamfer, r2=0, center=true);
}

module internal_thread_profile() {
  translate([0, 0, (-L/2) + thread_length/2 + overlap])
    cylinder(h=thread_length, r=id_tap_M4/2 + thread_hint_depth, center=true);
}

module external_barb(angle) {
  rotate([0, 0, angle])
    translate([od/2 + (barb_radial + overlap)/2 - overlap, 0, 0])
    cube([barb_radial + overlap, barb_width, barb_height], center=true);
}

module external_knurling_or_barbs() {
  union() {
    for (i = [0:barb_count-1]) {
      external_barb(i*360/barb_count);
    }
  }
}

// Operations
module insert_outer_union() {
  union() {
    insert_body();
    installation_flange();
    external_knurling_or_barbs();
  }
}

module lead_in_chamfers() {
  union() {
    lead_in_chamfer_top();
    lead_in_chamfer_bottom();
  }
}

module internal_voids_union() {
  union() {
    internal_thread_bore();
    lead_in_chamfers();
    internal_thread_profile();
  }
}

// Final model
module complete_insert_model() {
  difference() {
    insert_outer_union();
    internal_voids_union();
  }
}

// Render the final model
color("Gold") complete_insert_model();