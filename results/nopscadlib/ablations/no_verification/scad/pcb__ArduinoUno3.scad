// Parameters
pcb_L = 68.58; //[34.29:137.16:0.01]
pcb_W = 53.34; //[26.67:106.68:0.01]
pcb_T = 1.6; //[0.8:3.2:0.1]
hole_d = 3.2; //[1.6:6.4:0.1]
hole_edge_margin = 4.0; //[2.0:8.0:0.1]
hole_cut_extra = 0.6; //[0.2:2.0:0.1]
chamfer_size = 2.0; //[0.5:6.0:0.1]
chamfer_overlap = 0.8; //[0.2:2.0:0.1]
silk_T = 0.2; //[0.1:0.6:0.05]
silk_inset = 2.0; //[0.5:6.0:0.1]
header_L = 50.0; //[25.0:100.0:0.1]
header_W = 5.0; //[2.5:10.0:0.1]
header_H = 8.0; //[4.0:16.0:0.1]
header_edge_gap = 3.0; //[1.0:8.0:0.1]
attach_overlap = 0.8; //[0.2:2.0:0.1]
ic_L = 14.0; //[7.0:28.0:0.1]
ic_W = 14.0; //[7.0:28.0:0.1]
ic_H = 2.0; //[1.0:6.0:0.1]
led_r = 1.5; //[0.8:3.5:0.1]
led_H = 1.2; //[0.6:3.0:0.1]
button_L = 6.0; //[3.0:12.0:0.1]
button_W = 6.0; //[3.0:12.0:0.1]
button_H = 3.5; //[1.5:8.0:0.1]

// Main PCB Body
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  cube([pcb_L, pcb_W, pcb_T], center=true);
}

// Mounting Holes
module mounting_hole_cyl(position) {
  translate(position)
    cylinder(r=hole_d/2, h=pcb_T + hole_cut_extra, center=true);
}

module mounting_holes() {
  union() {
    mounting_hole_cyl([pcb_L/2 - hole_edge_margin, pcb_W/2 - hole_edge_margin, 0]);
    mounting_hole_cyl([-pcb_L/2 + hole_edge_margin, pcb_W/2 - hole_edge_margin, 0]);
    mounting_hole_cyl([-pcb_L/2 + hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0]);
    mounting_hole_cyl([pcb_L/2 - hole_edge_margin, -pcb_W/2 + hole_edge_margin, 0]);
  }
}

// Chamfer Cuts
module chamfer_cut(position) {
  translate(position)
    cube([chamfer_size, chamfer_size, pcb_T + hole_cut_extra], center=true);
}

module edge_chamfer() {
  union() {
    chamfer_cut([pcb_L/2 - chamfer_size/2 + chamfer_overlap, pcb_W/2 - chamfer_size/2 + chamfer_overlap, 0]);
    chamfer_cut([-pcb_L/2 + chamfer_size/2 - chamfer_overlap, pcb_W/2 - chamfer_size/2 + chamfer_overlap, 0]);
    chamfer_cut([-pcb_L/2 + chamfer_size/2 - chamfer_overlap, -pcb_W/2 + chamfer_size/2 - chamfer_overlap, 0]);
    chamfer_cut([pcb_L/2 - chamfer_size/2 + chamfer_overlap, -pcb_W/2 + chamfer_size/2 - chamfer_overlap, 0]);
  }
}

// Silkscreen Markings
module silkscreen_markings() {
  color("White")
  translate([0, 0, pcb_T/2 + silk_T/2 - attach_overlap])
    cube([pcb_L - 2*silk_inset, pcb_W - 2*silk_inset, silk_T], center=true);
}

// Connectors Headers
module connectors_headers_left() {
  color("Black")
  translate([0, -pcb_W/2 + header_edge_gap + header_W/2 - attach_overlap, pcb_T/2 + header_H/2 - attach_overlap])
    cube([header_L, header_W, header_H], center=true);
}

module connectors_headers_right() {
  color("Black")
  translate([0, pcb_W/2 - header_edge_gap - header_W/2 + attach_overlap, pcb_T/2 + header_H/2 - attach_overlap])
    cube([header_L, header_W, header_H], center=true);
}

// IC Packages
module ic_packages_main() {
  color("DimGray")
  translate([0, 0, pcb_T/2 + ic_H/2 - attach_overlap])
    cube([ic_L, ic_W, ic_H], center=true);
}

// LEDs and Buttons
module leds_buttons_led1() {
  color("Red")
  translate([-pcb_L/2 + hole_edge_margin + led_r, 0, pcb_T/2 + led_H/2 - attach_overlap])
    cylinder(r=led_r, h=led_H, center=true);
}

module leds_buttons_button1() {
  color("Blue")
  translate([pcb_L/2 - hole_edge_margin - button_L/2, 0, pcb_T/2 + button_H/2 - attach_overlap])
    cube([button_L, button_W, button_H], center=true);
}

// Complete Model
module complete_model() {
  union() {
    difference() {
      pcb_main_body();
      mounting_holes();
      edge_chamfer();
    }
    silkscreen_markings();
    connectors_headers_left();
    connectors_headers_right();
    ic_packages_main();
    leds_buttons_led1();
    leds_buttons_button1();
  }
}

// Render the complete model
complete_model();