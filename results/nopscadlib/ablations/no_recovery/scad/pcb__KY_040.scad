// Parameters
pcb_length = 26.3; //[13.15:52.6:0.1]
pcb_width = 19.5; //[9.75:39:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 2.0; //[0.5:4.0:0.1]
corner_overlap = 0.8; //[0.5:2.0:0.1]
mount_hole_diameter = 3.0; //[1.5:6.0:0.1]
mount_hole_edge_offset_x = 3.5; //[2.0:7.0:0.1]
mount_hole_edge_offset_y = 3.5; //[2.0:7.0:0.1]
pad_diameter = 1.6; //[0.8:3.2:0.1]
pad_height = 0.2; //[0.1:1.0:0.1]
pad_pitch = 2.54; //[2.0:5.08:0.01]
pad_count = 5; //[3:8:1]
pad_row_edge_offset_x = 3.0; //[1.5:6.0:0.1]
pad_row_center_y = 0.0; //[-5.0:5.0:0.1]
encoder_outline_length = 14.0; //[8.0:20.0:0.1]
encoder_outline_width = 14.0; //[8.0:20.0:0.1]
encoder_outline_height = 0.4; //[0.1:2.0:0.1]
encoder_center_x = 5.0; //[-5.0:10.0:0.1]
encoder_center_y = 0.0; //[-5.0:5.0:0.1]
silk_inset = 0.6; //[0.2:1.5:0.1]
silk_line_width = 0.4; //[0.2:1.0:0.1]
silk_height = 0.15; //[0.05:0.5:0.05]
union_overlap = 0.8; //[0.5:2.0:0.1]

// PCB Board with Rounded Corners
module pcb_board() {
  difference() {
    intersection() {
      union() {
        translate([0, 0, 0])
          cube([pcb_length, pcb_width, pcb_thickness], center=true);
        hull() {
          translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
            cylinder(r=corner_radius, h=pcb_thickness + 2*corner_overlap, center=true);
          translate([pcb_length/2 - corner_radius, -(pcb_width/2 - corner_radius), 0])
            cylinder(r=corner_radius, h=pcb_thickness + 2*corner_overlap, center=true);
          translate([-(pcb_length/2 - corner_radius), pcb_width/2 - corner_radius, 0])
            cylinder(r=corner_radius, h=pcb_thickness + 2*corner_overlap, center=true);
          translate([-(pcb_length/2 - corner_radius), -(pcb_width/2 - corner_radius), 0])
            cylinder(r=corner_radius, h=pcb_thickness + 2*corner_overlap, center=true);
        }
      }
    }
    // Mounting Holes
    union() {
      translate([pcb_length/2 - mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y, 0])
        cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2*union_overlap, center=true);
      translate([pcb_length/2 - mount_hole_edge_offset_x, -(pcb_width/2 - mount_hole_edge_offset_y), 0])
        cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2*union_overlap, center=true);
      translate([-(pcb_length/2 - mount_hole_edge_offset_x), pcb_width/2 - mount_hole_edge_offset_y, 0])
        cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2*union_overlap, center=true);
      translate([-(pcb_length/2 - mount_hole_edge_offset_x), -(pcb_width/2 - mount_hole_edge_offset_y), 0])
        cylinder(r=mount_hole_diameter/2, h=pcb_thickness + 2*union_overlap, center=true);
    }
  }
}

// Pin Header Pads
module pin_header_pads() {
  for (i = [0:pad_count-1]) {
    translate([-(pcb_length/2 - pad_row_edge_offset_x) + (i - (pad_count-1)/2)*pad_pitch, pad_row_center_y, pcb_thickness/2 + pad_height/2 - union_overlap/2])
      cylinder(r=pad_diameter/2, h=pad_height, center=true);
  }
}

// Encoder Body Outline
module encoder_body_outline() {
  translate([encoder_center_x, encoder_center_y, pcb_thickness/2 + encoder_outline_height/2 - union_overlap/2])
    cube([encoder_outline_length, encoder_outline_width, encoder_outline_height], center=true);
}

// Silkscreen Outline
module silkscreen_outline() {
  difference() {
    translate([0, 0, pcb_thickness/2 + silk_height/2 - union_overlap/2])
      cube([pcb_length - 2*silk_inset, pcb_width - 2*silk_inset, silk_height], center=true);
    translate([0, 0, pcb_thickness/2 + silk_height/2 - union_overlap/2])
      cube([pcb_length - 2*(silk_inset + silk_line_width), pcb_width - 2*(silk_inset + silk_line_width), silk_height + 2*union_overlap], center=true);
  }
}

// Complete PCB Model
module pcb_complete_model() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  union() {
    pcb_board();
    pin_header_pads();
    encoder_body_outline();
    silkscreen_outline();
  }
}

// Render the complete model
pcb_complete_model();