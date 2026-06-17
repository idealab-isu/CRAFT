// Parameters
pcb_length = 68.58; //[34.29:137.16:0.01]
pcb_width = 53.34; //[26.67:106.68:0.01]
pcb_thickness = 1.6; //[0.8:3.2:0.05]
corner_radius = 3.0; //[1.5:6.0:0.1]
hole_diameter = 3.2; //[2.0:6.0:0.1]
hole_edge_margin = 6.0; //[3.0:12.0:0.1]
hole_clearance_extra = 0.4; //[0.1:1.0:0.05]
silkscreen_thickness = 0.05; //[0.02:0.2:0.01]
silkscreen_margin = 2.0; //[0.5:6.0:0.1]
silkscreen_stripe_width = 3.0; //[1.0:10.0:0.1]
header_length = 50.0; //[25.0:100.0:0.5]
header_width = 5.0; //[3.0:10.0:0.1]
header_height = 8.0; //[4.0:16.0:0.5]
usb_width = 8.0; //[5.0:16.0:0.1]
usb_length = 10.0; //[6.0:20.0:0.1]
usb_height = 3.5; //[2.0:8.0:0.1]
ic_length = 10.0; //[5.0:25.0:0.1]
ic_width = 10.0; //[5.0:25.0:0.1]
ic_height = 1.2; //[0.6:3.0:0.05]
connect_overlap = 0.8; //[0.5:2.0:0.1]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Edge Rounding Corner Cutter
module edge_rounding_corner_cutter() {
  translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
    cylinder(r=corner_radius, h=pcb_thickness + hole_clearance_extra, center=true);
}

// Mounting Hole Cutter
module mounting_hole_cutter(x, y) {
  translate([x, y, 0])
    cylinder(r=hole_diameter/2, h=pcb_thickness + hole_clearance_extra, center=true);
}

// Silkscreen Markings
module silkscreen_markings() {
  color("White")
  translate([0, pcb_width/2 - silkscreen_margin - silkscreen_stripe_width/2, pcb_thickness/2 + silkscreen_thickness/2 - connect_overlap])
    cube([pcb_length - 2*silkscreen_margin, silkscreen_stripe_width, silkscreen_thickness], center=true);
}

// Connectors Headers
module connectors_headers_left() {
  color("Black")
  translate([0, -pcb_width/2 + header_width/2, pcb_thickness/2 + header_height/2 - connect_overlap])
    cube([header_length, header_width, header_height], center=true);
}

module connectors_headers_right() {
  color("Black")
  translate([0, pcb_width/2 - header_width/2, pcb_thickness/2 + header_height/2 - connect_overlap])
    cube([header_length, header_width, header_height], center=true);
}

// USB Connector
module usb_connector() {
  color("Silver")
  translate([-pcb_length/2 + usb_length/2, 0, pcb_thickness/2 + usb_height/2 - connect_overlap])
    cube([usb_length, usb_width, usb_height], center=true);
}

// IC Packages
module ic_packages() {
  color("DimGray")
  translate([0, 0, pcb_thickness/2 + ic_height/2 - connect_overlap])
    cube([ic_length, ic_width, ic_height], center=true);
}

// Complete Model
module complete_model() {
  difference() {
    pcb_main_body();
    edge_rounding_corner_cutter();
    mirror([1, 0, 0]) edge_rounding_corner_cutter();
    mirror([0, 1, 0]) edge_rounding_corner_cutter();
    mirror([1, 1, 0]) edge_rounding_corner_cutter();
    mounting_hole_cutter(-pcb_length/2 + hole_edge_margin, -pcb_width/2 + hole_edge_margin);
    mounting_hole_cutter(pcb_length/2 - hole_edge_margin, -pcb_width/2 + hole_edge_margin);
    mounting_hole_cutter(-pcb_length/2 + hole_edge_margin, pcb_width/2 - hole_edge_margin);
    mounting_hole_cutter(pcb_length/2 - hole_edge_margin, pcb_width/2 - hole_edge_margin);
  }
  union() {
    silkscreen_markings();
    connectors_headers_left();
    connectors_headers_right();
    usb_connector();
    ic_packages();
  }
}

// Render the complete model
complete_model();