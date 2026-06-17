// Parameters
pcb_length = 85; //[42.5:170:0.5]
pcb_width = 56; //[28:112:0.5]
pcb_thickness = 1.4; //[0.7:2.8:0.1]
corner_radius = 3; //[1.5:6:0.5]
mount_hole_diameter = 2.75; //[2:4:0.05]
mount_hole_edge_offset_x = 3.5; //[2:7:0.25]
mount_hole_edge_offset_y = 3.5; //[2:7:0.25]
hole_cut_extra_height = 2; //[1:5:0.5]
overlap = 1; //[0.5:2:0.1]
connector_height = 12; //[6:24:0.5]
usb_block_length = 16; //[8:32:0.5]
usb_block_width = 14; //[7:28:0.5]
usb_block_height = 10; //[5:20:0.5]
header_length = 52; //[26:80:0.5]
header_width = 6; //[3:12:0.25]
header_height = 8; //[4:16:0.5]
silkscreen_thickness = 0.2; //[0.1:0.6:0.05]
silkscreen_margin = 2; //[1:5:0.25]

// Main PCB Body with Rounded Corners
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  difference() {
    union() {
      translate([0, 0, 0])
        cube([pcb_length, pcb_width, pcb_thickness], center=true);
      translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
        cylinder(r=corner_radius, h=pcb_thickness, center=true);
      translate([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0])
        cylinder(r=corner_radius, h=pcb_thickness, center=true);
      translate([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0])
        cylinder(r=corner_radius, h=pcb_thickness, center=true);
      translate([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0])
        cylinder(r=corner_radius, h=pcb_thickness, center=true);
    }
    // Mounting Holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (pcb_length/2 - mount_hole_edge_offset_x), y * (pcb_width/2 - mount_hole_edge_offset_y), 0])
        cylinder(r=mount_hole_diameter/2, h=pcb_thickness + hole_cut_extra_height, center=true);
    }
  }
}

// Connectors Placeholder
module connectors_placeholder() {
  color([0.85, 0.85, 0.8]) // Off-white for connectors
  union() {
    translate([pcb_length/2 + usb_block_length/2 - overlap, 0, pcb_thickness/2 + usb_block_height/2 - overlap])
      cube([usb_block_length, usb_block_width, usb_block_height], center=true);
    translate([0, pcb_width/2 - header_width/2 + overlap, pcb_thickness/2 + header_height/2 - overlap])
      cube([header_length, header_width, header_height], center=true);
  }
}

// Silkscreen Details
module silkscreen_details() {
  color([1, 1, 1]) // White for silkscreen
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
    cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
}

// Final Assembly
module final_assembly() {
  union() {
    pcb_main_body();
    connectors_placeholder();
    silkscreen_details();
  }
}

// Render the final output
final_assembly();