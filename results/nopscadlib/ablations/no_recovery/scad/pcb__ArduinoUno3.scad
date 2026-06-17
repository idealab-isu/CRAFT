// Parameters
pcb_L = 68.58; //[34.29:137.16:0.01]
pcb_W = 53.34; //[26.67:106.68:0.01]
pcb_T = 1.6; //[0.8:3.2:0.1]
corner_R = 3.0; //[1.5:6.0:0.1]
hole_d = 3.2; //[2.0:4.0:0.1]
hole_edge_offset = 4.0; //[2.0:8.0:0.1]
hole_clearance = 0.2; //[0.0:0.6:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
silk_T = 0.2; //[0.1:0.6:0.05]
silk_margin = 2.0; //[1.0:5.0:0.1]
header_L = 50.0; //[25.0:100.0:0.5]
header_W = 5.0; //[3.0:10.0:0.1]
header_H = 8.0; //[4.0:16.0:0.5]
header_inset = 2.0; //[0.5:6.0:0.1]
ic_L = 14.0; //[7.0:28.0:0.5]
ic_W = 14.0; //[7.0:28.0:0.5]
ic_H = 2.0; //[1.0:6.0:0.1]
usb_L = 8.0; //[4.0:16.0:0.5]
usb_W = 10.0; //[6.0:20.0:0.5]
usb_H = 4.0; //[2.0:10.0:0.5]

// Base shapes
module edge_rounding_corner_cyl() {
  cylinder(r=corner_R, h=pcb_T, center=true);
}

module mounting_hole() {
  cylinder(r=hole_d/2 + hole_clearance, h=pcb_T + 2*overlap, center=true);
}

module silkscreen_markings() {
  cube([pcb_L - 2*silk_margin, pcb_W - 2*silk_margin, silk_T], center=true);
}

module connectors_headers() {
  cube([header_L, header_W, header_H], center=true);
}

module ic_packages_main() {
  cube([ic_L, ic_W, ic_H], center=true);
}

module usb_port() {
  cube([usb_L, usb_W, usb_H], center=true);
}

// Operations
module edge_rounding() {
  hull() {
    translate([pcb_L/2 - corner_R, pcb_W/2 - corner_R, 0]) edge_rounding_corner_cyl();
    translate([-(pcb_L/2 - corner_R), pcb_W/2 - corner_R, 0]) edge_rounding_corner_cyl();
    translate([-(pcb_L/2 - corner_R), -(pcb_W/2 - corner_R), 0]) edge_rounding_corner_cyl();
    translate([pcb_L/2 - corner_R, -(pcb_W/2 - corner_R), 0]) edge_rounding_corner_cyl();
  }
}

module mounting_holes() {
  union() {
    translate([-(pcb_L/2 - hole_edge_offset), -(pcb_W/2 - hole_edge_offset), 0]) mounting_hole();
    translate([pcb_L/2 - hole_edge_offset, -(pcb_W/2 - hole_edge_offset), 0]) mounting_hole();
    translate([pcb_L/2 - hole_edge_offset, pcb_W/2 - hole_edge_offset, 0]) mounting_hole();
    translate([-(pcb_L/2 - hole_edge_offset), pcb_W/2 - hole_edge_offset, 0]) mounting_hole();
  }
}

module pcb_main_body() {
  difference() {
    edge_rounding();
    mounting_holes();
  }
}

module complete_model() {
  union() {
    pcb_main_body();
    translate([0, 0, pcb_T/2 + silk_T/2 - overlap]) silkscreen_markings();
    translate([0, -(pcb_W/2 - header_inset) + header_W/2 - overlap, pcb_T/2 + header_H/2 - overlap]) connectors_headers();
    translate([0, pcb_W/2 - header_inset - header_W/2 + overlap, pcb_T/2 + header_H/2 - overlap]) connectors_headers();
    translate([0, 0, pcb_T/2 + ic_H/2 - overlap]) ic_packages_main();
    translate([pcb_L/2 + usb_L/2 - overlap, 0, pcb_T/2 + usb_H/2 - overlap]) usb_port();
  }
}

// Final output
color([0.0, 0.4, 0.2]) complete_model(); // PCB color