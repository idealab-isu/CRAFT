// Parameters
pcb_L = 68.58; //[34.29:137.16:0.01]
pcb_W = 53.34; //[26.67:106.68:0.01]
pcb_T = 1.6; //[0.8:3.2:0.1]
corner_R = 3.0; //[1.5:6.0:0.1]
hole_d = 3.2; //[2.0:4.5:0.1]
hole_edge_margin = 4.0; //[2.0:8.0:0.1]
silk_T = 0.2; //[0.05:0.5:0.05]
silk_inset = 1.0; //[0.5:3.0:0.1]
header_L = 50.0; //[25.0:100.0:0.5]
header_W = 5.0; //[3.0:10.0:0.1]
header_H = 8.5; //[4.0:15.0:0.1]
usb_L = 8.0; //[5.0:16.0:0.1]
usb_W = 7.5; //[5.0:14.0:0.1]
usb_H = 3.2; //[2.0:6.0:0.1]
ic1_L = 10.0; //[5.0:20.0:0.1]
ic1_W = 10.0; //[5.0:20.0:0.1]
ic1_H = 1.2; //[0.6:3.0:0.1]
ic2_L = 8.0; //[4.0:16.0:0.1]
ic2_W = 6.0; //[3.0:12.0:0.1]
ic2_H = 1.1; //[0.6:3.0:0.1]
led_r = 1.0; //[0.5:2.5:0.1]
led_h = 1.2; //[0.6:3.0:0.1]
button_L = 6.0; //[3.0:12.0:0.1]
button_W = 6.0; //[3.0:12.0:0.1]
button_H = 3.5; //[2.0:8.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]

// PCB with rounded corners and mounting holes
module pcb_with_mounting_holes() {
  difference() {
    // Main PCB body
    color([0.0, 0.4, 0.2]) // Green PCB
    cube([pcb_L, pcb_W, pcb_T], center=true);

    // Edge rounding cutouts
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (pcb_L/2 - corner_R), y * (pcb_W/2 - corner_R), 0])
        difference() {
          cube([corner_R*2, corner_R*2, pcb_T + 2*overlap], center=true);
          cylinder(r=corner_R, h=pcb_T + 2*overlap, center=true);
        }
    }

    // Mounting holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (pcb_L/2 - hole_edge_margin), y * (pcb_W/2 - hole_edge_margin), 0])
        cylinder(r=hole_d/2, h=pcb_T + 2*overlap, center=true);
    }
  }
}

// Silkscreen markings
module silkscreen_markings() {
  color("White")
  translate([0, 0, pcb_T/2 + silk_T/2 - overlap])
    cube([pcb_L - 2*silk_inset, pcb_W - 2*silk_inset, silk_T], center=true);
}

// Headers
module connectors_headers() {
  color("Black")
  translate([0, -pcb_W/2 + header_W/2, pcb_T/2 + header_H/2 - overlap])
    cube([header_L, header_W, header_H], center=true);
  translate([0, pcb_W/2 - header_W/2, pcb_T/2 + header_H/2 - overlap])
    cube([header_L, header_W, header_H], center=true);
}

// USB Connector
module usb_connector() {
  color("Silver")
  translate([-pcb_L/2 + usb_L/2, 0, pcb_T/2 + usb_H/2 - overlap])
    cube([usb_L, usb_W, usb_H], center=true);
}

// IC Packages
module ic_packages() {
  color("DimGray")
  translate([0, 0, pcb_T/2 + ic1_H/2 - overlap])
    cube([ic1_L, ic1_W, ic1_H], center=true);
  translate([pcb_L/2 - (usb_L + ic2_L/2), 0, pcb_T/2 + ic2_H/2 - overlap])
    cube([ic2_L, ic2_W, ic2_H], center=true);
}

// LEDs
module leds() {
  color("Red")
  translate([pcb_L/2 - (hole_edge_margin + led_r), pcb_W/2 - (hole_edge_margin + led_r), pcb_T/2 + led_h/2 - overlap])
    cylinder(r=led_r, h=led_h, center=true);
  translate([pcb_L/2 - (hole_edge_margin + led_r), pcb_W/2 - (hole_edge_margin + 3*led_r), pcb_T/2 + led_h/2 - overlap])
    cylinder(r=led_r, h=led_h, center=true);
}

// Buttons
module buttons() {
  color("Blue")
  translate([-pcb_L/2 + (usb_L + button_L/2), pcb_W/2 - (hole_edge_margin + button_W/2), pcb_T/2 + button_H/2 - overlap])
    cube([button_L, button_W, button_H], center=true);
  translate([-pcb_L/2 + (usb_L + button_L/2), -pcb_W/2 + (hole_edge_margin + button_W/2), pcb_T/2 + button_H/2 - overlap])
    cube([button_L, button_W, button_H], center=true);
}

// Complete board assembly
module complete_board_union() {
  union() {
    pcb_with_mounting_holes();
    silkscreen_markings();
    connectors_headers();
    usb_connector();
    ic_packages();
    leds();
    buttons();
  }
}

// Final output
complete_board_union();