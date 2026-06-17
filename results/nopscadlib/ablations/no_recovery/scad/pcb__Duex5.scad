// Parameters
pcb_L = 123; //[61.5:246:0.5]
pcb_W = 100; //[50:200:0.5]
pcb_T = 1.6; //[0.8:3.2:0.1]
corner_R = 6; //[2:12:0.5]
hole_d = 3.2; //[2.4:5:0.1]
hole_edge_offset = 6; //[3:12:0.5]
standoff_d = 8; //[5:16:0.5]
standoff_h = 10; //[4:25:0.5]
standoff_overlap = 0.8; //[0.5:2:0.1]
conn_h = 10; //[6:20:0.5]
conn_overlap = 0.8; //[0.5:2:0.1]
chip_h = 2.5; //[1:6:0.1]
chip_overlap = 0.6; //[0.5:2:0.1]
heatsink_h = 12; //[6:30:0.5]
heatsink_overlap = 0.8; //[0.5:2:0.1]
silk_T = 0.2; //[0.1:0.6:0.05]
silk_overlap = 0.2; //[0.1:1:0.05]

// Base Shapes
module pcb_core_box() {
  cube([pcb_L - 2*corner_R, pcb_W - 2*corner_R, pcb_T], center=true);
}

module corner_cyl(pos) {
  translate(pos)
    cylinder(r=corner_R, h=pcb_T, center=true);
}

module mount_hole(pos) {
  translate(pos)
    cylinder(r=hole_d/2, h=pcb_T + 2, center=true);
}

module standoff(pos) {
  translate(pos)
    cylinder(r=standoff_d/2, h=standoff_h, center=true);
}

module connector(size, pos) {
  translate(pos)
    cube(size, center=true);
}

module chip(size, pos) {
  translate(pos)
    cube(size, center=true);
}

module heatsink(size, pos) {
  translate(pos)
    cube(size, center=true);
}

module silk_patch(size, pos) {
  translate(pos)
    cube(size, center=true);
}

// Operations
module corner_rounding() {
  union() {
    pcb_core_box();
    corner_cyl([pcb_L/2 - corner_R, pcb_W/2 - corner_R, 0]);
    corner_cyl([-pcb_L/2 + corner_R, pcb_W/2 - corner_R, 0]);
    corner_cyl([-pcb_L/2 + corner_R, -pcb_W/2 + corner_R, 0]);
    corner_cyl([pcb_L/2 - corner_R, -pcb_W/2 + corner_R, 0]);
  }
}

module pcb_board() {
  difference() {
    corner_rounding();
    mount_hole([pcb_L/2 - hole_edge_offset, pcb_W/2 - hole_edge_offset, 0]);
    mount_hole([-pcb_L/2 + hole_edge_offset, pcb_W/2 - hole_edge_offset, 0]);
    mount_hole([-pcb_L/2 + hole_edge_offset, -pcb_W/2 + hole_edge_offset, 0]);
    mount_hole([pcb_L/2 - hole_edge_offset, -pcb_W/2 + hole_edge_offset, 0]);
  }
}

module connectors() {
  union() {
    connector([14, 12, conn_h], [-pcb_L/2 + 14/2 - 1, 0, pcb_T/2 + conn_h/2 - conn_overlap]);
    connector([20, 14, conn_h], [pcb_L/2 - 20/2 + 1, -pcb_W/4, pcb_T/2 + conn_h/2 - conn_overlap]);
    connector([60, 10, conn_h], [0, pcb_W/2 - 10/2 + 1, pcb_T/2 + conn_h/2 - conn_overlap]);
  }
}

module chips() {
  union() {
    chip([18, 18, chip_h], [-pcb_L/6, 0, pcb_T/2 + chip_h/2 - chip_overlap]);
    chip([10, 10, chip_h], [pcb_L/6, pcb_W/6, pcb_T/2 + chip_h/2 - chip_overlap]);
    chip([10, 10, chip_h], [pcb_L/6, 0, pcb_T/2 + chip_h/2 - chip_overlap]);
    chip([10, 10, chip_h], [pcb_L/6, -pcb_W/6, pcb_T/2 + chip_h/2 - chip_overlap]);
  }
}

module heatsinks() {
  union() {
    heatsink([14, 14, heatsink_h], [pcb_L/6, pcb_W/6, pcb_T/2 + heatsink_h/2 - heatsink_overlap]);
    heatsink([14, 14, heatsink_h], [pcb_L/6, 0, pcb_T/2 + heatsink_h/2 - heatsink_overlap]);
    heatsink([14, 14, heatsink_h], [pcb_L/6, -pcb_W/6, pcb_T/2 + heatsink_h/2 - heatsink_overlap]);
  }
}

module silkscreen_text() {
  union() {
    silk_patch([pcb_L/3, pcb_W/6, silk_T], [-pcb_L/6, -pcb_W/4, pcb_T/2 + silk_T/2 - silk_overlap]);
    silk_patch([pcb_L/4, pcb_W/10, silk_T], [pcb_L/6, pcb_W/4, pcb_T/2 + silk_T/2 - silk_overlap]);
  }
}

module standoffs() {
  union() {
    standoff([pcb_L/2 - hole_edge_offset, pcb_W/2 - hole_edge_offset, -pcb_T/2 - standoff_h/2 + standoff_overlap]);
    standoff([-pcb_L/2 + hole_edge_offset, pcb_W/2 - hole_edge_offset, -pcb_T/2 - standoff_h/2 + standoff_overlap]);
    standoff([-pcb_L/2 + hole_edge_offset, -pcb_W/2 + hole_edge_offset, -pcb_T/2 - standoff_h/2 + standoff_overlap]);
    standoff([pcb_L/2 - hole_edge_offset, -pcb_W/2 + hole_edge_offset, -pcb_T/2 - standoff_h/2 + standoff_overlap]);
  }
}

// Final Model
module complete_model() {
  union() {
    pcb_board();
    connectors();
    chips();
    heatsinks();
    silkscreen_text();
    standoffs();
  }
}

// Render the complete model
color([0.0, 0.4, 0.2]) complete_model(); // PCB in green