// Parameters
pcb_length = 51; //[25.5:102:0.1]
pcb_width = 21; //[10.5:42:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
overlap = 1; //[0.5:2:0.1]
mount_hole_diameter = 2.7; //[2:4:0.1]
mount_hole_edge_offset_x = 3.5; //[2:7:0.1]
mount_hole_edge_offset_y = 3.5; //[2:7:0.1]
edge_connector_length = 14; //[7:28:0.1]
edge_connector_width = 6; //[3:12:0.1]
edge_connector_height = 2.2; //[1:5:0.1]
ic1_length = 12; //[6:24:0.1]
ic1_width = 10; //[5:20:0.1]
ic1_height = 1.6; //[0.8:4:0.1]
ic2_length = 8; //[4:16:0.1]
ic2_width = 6; //[3:12:0.1]
ic2_height = 1.4; //[0.7:3.5:0.1]
usb_length = 12; //[6:24:0.1]
usb_width = 8; //[4:16:0.1]
usb_height = 4.5; //[2:10:0.1]
header_length = 20; //[10:40:0.1]
header_width = 2.6; //[1.5:6:0.1]
header_height = 6; //[3:12:0.1]
silkscreen_thickness = 0.2; //[0.1:0.5:0.05]
silkscreen_margin = 1.2; //[0.6:3:0.1]

// PCB Main Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Mounting Holes
module mount_hole() {
  cylinder(h=pcb_thickness + 2*overlap, r=mount_hole_diameter/2, center=true);
}

module mounting_holes() {
  union() {
    translate([-pcb_length/2 + mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0]) mount_hole();
    translate([pcb_length/2 - mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0]) mount_hole();
    translate([-pcb_length/2 + mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0]) mount_hole();
    translate([pcb_length/2 - mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0]) mount_hole();
  }
}

// PCB with Holes
module pcb_with_holes() {
  difference() {
    pcb_main_body();
    mounting_holes();
  }
}

// Edge Connectors
module edge_connectors() {
  color([0.85, 0.85, 0.8]) // Off-white
  translate([-pcb_length/2 + edge_connector_length/2 - overlap, 0, pcb_thickness/2 + edge_connector_height/2 - overlap])
    cube([edge_connector_length, edge_connector_width, edge_connector_height], center=true);
}

// IC Package 1
module ic_package_1() {
  color([0.1, 0.1, 0.12]) // Black
  translate([-pcb_length/2 + mount_hole_edge_offset_x + ic1_length/2 + (pcb_length - 2*mount_hole_edge_offset_x - ic1_length)*0.35, 0, pcb_thickness/2 + ic1_height/2 - overlap])
    cube([ic1_length, ic1_width, ic1_height], center=true);
}

// IC Package 2
module ic_package_2() {
  color([0.1, 0.1, 0.12]) // Black
  translate([pcb_length/2 - mount_hole_edge_offset_x - ic2_length/2 - (pcb_length - 2*mount_hole_edge_offset_x - ic2_length)*0.25, -pcb_width/2 + mount_hole_edge_offset_y + ic2_width/2 + (pcb_width - 2*mount_hole_edge_offset_y - ic2_width)*0.25, pcb_thickness/2 + ic2_height/2 - overlap])
    cube([ic2_length, ic2_width, ic2_height], center=true);
}

// USB Connector
module usb_connector() {
  color([0.15, 0.15, 0.17]) // Dark Gray
  translate([pcb_length/2 - usb_length/2 + overlap, 0, pcb_thickness/2 + usb_height/2 - overlap])
    cube([usb_length, usb_width, usb_height], center=true);
}

// Pin Headers
module pin_headers() {
  color([0.2, 0.2, 0.2]) // Dark Gray
  translate([0, pcb_width/2 - header_width/2 + overlap, pcb_thickness/2 + header_height/2 - overlap])
    cube([header_length, header_width, header_height], center=true);
}

// Silkscreen Markings
module silkscreen_markings() {
  color([0.85, 0.85, 0.8]) // Off-white
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
    cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
}

// Complete Model
module complete_model() {
  union() {
    pcb_with_holes();
    edge_connectors();
    ic_package_1();
    ic_package_2();
    usb_connector();
    pin_headers();
    silkscreen_markings();
  }
}

// Render the complete model
complete_model();