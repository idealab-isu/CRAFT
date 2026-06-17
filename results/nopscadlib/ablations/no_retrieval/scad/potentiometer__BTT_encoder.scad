// Parameters
body_length = 12; //[6:24:1]
body_width = 11; //[6:22:1]
body_height = 6; //[3:12:1]
shaft_diameter = 6; //[3:12:0.5]
shaft_height = 10; //[5:20:1]
collar_diameter = 8; //[4:16:0.5]
collar_height = 2; //[1:6:0.5]
lead_thickness = 0.5; //[0.25:1:0.05]
lead_width = 1; //[0.5:2:0.1]
lead_length = 4; //[2:10:0.5]
lead_pitch = 2.54; //[1.27:5.08:0.01]
lead_row_offset = 1.5; //[0.5:4:0.1]
shaft_flat_depth = 0.8; //[0.2:2:0.1]
shaft_flat_width = 4; //[2:8:0.5]
overlap = 1; //[0.5:2:0.1]
terminal_bend_length = 2; //[1:6:0.5]
anti_rotation_tab_length = 3; //[1.5:8:0.5]
anti_rotation_tab_width = 2; //[1:6:0.5]
anti_rotation_tab_thickness = 1; //[0.5:3:0.5]
mounting_thread_diameter = 7; //[4:14:0.5]
mounting_thread_height = 1.5; //[0.5:4:0.5]
chamfer_amount = 0.6; //[0.2:1.5:0.1]

// Main body with chamfers
module main_body() {
  difference() {
    cube([body_length, body_width, body_height], center=true);
    translate([0, 0, 0])
      cube([body_length - 2*chamfer_amount, body_width - 2*chamfer_amount, body_height - 2*chamfer_amount], center=true);
  }
}

// Bushing collar
module bushing_collar() {
  translate([0, 0, body_height/2 + collar_height/2 - overlap])
    cylinder(h=collar_height, r=collar_diameter/2, center=true);
}

// Shaft with flat
module shaft_with_flat() {
  difference() {
    translate([0, 0, body_height/2 + collar_height + shaft_height/2 - overlap])
      cylinder(h=shaft_height, r=shaft_diameter/2, center=true);
    translate([shaft_diameter/2 - shaft_flat_depth + shaft_diameter/2, 0, body_height/2 + collar_height + shaft_height/2 - overlap])
      cube([shaft_diameter, shaft_flat_width, shaft_height + collar_height + body_height], center=true);
  }
}

// Mounting thread detail
module mounting_thread_detail() {
  translate([0, 0, body_height/2 + mounting_thread_height/2 - overlap])
    cylinder(h=mounting_thread_height, r=mounting_thread_diameter/2, center=true);
}

// Anti-rotation tab
module anti_rotation_tab() {
  translate([collar_diameter/2 + anti_rotation_tab_length/2 - overlap, 0, body_height/2 + anti_rotation_tab_thickness/2 - overlap])
    cube([anti_rotation_tab_length, anti_rotation_tab_width, anti_rotation_tab_thickness], center=true);
}

// Terminals
module terminals() {
  union() {
    translate([body_length/2 + lead_length/2 - overlap, lead_row_offset - lead_pitch, -body_height/2 + lead_thickness/2 + overlap])
      cube([lead_length, lead_width, lead_thickness], center=true);
    translate([body_length/2 + lead_length/2 - overlap, lead_row_offset, -body_height/2 + lead_thickness/2 + overlap])
      cube([lead_length, lead_width, lead_thickness], center=true);
    translate([body_length/2 + lead_length/2 - overlap, lead_row_offset + lead_pitch, -body_height/2 + lead_thickness/2 + overlap])
      cube([lead_length, lead_width, lead_thickness], center=true);
    translate([body_length/2 + lead_thickness/2 - overlap, lead_row_offset - lead_pitch, -body_height/2 - terminal_bend_length/2 + overlap])
      cube([lead_thickness, lead_width, terminal_bend_length], center=true);
    translate([body_length/2 + lead_thickness/2 - overlap, lead_row_offset, -body_height/2 - terminal_bend_length/2 + overlap])
      cube([lead_thickness, lead_width, terminal_bend_length], center=true);
    translate([body_length/2 + lead_thickness/2 - overlap, lead_row_offset + lead_pitch, -body_height/2 - terminal_bend_length/2 + overlap])
      cube([lead_thickness, lead_width, terminal_bend_length], center=true);
    translate([body_length/2 + lead_thickness/2 - overlap, lead_row_offset, -body_height/2 + lead_thickness/2 + overlap])
      cube([lead_thickness, 2*lead_pitch + lead_width, lead_thickness], center=true);
  }
}

// Complete model
module complete_model() {
  union() {
    main_body();
    bushing_collar();
    mounting_thread_detail();
    anti_rotation_tab();
    terminals();
    shaft_with_flat();
  }
}

// Render the complete model
complete_model();