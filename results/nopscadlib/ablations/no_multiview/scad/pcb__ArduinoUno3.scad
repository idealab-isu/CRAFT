// Parameters
pcb_L = 68.58; //[34.29:137.16:0.01]
pcb_W = 53.34; //[26.67:106.68:0.01]
pcb_T = 1.6; //[0.8:3.2:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
hole_r = 1.6; //[0.8:3.2:0.1]
hole_h = 2.0; //[1.0:6.0:0.1]
hole_edge_margin = 4.0; //[2.0:10.0:0.5]
edge_conn_L = 20.0; //[10.0:40.0:0.5]
edge_conn_W = 6.0; //[3.0:15.0:0.5]
edge_conn_H = 3.0; //[1.5:10.0:0.5]
pin_header_L = 50.0; //[25.0:100.0:0.5]
pin_header_W = 5.0; //[2.5:12.0:0.5]
pin_header_H = 8.0; //[4.0:20.0:0.5]
usb_L = 8.0; //[4.0:20.0:0.5]
usb_W = 12.0; //[6.0:25.0:0.5]
usb_H = 4.0; //[2.0:12.0:0.5]
silk_T = 0.2; //[0.1:0.6:0.05]
silk_margin = 2.0; //[1.0:6.0:0.5]
comp_L = 18.0; //[9.0:40.0:0.5]
comp_W = 18.0; //[9.0:40.0:0.5]
comp_H = 3.0; //[1.5:15.0:0.5]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_L, pcb_W, pcb_T], center=true);
}

// Mounting Holes
module mounting_holes() {
  color("DimGray") // Placeholder color for holes
  union() {
    translate([-pcb_L/2 + hole_edge_margin, -pcb_W/2 + hole_edge_margin, pcb_T/2 + hole_h/2 - overlap])
      cylinder(r=hole_r, h=hole_h, center=true);
    translate([pcb_L/2 - hole_edge_margin, -pcb_W/2 + hole_edge_margin, pcb_T/2 + hole_h/2 - overlap])
      cylinder(r=hole_r, h=hole_h, center=true);
    translate([-pcb_L/2 + hole_edge_margin, pcb_W/2 - hole_edge_margin, pcb_T/2 + hole_h/2 - overlap])
      cylinder(r=hole_r, h=hole_h, center=true);
    translate([pcb_L/2 - hole_edge_margin, pcb_W/2 - hole_edge_margin, pcb_T/2 + hole_h/2 - overlap])
      cylinder(r=hole_r, h=hole_h, center=true);
  }
}

// Edge Connector Placeholder
module edge_connector_placeholder() {
  color("Silver") // Placeholder color for connectors
  translate([0, pcb_W/2 - edge_conn_W/2 + overlap, pcb_T/2 + edge_conn_H/2 - overlap])
    cube([edge_conn_L, edge_conn_W, edge_conn_H], center=true);
}

// Pin Header Placeholders
module pin_headers() {
  color("Silver") // Placeholder color for pin headers
  union() {
    translate([0, -pcb_W/2 + pin_header_W/2 - overlap, pcb_T/2 + pin_header_H/2 - overlap])
      cube([pin_header_L, pin_header_W, pin_header_H], center=true);
    translate([0, pcb_W/2 - pin_header_W/2 + overlap, pcb_T/2 + pin_header_H/2 - overlap])
      cube([pin_header_L, pin_header_W, pin_header_H], center=true);
  }
}

// USB Connector Placeholder
module usb_connector_placeholder() {
  color("Silver") // Placeholder color for USB connector
  translate([-pcb_L/2 + usb_L/2 - overlap, 0, pcb_T/2 + usb_H/2 - overlap])
    cube([usb_L, usb_W, usb_H], center=true);
}

// Silkscreen Markings
module silkscreen_markings() {
  color("White") // Silkscreen color
  translate([0, 0, pcb_T/2 + silk_T/2 - overlap])
    cube([pcb_L - 2*silk_margin, pcb_W - 2*silk_margin, silk_T], center=true);
}

// Component Placeholders
module component_placeholders() {
  color("Silver") // Placeholder color for components
  translate([0, 0, pcb_T/2 + comp_H/2 - overlap])
    cube([comp_L, comp_W, comp_H], center=true);
}

// Complete Board Model
module complete_board_model() {
  union() {
    pcb_main_body();
    mounting_holes();
    edge_connector_placeholder();
    pin_headers();
    usb_connector_placeholder();
    silkscreen_markings();
    component_placeholders();
  }
}

// Render the complete board model
complete_board_model();