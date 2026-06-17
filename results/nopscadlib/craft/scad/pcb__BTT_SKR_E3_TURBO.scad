// Parameters
pcb_L = 102.0; //[51.0:204.0:0.25]
pcb_W = 90.25; //[45.0:180.5:0.25]
pcb_T = 1.6; //[0.8:3.2:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
mount_hole_d = 3.2; //[2.0:6.0:0.1]
mount_edge_x = 6.0; //[3.0:15.0:0.5]
mount_edge_y = 6.0; //[3.0:15.0:0.5]
conn_T = 8.0; //[4.0:16.0:0.5]
conn_depth = 12.0; //[6.0:24.0:0.5]
conn_wall = 2.0; //[1.0:4.0:0.25]
heatsink_L = 18.0; //[9.0:36.0:0.5]
heatsink_W = 18.0; //[9.0:36.0:0.5]
heatsink_H = 10.0; //[5.0:20.0:0.5]
ic1_L = 14.0; //[7.0:28.0:0.5]
ic1_W = 14.0; //[7.0:28.0:0.5]
ic1_H = 2.0; //[1.0:5.0:0.1]
ic2_L = 10.0; //[5.0:20.0:0.5]
ic2_W = 10.0; //[5.0:20.0:0.5]
ic2_H = 1.8; //[0.9:4.0:0.1]
silk_T = 0.15; //[0.05:0.4:0.05]
silk_margin = 2.0; //[1.0:6.0:0.5]

// Mainboard PCB with mounting holes
module pcb_with_holes() {
  difference() {
    color([0.0, 0.4, 0.2]) // PCB color
    cube([pcb_L, pcb_W, pcb_T], center=true);
    translate([-pcb_L/2 + mount_edge_x, -pcb_W/2 + mount_edge_y, 0])
      cylinder(h=pcb_T + 2*overlap, r=mount_hole_d/2, center=true);
    translate([pcb_L/2 - mount_edge_x, -pcb_W/2 + mount_edge_y, 0])
      cylinder(h=pcb_T + 2*overlap, r=mount_hole_d/2, center=true);
    translate([-pcb_L/2 + mount_edge_x, pcb_W/2 - mount_edge_y, 0])
      cylinder(h=pcb_T + 2*overlap, r=mount_hole_d/2, center=true);
    translate([pcb_L/2 - mount_edge_x, pcb_W/2 - mount_edge_y, 0])
      cylinder(h=pcb_T + 2*overlap, r=mount_hole_d/2, center=true);
  }
}

// Connectors
module connectors() {
  union() {
    color([0.15, 0.15, 0.15]) // Connector color
    translate([pcb_L/2 + conn_wall/2 - overlap, -pcb_W*0.18, pcb_T/2 + conn_T/2 - overlap])
      cube([conn_wall, pcb_W*0.22, conn_T], center=true);
    translate([pcb_L/2 + conn_wall/2 - overlap, pcb_W*0.22, pcb_T/2 + (conn_T*0.9)/2 - overlap])
      cube([conn_wall, pcb_W*0.18, conn_T*0.9], center=true);
    translate([-pcb_L*0.18, pcb_W/2 + conn_wall/2 - overlap, pcb_T/2 + (conn_T*0.8)/2 - overlap])
      cube([pcb_L*0.28, conn_wall, conn_T*0.8], center=true);
    translate([-pcb_L/2 - conn_wall/2 + overlap, pcb_W*0.05, pcb_T/2 + (conn_T*0.75)/2 - overlap])
      cube([conn_wall, pcb_W*0.20, conn_T*0.75], center=true);
  }
}

// Heatsinks
module heatsinks() {
  union() {
    color([0.75, 0.75, 0.77]) // Heatsink color
    translate([pcb_L*0.18, pcb_W*0.10, pcb_T/2 + heatsink_H/2 - overlap])
      cube([heatsink_L, heatsink_W, heatsink_H], center=true);
    translate([pcb_L*0.05, -pcb_W*0.22, pcb_T/2 + (heatsink_H*0.9)/2 - overlap])
      cube([heatsink_L*0.9, heatsink_W*0.9, heatsink_H*0.9], center=true);
  }
}

// IC Packages
module ic_packages() {
  union() {
    color([0.1, 0.1, 0.1]) // IC package color
    translate([-pcb_L*0.10, -pcb_W*0.05, pcb_T/2 + ic1_H/2 - overlap])
      cube([ic1_L, ic1_W, ic1_H], center=true);
    translate([-pcb_L*0.28, pcb_W*0.18, pcb_T/2 + ic2_H/2 - overlap])
      cube([ic2_L, ic2_W*1.4, ic2_H], center=true);
    translate([pcb_L*0.30, -pcb_W*0.18, pcb_T/2 + (ic2_H*0.9)/2 - overlap])
      cube([ic2_L*1.2, ic2_W, ic2_H*0.9], center=true);
  }
}

// Silkscreen Markings
module silkscreen_markings() {
  difference() {
    color([1, 1, 1]) // Silkscreen color
    translate([0, 0, pcb_T/2 + silk_T/2 - overlap])
      cube([pcb_L - 2*silk_margin, pcb_W - 2*silk_margin, silk_T], center=true);
    translate([0, 0, pcb_T/2 + silk_T/2 - overlap])
      cube([pcb_L - 2*(silk_margin + pcb_L*0.03), pcb_W - 2*(silk_margin + pcb_W*0.03), silk_T + 2*overlap], center=true);
  }
  translate([-pcb_L*0.22, -pcb_W*0.30, pcb_T/2 + silk_T/2 - overlap])
    cube([pcb_L*0.18, pcb_W*0.03, silk_T], center=true);
  translate([pcb_L*0.20, pcb_W*0.30, pcb_T/2 + silk_T/2 - overlap])
    cube([pcb_L*0.10, pcb_W*0.03, silk_T], center=true);
}

// Mainboard Complete
module mainboard_complete() {
  union() {
    pcb_with_holes();
    connectors();
    heatsinks();
    ic_packages();
    silkscreen_markings();
  }
}

// Render the complete mainboard
mainboard_complete();