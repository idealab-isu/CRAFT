// Parameters
pcb_L = 68.58; //[34.29:137.16:0.01]
pcb_W = 53.34; //[26.67:106.68:0.01]
pcb_T = 1.6; //[0.8:3.2:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
placeholder_T = 0.4; //[0.2:1.0:0.1]
mount_hole_r = 1.6; //[0.8:3.2:0.1]
mount_hole_offset_x = 6.0; //[3.0:12.0:0.5]
mount_hole_offset_y = 6.0; //[3.0:12.0:0.5]
header_L = 50.0; //[25.0:100.0:0.5]
header_W = 5.0; //[2.5:10.0:0.5]
header_H = 8.0; //[4.0:16.0:0.5]
usb_L = 10.0; //[5.0:20.0:0.5]
usb_W = 8.0; //[4.0:16.0:0.5]
usb_H = 4.0; //[2.0:10.0:0.5]
comp_L = 20.0; //[10.0:40.0:0.5]
comp_W = 15.0; //[7.5:30.0:0.5]
comp_H = 3.0; //[1.5:8.0:0.5]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_L, pcb_W, pcb_T], center=true);
}

// Edge Rounding
module edge_rounding() {
  color([0.0, 0.4, 0.2]) // Green PCB
  translate([0, 0, pcb_T/2 - overlap - placeholder_T/2])
    cube([pcb_L, pcb_W, placeholder_T], center=true);
}

// Silkscreen Markings
module silkscreen_markings() {
  color([0.0, 0.4, 0.2]) // Green PCB
  translate([0, 0, pcb_T/2 - overlap - placeholder_T/2])
    cube([pcb_L*0.9, pcb_W*0.9, placeholder_T], center=true);
}

// Mounting Holes
module mounting_hole() {
  color("Black")
  cylinder(h=pcb_T + 2*placeholder_T, r=mount_hole_r, center=true);
}

module mounting_holes() {
  union() {
    translate([-pcb_L/2 + mount_hole_offset_x, -pcb_W/2 + mount_hole_offset_y, 0]) mounting_hole();
    translate([pcb_L/2 - mount_hole_offset_x, -pcb_W/2 + mount_hole_offset_y, 0]) mounting_hole();
    translate([-pcb_L/2 + mount_hole_offset_x, pcb_W/2 - mount_hole_offset_y, 0]) mounting_hole();
    translate([pcb_L/2 - mount_hole_offset_x, pcb_W/2 - mount_hole_offset_y, 0]) mounting_hole();
  }
}

// Pin Headers
module pin_header() {
  color("Black")
  cube([header_L, header_W, header_H], center=true);
}

module pin_headers() {
  union() {
    translate([0, -pcb_W/2 + header_W/2 - overlap, pcb_T/2 + header_H/2 - overlap]) pin_header();
    translate([0, pcb_W/2 - header_W/2 + overlap, pcb_T/2 + header_H/2 - overlap]) pin_header();
  }
}

// USB Connector
module usb_connector() {
  color("Black")
  translate([-pcb_L/2 + usb_L/2 - overlap, 0, pcb_T/2 + usb_H/2 - overlap])
    cube([usb_L, usb_W, usb_H], center=true);
}

// Component Placeholders
module component_placeholders() {
  color("Black")
  translate([0, 0, pcb_T/2 + comp_H/2 - overlap])
    cube([comp_L, comp_W, comp_H], center=true);
}

// Complete Board
module board_complete() {
  union() {
    pcb_main_body();
    edge_rounding();
    silkscreen_markings();
    mounting_holes();
    component_placeholders();
    pin_headers();
    usb_connector();
  }
}

// Final Output
board_complete();