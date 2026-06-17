// Parameters
pcb_length = 123.0; //[60.0:246.0:1]
pcb_width = 100.0; //[50.0:200.0:1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_fillet_radius = 6.0; //[2.0:12.0:0.5]
mount_hole_diameter = 3.2; //[2.0:6.0:0.1]
mount_hole_edge_offset_x = 6.0; //[3.0:15.0:0.5]
mount_hole_edge_offset_y = 6.0; //[3.0:15.0:0.5]
hole_clearance_extra = 0.2; //[0.0:0.6:0.05]
hole_cut_height_extra = 2.0; //[0.5:5.0:0.5]
silkscreen_height = 0.15; //[0.05:0.4:0.05]
silkscreen_margin = 4.0; //[1.0:10.0:0.5]
component_base_height = 8.0; //[3.0:20.0:1]
component_overlap = 0.8; //[0.5:2.0:0.1]

// Main PCB Body with Corner Fillets
module pcb_with_corner_fillets() {
  color([0.0, 0.4, 0.2]) // PCB green
  union() {
    translate([0, 0, 0])
      cube([pcb_length, pcb_width, pcb_thickness], center=true);
    translate([pcb_length/2 - corner_fillet_radius, pcb_width/2 - corner_fillet_radius, 0])
      cylinder(r=corner_fillet_radius, h=pcb_thickness, center=true);
    translate([-pcb_length/2 + corner_fillet_radius, pcb_width/2 - corner_fillet_radius, 0])
      cylinder(r=corner_fillet_radius, h=pcb_thickness, center=true);
    translate([pcb_length/2 - corner_fillet_radius, -pcb_width/2 + corner_fillet_radius, 0])
      cylinder(r=corner_fillet_radius, h=pcb_thickness, center=true);
    translate([-pcb_length/2 + corner_fillet_radius, -pcb_width/2 + corner_fillet_radius, 0])
      cylinder(r=corner_fillet_radius, h=pcb_thickness, center=true);
  }
}

// Mounting Holes
module mounting_holes() {
  union() {
    translate([pcb_length/2 - mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0])
      cylinder(r=(mount_hole_diameter + hole_clearance_extra)/2, h=pcb_thickness + hole_cut_height_extra, center=true);
    translate([-pcb_length/2 + mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0])
      cylinder(r=(mount_hole_diameter + hole_clearance_extra)/2, h=pcb_thickness + hole_cut_height_extra, center=true);
    translate([pcb_length/2 - mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0])
      cylinder(r=(mount_hole_diameter + hole_clearance_extra)/2, h=pcb_thickness + hole_cut_height_extra, center=true);
    translate([-pcb_length/2 + mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y, 0])
      cylinder(r=(mount_hole_diameter + hole_clearance_extra)/2, h=pcb_thickness + hole_cut_height_extra, center=true);
  }
}

// Silkscreen Markings
module silkscreen_markings() {
  color([0.85, 0.85, 0.8]) // Off-white for silkscreen
  difference() {
    translate([0, 0, pcb_thickness/2 + silkscreen_height/2])
      cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_height], center=true);
    translate([0, 0, pcb_thickness/2 + silkscreen_height/2])
      cube([pcb_length - 2*(silkscreen_margin + 2), pcb_width - 2*(silkscreen_margin + 2), silkscreen_height + 1], center=true);
  }
}

// Connectors and Components
module connectors_and_components() {
  color([0.1, 0.1, 0.12]) // Black for components
  union() {
    translate([-pcb_length/2 + 14/2 - component_overlap, 0, pcb_thickness/2 + component_base_height/2 - component_overlap])
      cube([14, 12, component_base_height], center=true);
    translate([pcb_length/2 - 18/2 + component_overlap, -pcb_width/2 + 20, pcb_thickness/2 + component_base_height/2 - component_overlap])
      cube([18, 14, component_base_height], center=true);
    translate([0, pcb_width/2 - 10/2 + component_overlap, pcb_thickness/2 + (component_base_height*0.8)/2 - component_overlap])
      cube([40, 10, component_base_height*0.8], center=true);
    translate([-pcb_length/6, 0, pcb_thickness/2 + (component_base_height*0.6)/2 - component_overlap])
      cube([20, 20, component_base_height*0.6], center=true);
    translate([pcb_length/6, -pcb_width/6, pcb_thickness/2 + (component_base_height*0.9)/2 - component_overlap])
      cylinder(r=5, h=component_base_height*0.9, center=true);
  }
}

// Complete PCB Model
difference() {
  pcb_with_corner_fillets();
  mounting_holes();
}
union() {
  silkscreen_markings();
  connectors_and_components();
}