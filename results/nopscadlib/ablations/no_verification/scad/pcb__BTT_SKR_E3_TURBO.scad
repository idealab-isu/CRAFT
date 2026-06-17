// Parameters
pcb_L = 102.0; //[51.0:204.0:0.25]
pcb_W = 90.25; //[45.0:180.5:0.25]
pcb_T = 1.6; //[0.8:3.2:0.1]
corner_R = 3.0; //[1.5:6.0:0.25]
mount_hole_d = 3.2; //[2.0:6.0:0.1]
mount_edge_margin = 6.0; //[3.0:12.0:0.25]
hole_clearance_z = 0.5; //[0.2:2.0:0.1]
attach_overlap = 1.0; //[0.5:2.0:0.1]
conn_L = 18.0; //[9.0:36.0:0.5]
conn_W = 12.0; //[6.0:24.0:0.5]
conn_H = 10.0; //[5.0:20.0:0.5]
heatsink_L = 14.0; //[7.0:28.0:0.5]
heatsink_W = 14.0; //[7.0:28.0:0.5]
heatsink_H = 8.0; //[4.0:16.0:0.5]
chip_L = 12.0; //[6.0:24.0:0.5]
chip_W = 12.0; //[6.0:24.0:0.5]
chip_H = 2.0; //[1.0:5.0:0.1]
small_chip_L = 6.0; //[3.0:12.0:0.25]
small_chip_W = 4.0; //[2.0:8.0:0.25]
small_chip_H = 1.6; //[0.8:3.2:0.1]

// Mainboard PCB with rounded corners and mounting holes
module pcb_with_mounting_holes() {
  difference() {
    // PCB main body
    color([0.0, 0.4, 0.2]) // Green PCB
    cube([pcb_L, pcb_W, pcb_T], center=true);
    
    // Rounded corners
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (pcb_L/2 - corner_R), y * (pcb_W/2 - corner_R), 0])
        cylinder(r=corner_R, h=pcb_T + hole_clearance_z, center=true);
    }
    
    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (pcb_L/2 - mount_edge_margin), y * (pcb_W/2 - mount_edge_margin), 0])
        cylinder(r=mount_hole_d/2, h=pcb_T + hole_clearance_z, center=true);
    }
  }
}

// Connector module
module connector_body() {
  color([0.85, 0.85, 0.8]) // Off-white for connectors
  cube([conn_L, conn_W, conn_H], center=true);
}

// Heatsink module
module heatsink_body() {
  color([0.4, 0.4, 0.43]) // DimGray for heatsinks
  cube([heatsink_L, heatsink_W, heatsink_H], center=true);
}

// Main chip module
module chip_main() {
  color([0.1, 0.1, 0.6]) // Blue for main chip
  cube([chip_L, chip_W, chip_H], center=true);
}

// Small chip module
module chip_small() {
  color([0.1, 0.1, 0.6]) // Blue for small chips
  cube([small_chip_L, small_chip_W, small_chip_H], center=true);
}

// Complete mainboard model
module complete_mainboard_model() {
  union() {
    pcb_with_mounting_holes();
    
    // Connectors
    translate([pcb_L/2 - conn_L/2, pcb_W/2 - conn_W/2, pcb_T/2 + conn_H/2 - attach_overlap])
      connector_body();
    translate([pcb_L/2 - conn_L/2, -pcb_W/2 + conn_W/2, pcb_T/2 + conn_H/2 - attach_overlap])
      connector_body();
    translate([-pcb_L/2 + conn_L/2, 0, pcb_T/2 + conn_H/2 - attach_overlap])
      connector_body();
    
    // Main chip and heatsink
    translate([0, 0, pcb_T/2 + chip_H/2 - attach_overlap])
      chip_main();
    translate([0, 0, pcb_T/2 + heatsink_H/2 - attach_overlap])
      heatsink_body();
    
    // Small chips
    translate([-pcb_L/4, pcb_W/4, pcb_T/2 + small_chip_H/2 - attach_overlap])
      chip_small();
    translate([pcb_L/4, pcb_W/4, pcb_T/2 + small_chip_H/2 - attach_overlap])
      chip_small();
    translate([-pcb_L/4, -pcb_W/4, pcb_T/2 + small_chip_H/2 - attach_overlap])
      chip_small();
    translate([pcb_L/4, -pcb_W/4, pcb_T/2 + small_chip_H/2 - attach_overlap])
      chip_small();
  }
}

// Render the complete mainboard model
complete_mainboard_model();