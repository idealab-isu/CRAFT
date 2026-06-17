// Parameters
length = 63; //[31.5:126:0.5]
width = 45; //[22.5:90:0.5]
height = 23; //[11.5:46:0.5]
base_plane_thickness = 0.8; //[0.4:2:0.1]
base_plane_margin = 2; //[0:10:0.5]
connect_overlap = 1; //[0.5:2:0.1]

// Main Body - SSR Module
module main_body() {
  color("DimGray") {
    translate([0, 0, height/2])
      cube([length, width, height], center=true);
  }
}

// Mounting Base Plane Reference
module mounting_base_plane_reference() {
  color("Silver") {
    translate([0, 0, base_plane_thickness/2 - connect_overlap])
      cube([length + 2*base_plane_margin, width + 2*base_plane_margin, base_plane_thickness], center=true);
  }
}

// Complete Module
module mod() {
  union() {
    main_body();
    mounting_base_plane_reference();
  }
}

// Assembly
module assembly() {
  mod();
}

assembly();