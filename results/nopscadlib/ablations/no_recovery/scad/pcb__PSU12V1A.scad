// Parameters
pcb_length = 67; //[33.5:134:0.5]
pcb_width = 31; //[15.5:62:0.5]
pcb_thickness = 1.7; //[0.8:3.4:0.1]
silkscreen_thickness = 0.05; //[0.02:0.2:0.01]
copper_thickness = 0.035; //[0.017:0.105:0.001]
layer_inset = 0.5; //[0.2:2:0.1]
overlap = 0.8; //[0.5:2:0.1]
mounting_hole_diameter = 3.2; //[2:6:0.1]
mounting_hole_edge_offset = 3.5; //[2:10:0.1]
connector_placeholder_size_x = 10; //[5:25:0.5]
connector_placeholder_size_y = 6; //[3:20:0.5]
connector_placeholder_size_z = 5; //[2:20:0.5]
component_placeholder_size_x = 8; //[3:30:0.5]
component_placeholder_size_y = 8; //[3:30:0.5]
component_placeholder_size_z = 4; //[1:20:0.5]
edge_chamfer_size = 0.8; //[0:3:0.1]

// Geometry
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

module silkscreen_markings() {
  color("White") // White for silkscreen
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
    cube([pcb_length - 2*layer_inset, pcb_width - 2*layer_inset, silkscreen_thickness], center=true);
}

module copper_pours() {
  color([0.72, 0.45, 0.2]) // Copper color
  translate([0, 0, -pcb_thickness/2 - copper_thickness/2 + overlap])
    cube([pcb_length - 2*layer_inset, pcb_width - 2*layer_inset, copper_thickness], center=true);
}

module connectors() {
  color([0.85, 0.85, 0.8]) // Off-white for connectors
  translate([0, 0, pcb_thickness/2 + connector_placeholder_size_z/2 - overlap])
    cube([connector_placeholder_size_x, connector_placeholder_size_y, connector_placeholder_size_z], center=true);
}

module components() {
  color([0.1, 0.1, 0.6]) // Blue for components
  translate([pcb_length/4, 0, pcb_thickness/2 + component_placeholder_size_z/2 - overlap])
    cube([component_placeholder_size_x, component_placeholder_size_y, component_placeholder_size_z], center=true);
}

// Final PCB assembly
module pcb_complete_union() {
  union() {
    pcb_main_body();
    silkscreen_markings();
    copper_pours();
    connectors();
    components();
  }
}

// Render the final PCB
pcb_complete_union();