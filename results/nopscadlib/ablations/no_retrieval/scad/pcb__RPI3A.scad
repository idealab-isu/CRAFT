$fn = 64;

// Parameters (mm)
pcb_length = 65.0;
pcb_width = 56.0;
pcb_thickness = 1.4;

corner_radius = 3.0;

hole_diameter = 2.8;
hole_edge_offset_x = 3.5;
hole_edge_offset_y = 3.5;
hole_clearance_z = 0.2;

connect_overlap = 1.0;

// Components (simplified but recognizable)
usb_width = 14.0;
usb_depth = 16.0;
usb_height = 7.0;

hdmi_width = 12.0;
hdmi_depth = 12.0;
hdmi_height = 5.0;

gpio_length = 52.0;
gpio_width = 5.0;
gpio_height = 8.5;

chip1_length = 14.0;
chip1_width = 14.0;
chip1_height = 1.6;

chip2_length = 10.0;
chip2_width = 8.0;
chip2_height = 1.4;

silk_depth = 0.2;
silk_margin = 2.0;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Rounded rectangle prism (centered)
module rounded_rect_prism(l, w, h, r) {
  r2 = clamp(r, 0, min(l, w)/2);
  linear_extrude(height=h, center=true)
    offset(r=r2)
      square([l - 2*r2, w - 2*r2], center=true);
}

// PCB Core with Rounded Corners + Mounting Holes
module pcb_core() {
  color([0.0, 0.4, 0.2])
  difference() {
    rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius);

    // Mounting holes (through)
    for (sx = [-1, 1], sy = [-1, 1]) {
      translate([sx*(pcb_length/2 - hole_edge_offset_x),
                 sy*(pcb_width/2 - hole_edge_offset_y),
                 0])
        cylinder(h=pcb_thickness + hole_clearance_z, r=hole_diameter/2, center=true);
    }
  }
}

// USB Connector (right edge, centered in Y)
module usb_connector() {
  color([0.7, 0.7, 0.7])
  translate([ pcb_length/2 + usb_depth/2 - connect_overlap,
              0,
              pcb_thickness/2 + usb_height/2 - connect_overlap ])
    cube([usb_depth, usb_width, usb_height], center=true);
}

// HDMI Connector (left edge, centered in Y)
module hdmi_connector() {
  color([0.7, 0.7, 0.7])
  translate([ -pcb_length/2 - hdmi_depth/2 + connect_overlap,
              0,
              pcb_thickness/2 + hdmi_height/2 - connect_overlap ])
    cube([hdmi_depth, hdmi_width, hdmi_height], center=true);
}

// GPIO Header (top edge in +Y)
module gpio_header() {
  color([0.7, 0.7, 0.7])
  translate([ 0,
              pcb_width/2 + gpio_width/2 - connect_overlap,
              pcb_thickness/2 + gpio_height/2 - connect_overlap ])
    cube([gpio_length, gpio_width, gpio_height], center=true);
}

// Main Chip (center-ish)
module main_chip() {
  color([0.35, 0.35, 0.35])
  translate([ 0,
              0,
              pcb_thickness/2 + chip1_height/2 - connect_overlap ])
    cube([chip1_length, chip1_width, chip1_height], center=true);
}

// Secondary Chip (upper-left quadrant)
module secondary_chip() {
  color([0.35, 0.35, 0.35])
  translate([ -pcb_length/4,
              pcb_width/4,
              pcb_thickness/2 + chip2_height/2 - connect_overlap ])
    cube([chip2_length, chip2_width, chip2_height], center=true);
}

// Silkscreen (thin raised layer, overlaps into PCB to ensure connectivity)
module silkscreen() {
  color([1, 1, 1])
  union() {
    translate([0, 0, pcb_thickness/2 + silk_depth/2 - connect_overlap])
      cube([pcb_length - 2*silk_margin, pcb_width - 2*silk_margin, silk_depth], center=true);

    translate([ -pcb_length/2 + silk_margin + (pcb_length - 2*silk_margin)/6,
                -pcb_width/2 + silk_margin + (pcb_width - 2*silk_margin)/8,
                pcb_thickness/2 + silk_depth/2 - connect_overlap ])
      cube([(pcb_length - 2*silk_margin)/3, (pcb_width - 2*silk_margin)/4, silk_depth], center=true);
  }
}

// Complete SBC Model (ONE connected solid)
module sbc_complete_model() {
  union() {
    pcb_core();
    // Edge connectors
    usb_connector();
    hdmi_connector();
    gpio_header();
    // On-board components
    main_chip();
    secondary_chip();
    silkscreen();
  }
}

sbc_complete_model();