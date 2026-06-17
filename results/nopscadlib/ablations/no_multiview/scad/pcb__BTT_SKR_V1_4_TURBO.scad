// Parameters
pcb_L = 110; //[55:220:1]
pcb_W = 85; //[42.5:170:1]
pcb_T = 1.6; //[0.8:3.2:0.1]
edge_chamfer = 2; //[0.5:6:0.5]
hole_d = 3.2; //[2:6:0.1]
hole_edge_margin = 6; //[3:15:0.5]
connector_H = 10; //[5:25:1]
connector_overlap = 1; //[0.5:2:0.1]
heatsink_H = 12; //[6:30:1]
heatsink_overlap = 1; //[0.5:2:0.1]
chip_H = 3; //[1:8:0.5]
chip_overlap = 0.8; //[0.5:2:0.1]

// Mainboard PCB with holes and chamfers
module pcb_with_holes_and_chamfers() {
  difference() {
    color([0.0, 0.4, 0.2]) // PCB color
    cube([pcb_L, pcb_W, pcb_T], center=true);
    union() {
      translate([-pcb_L/2 + hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0])
        cylinder(h=pcb_T*3, r=hole_d/2, center=true);
      translate([pcb_L/2 - hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0])
        cylinder(h=pcb_T*3, r=hole_d/2, center=true);
      translate([pcb_L/2 - hole_edge_margin, pcb_W/2 - hole_edge_margin, 0])
        cylinder(h=pcb_T*3, r=hole_d/2, center=true);
      translate([-pcb_L/2 + hole_edge_margin, pcb_W/2 - hole_edge_margin, 0])
        cylinder(h=pcb_T*3, r=hole_d/2, center=true);
    }
    union() {
      translate([-pcb_L/2 + edge_chamfer, -pcb_W/2 + edge_chamfer, 0])
        cube([edge_chamfer*2, edge_chamfer*2, pcb_T*3], center=true);
      translate([pcb_L/2 - edge_chamfer, -pcb_W/2 + edge_chamfer, 0])
        cube([edge_chamfer*2, edge_chamfer*2, pcb_T*3], center=true);
      translate([pcb_L/2 - edge_chamfer, pcb_W/2 - edge_chamfer, 0])
        cube([edge_chamfer*2, edge_chamfer*2, pcb_T*3], center=true);
      translate([-pcb_L/2 + edge_chamfer, pcb_W/2 - edge_chamfer, 0])
        cube([edge_chamfer*2, edge_chamfer*2, pcb_T*3], center=true);
    }
  }
}

// Connectors
module connectors() {
  union() {
    color([0.85, 0.85, 0.8]) // Connector color
    translate([-pcb_L/2 + (pcb_L*0.18)/2 - connector_overlap, 0, pcb_T/2 + connector_H/2 - connector_overlap])
      cube([pcb_L*0.18, pcb_W*0.12, connector_H], center=true);
    translate([pcb_L/2 - (pcb_L*0.22)/2 + connector_overlap, -pcb_W/2 + (pcb_W*0.14)/2 - connector_overlap, pcb_T/2 + (connector_H*1.1)/2 - connector_overlap])
      cube([pcb_L*0.22, pcb_W*0.14, connector_H*1.1], center=true);
    translate([0, pcb_W/2 - (pcb_W*0.08)/2 + connector_overlap, pcb_T/2 + (connector_H*0.7)/2 - connector_overlap])
      cube([pcb_L*0.55, pcb_W*0.08, connector_H*0.7], center=true);
  }
}

// Heatsinks
module heatsinks() {
  union() {
    color([0.4, 0.4, 0.43]) // Heatsink color
    translate([-pcb_L*0.15, -pcb_W*0.05, pcb_T/2 + heatsink_H/2 - heatsink_overlap])
      cube([pcb_L*0.18, pcb_W*0.18, heatsink_H], center=true);
    translate([pcb_L*0.18, pcb_W*0.08, pcb_T/2 + (heatsink_H*0.9)/2 - heatsink_overlap])
      cube([pcb_L*0.16, pcb_W*0.16, heatsink_H*0.9], center=true);
  }
}

// Chips and components
module chips_components() {
  union() {
    color([0.2, 0.2, 0.2]) // Chip color
    translate([0, 0, pcb_T/2 + chip_H/2 - chip_overlap])
      cube([pcb_L*0.18, pcb_W*0.14, chip_H], center=true);
    translate([-pcb_L*0.22, pcb_W*0.18, pcb_T/2 + (chip_H*0.9)/2 - chip_overlap])
      cube([pcb_L*0.10, pcb_W*0.10, chip_H*0.9], center=true);
    translate([-pcb_L*0.10, pcb_W*0.18, pcb_T/2 + (chip_H*0.9)/2 - chip_overlap])
      cube([pcb_L*0.10, pcb_W*0.10, chip_H*0.9], center=true);
    translate([pcb_L*0.02, pcb_W*0.18, pcb_T/2 + (chip_H*0.9)/2 - chip_overlap])
      cube([pcb_L*0.10, pcb_W*0.10, chip_H*0.9], center=true);
    translate([pcb_L*0.14, pcb_W*0.18, pcb_T/2 + (chip_H*0.9)/2 - chip_overlap])
      cube([pcb_L*0.10, pcb_W*0.10, chip_H*0.9], center=true);
  }
}

// Complete mainboard model
module complete_mainboard_model() {
  union() {
    pcb_with_holes_and_chamfers();
    connectors();
    heatsinks();
    chips_components();
    // Silkscreen labels are not visible, so omitted
  }
}

// Render the complete model
complete_mainboard_model();