// Parameters
pcb_length = 80.4; //[40.2:160.8:0.1]
pcb_width = 36.3; //[18.15:72.6:0.1]
pcb_thickness = 1.5; //[0.8:3:0.1]
corner_radius = 3; //[1.5:6:0.1]
corner_overlap = 0.8; //[0.5:2:0.1]
mount_hole_diameter = 3.2; //[2:5:0.1]
mount_hole_edge_margin_x = 5; //[2.5:10:0.1]
mount_hole_edge_margin_y = 4; //[2:8:0.1]
connector_height = 8; //[4:16:0.1]
connector_depth = 10; //[5:20:0.1]
connector_overlap = 0.8; //[0.5:2:0.1]
component_height = 4; //[2:10:0.1]
component_overlap = 0.6; //[0.5:2:0.1]
silkscreen_thickness = 0.2; //[0.1:0.6:0.05]
silkscreen_overlap = 0.05; //[0.02:0.2:0.01]
silkscreen_margin = 2; //[1:6:0.1]

// Main PCB with rounded corners
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  difference() {
    union() {
      translate([0, 0, 0])
        cube([pcb_length, pcb_width, pcb_thickness], center=true);
      translate([pcb_length/2 - corner_radius + corner_overlap, pcb_width/2 - corner_radius + corner_overlap, 0])
        cylinder(r=corner_radius, h=pcb_thickness, center=true);
      translate([-pcb_length/2 + corner_radius - corner_overlap, pcb_width/2 - corner_radius + corner_overlap, 0])
        cylinder(r=corner_radius, h=pcb_thickness, center=true);
      translate([-pcb_length/2 + corner_radius - corner_overlap, -pcb_width/2 + corner_radius - corner_overlap, 0])
        cylinder(r=corner_radius, h=pcb_thickness, center=true);
      translate([pcb_length/2 - corner_radius + corner_overlap, -pcb_width/2 + corner_radius - corner_overlap, 0])
        cylinder(r=corner_radius, h=pcb_thickness, center=true);
    }
    // Mounting holes
    translate([-pcb_length/2 + mount_hole_edge_margin_x, -pcb_width/2 + mount_hole_edge_margin_y, 0])
      cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2, center=true);
    translate([pcb_length/2 - mount_hole_edge_margin_x, -pcb_width/2 + mount_hole_edge_margin_y, 0])
      cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2, center=true);
    translate([-pcb_length/2 + mount_hole_edge_margin_x, pcb_width/2 - mount_hole_edge_margin_y, 0])
      cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2, center=true);
    translate([pcb_length/2 - mount_hole_edge_margin_x, pcb_width/2 - mount_hole_edge_margin_y, 0])
      cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2, center=true);
  }
}

// Connectors
module connectors() {
  color([0.1, 0.1, 0.6]) // Blue connectors
  union() {
    translate([-pcb_length*0.22, pcb_width/2 - connector_depth/2 + connector_overlap, pcb_thickness/2 + connector_height/2 - connector_overlap])
      cube([pcb_length*0.22, connector_depth, connector_height], center=true);
    translate([pcb_length*0.22, pcb_width/2 - connector_depth/2 + connector_overlap, pcb_thickness/2 + connector_height/2 - connector_overlap])
      cube([pcb_length*0.18, connector_depth, connector_height], center=true);
  }
}

// Components
module components() {
  color([0.85, 0.85, 0.8]) // Off-white components
  union() {
    translate([-pcb_length*0.15, 0, pcb_thickness/2 + component_height/2 - component_overlap])
      cube([pcb_length*0.25, pcb_width*0.25, component_height], center=true);
    translate([pcb_length*0.18, -pcb_width*0.15, pcb_thickness/2 + (component_height*0.8)/2 - component_overlap])
      cube([pcb_length*0.18, pcb_width*0.18, component_height*0.8], center=true);
    translate([pcb_length*0.28, pcb_width*0.12, pcb_thickness/2 + (component_height*0.9)/2 - component_overlap])
      cylinder(r=pcb_width*0.08, h=component_height*0.9, center=true);
  }
}

// Silkscreen
module silkscreen() {
  color([1, 1, 1]) // White silkscreen
  difference() {
    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - silkscreen_overlap])
      cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - silkscreen_overlap])
      cube([pcb_length - 2*(silkscreen_margin + pcb_width*0.03), pcb_width - 2*(silkscreen_margin + pcb_width*0.03), silkscreen_thickness + 2*silkscreen_overlap], center=true);
  }
}

// Complete Mainboard
module complete_mainboard() {
  union() {
    pcb_main_body();
    connectors();
    components();
    silkscreen();
  }
}

// Render the complete mainboard
complete_mainboard();