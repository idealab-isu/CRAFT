// Parameters
pcb_length = 35.56; //[17.78:71.12:0.01]
pcb_width = 25.4; //[12.7:50.8:0.01]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 2.0; //[0.5:5.0:0.1]
mount_hole_diameter = 3.2; //[2.0:5.0:0.1]
mount_hole_edge_offset = 3.5; //[2.0:7.0:0.1]
copper_thickness = 0.035; //[0.01:0.1:0.005]
silkscreen_thickness = 0.02; //[0.01:0.1:0.005]
edge_finger_length = 6.0; //[3.0:12.0:0.1]
edge_finger_width = 1.2; //[0.6:2.5:0.1]
edge_finger_count = 8; //[2:20:1]
edge_finger_pitch = 2.0; //[1.0:3.5:0.1]
edge_finger_edge_margin = 3.0; //[1.0:6.0:0.1]
trace_width = 0.6; //[0.2:2.0:0.1]
pad_diameter = 1.6; //[0.8:3.5:0.1]
pad_count = 4; //[1:12:1]
pad_row_y = 6.0; //[2.0:10.0:0.1]
pad_pitch_x = 5.0; //[2.0:10.0:0.1]
silk_border_inset = 1.0; //[0.5:3.0:0.1]
silk_border_width = 0.4; //[0.2:1.0:0.05]

// PCB Body with Rounded Corners
module pcb_body() {
  difference() {
    color([0.0, 0.4, 0.2]) // PCB color
    cube([pcb_length, pcb_width, pcb_thickness], center=true);
    translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
      cylinder(r=corner_radius, h=pcb_thickness*2, center=true);
    translate([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0])
      cylinder(r=corner_radius, h=pcb_thickness*2, center=true);
    translate([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0])
      cylinder(r=corner_radius, h=pcb_thickness*2, center=true);
    translate([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0])
      cylinder(r=corner_radius, h=pcb_thickness*2, center=true);
  }
}

// Mounting Holes
module mounting_holes() {
  difference() {
    pcb_body();
    translate([pcb_length/2 - mount_hole_edge_offset, pcb_width/2 - mount_hole_edge_offset, 0])
      cylinder(r=mount_hole_diameter/2, h=pcb_thickness*3, center=true);
    translate([pcb_length/2 - mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset, 0])
      cylinder(r=mount_hole_diameter/2, h=pcb_thickness*3, center=true);
    translate([-pcb_length/2 + mount_hole_edge_offset, pcb_width/2 - mount_hole_edge_offset, 0])
      cylinder(r=mount_hole_diameter/2, h=pcb_thickness*3, center=true);
    translate([-pcb_length/2 + mount_hole_edge_offset, -pcb_width/2 + mount_hole_edge_offset, 0])
      cylinder(r=mount_hole_diameter/2, h=pcb_thickness*3, center=true);
  }
}

// Silkscreen Markings
module silkscreen_markings() {
  difference() {
    color([1, 1, 1]) // Silkscreen color
    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - silkscreen_thickness*0.2])
      cube([pcb_length - 2*silk_border_inset, pcb_width - 2*silk_border_inset, silkscreen_thickness], center=true);
    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - silkscreen_thickness*0.2])
      cube([pcb_length - 2*(silk_border_inset + silk_border_width), pcb_width - 2*(silk_border_inset + silk_border_width), silkscreen_thickness*3], center=true);
  }
}

// Copper Pads and Traces
module copper_pads_traces() {
  union() {
    color([0.72, 0.45, 0.2]) // Copper color
    translate([0, 0, pcb_thickness/2 + copper_thickness/2 - copper_thickness*0.2])
      cube([pcb_length*0.6, trace_width, copper_thickness], center=true);
    translate([-pcb_length*0.1, 0, pcb_thickness/2 + copper_thickness/2 - copper_thickness*0.2])
      cube([trace_width, pcb_width*0.5, copper_thickness], center=true);
    for (i = [0:pad_count-1]) {
      translate([-(pad_count-1)*pad_pitch_x/2 + i*pad_pitch_x, pad_row_y, pcb_thickness/2 + copper_thickness/2 - copper_thickness*0.2])
        cylinder(r=pad_diameter/2, h=copper_thickness, center=true);
      translate([-(pad_count-1)*pad_pitch_x/2 + i*pad_pitch_x, -pad_row_y, pcb_thickness/2 + copper_thickness/2 - copper_thickness*0.2])
        cylinder(r=pad_diameter/2, h=copper_thickness, center=true);
    }
  }
}

// Edge Connector Fingers
module edge_connector_fingers() {
  union() {
    color([0.72, 0.45, 0.2]) // Copper color
    for (i = [0:edge_finger_count-1]) {
      translate([-pcb_length/2 + edge_finger_length/2 - copper_thickness, -(edge_finger_count-1)*edge_finger_pitch/2 + i*edge_finger_pitch, pcb_thickness/2 + copper_thickness/2 - copper_thickness*0.2])
        cube([edge_finger_length, edge_finger_width, copper_thickness], center=true);
    }
  }
}

// Complete PCB Model
module pcb_complete() {
  union() {
    mounting_holes();
    silkscreen_markings();
    copper_pads_traces();
    edge_connector_fingers();
  }
}

// Render the complete PCB
pcb_complete();