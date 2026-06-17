// Parameters
pcb_length = 203.2; //[101.6:406.4:0.1]
pcb_width = 49.53; //[24.765:99.06:0.01]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 3.0; //[1.5:6.0:0.1]
mount_hole_diameter = 3.2; //[2.0:5.0:0.1]
mount_hole_edge_offset_x = 6.0; //[3.0:12.0:0.1]
mount_hole_edge_offset_y = 6.0; //[3.0:12.0:0.1]
hole_clearance_height = 6.0; //[3.0:12.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
silkscreen_thickness = 0.2; //[0.1:0.5:0.05]
silkscreen_margin = 2.0; //[1.0:5.0:0.1]
connector_block_length = 18.0; //[9.0:36.0:0.5]
connector_block_width = 12.0; //[6.0:24.0:0.5]
connector_block_height = 10.0; //[5.0:20.0:0.5]
component_chip_length = 20.0; //[10.0:40.0:0.5]
component_chip_width = 20.0; //[10.0:40.0:0.5]
component_chip_height = 3.0; //[1.5:6.0:0.1]
component_cap_radius = 4.0; //[2.0:8.0:0.1]
component_cap_height = 8.0; //[4.0:16.0:0.5]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

// Mounting Holes
module mounting_holes() {
  union() {
    translate([-pcb_length/2 + mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0])
      cylinder(r=mount_hole_diameter/2, h=hole_clearance_height, center=true);
    translate([pcb_length/2 - mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0])
      cylinder(r=mount_hole_diameter/2, h=hole_clearance_height, center=true);
    translate([-pcb_length/2 + mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0])
      cylinder(r=mount_hole_diameter/2, h=hole_clearance_height, center=true);
    translate([pcb_length/2 - mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0])
      cylinder(r=mount_hole_diameter/2, h=hole_clearance_height, center=true);
  }
}

// Corner Fillets
module corner_fillet() {
  union() {
    difference() {
      translate([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0])
        cube([corner_radius*2, corner_radius*2, hole_clearance_height], center=true);
      translate([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0])
        cylinder(r=corner_radius, h=hole_clearance_height, center=true);
    }
    difference() {
      translate([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0])
        cube([corner_radius*2, corner_radius*2, hole_clearance_height], center=true);
      translate([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0])
        cylinder(r=corner_radius, h=hole_clearance_height, center=true);
    }
    difference() {
      translate([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0])
        cube([corner_radius*2, corner_radius*2, hole_clearance_height], center=true);
      translate([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0])
        cylinder(r=corner_radius, h=hole_clearance_height, center=true);
    }
    difference() {
      translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
        cube([corner_radius*2, corner_radius*2, hole_clearance_height], center=true);
      translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
        cylinder(r=corner_radius, h=hole_clearance_height, center=true);
    }
  }
}

// Silkscreen Markings
module silkscreen_markings() {
  color("White")
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
    cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
}

// Connectors
module connectors() {
  color([0.5, 0.5, 0.5]) // Light gray connectors
  union() {
    translate([-pcb_length/2 + connector_block_length/2, 0, pcb_thickness/2 + connector_block_height/2 - overlap])
      cube([connector_block_length, connector_block_width, connector_block_height], center=true);
    translate([pcb_length/2 - connector_block_length/2, 0, pcb_thickness/2 + connector_block_height/2 - overlap])
      cube([connector_block_length, connector_block_width, connector_block_height], center=true);
  }
}

// Components
module components() {
  color([0.2, 0.2, 0.2]) // Dark gray components
  union() {
    translate([0, 0, pcb_thickness/2 + component_chip_height/2 - overlap])
      cube([component_chip_length, component_chip_width, component_chip_height], center=true);
    translate([-pcb_length/2 + mount_hole_edge_offset_x + component_cap_radius*2, pcb_width/2 - mount_hole_edge_offset_y - component_cap_radius*2, pcb_thickness/2 + component_cap_height/2 - overlap])
      cylinder(r=component_cap_radius, h=component_cap_height, center=true);
    translate([pcb_length/2 - mount_hole_edge_offset_x - component_cap_radius*2, pcb_width/2 - mount_hole_edge_offset_y - component_cap_radius*2, pcb_thickness/2 + component_cap_height/2 - overlap])
      cylinder(r=component_cap_radius, h=component_cap_height, center=true);
  }
}

// Complete Model
module complete_model() {
  difference() {
    pcb_main_body();
    mounting_holes();
    corner_fillet();
  }
  silkscreen_markings();
  connectors();
  components();
}

// Render the complete model
complete_model();