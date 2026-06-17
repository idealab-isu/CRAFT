$fn = 64;

// Target: Single-board computer PCB 65.0mm x 56.0mm x 1.4mm
pcb_length = 65.0;
pcb_width  = 56.0;
pcb_thickness = 1.4;

corner_radius = 3.0;

hole_diameter = 2.8;
hole_edge_offset_x = 3.5;
hole_edge_offset_y = 3.5;

connector_height = 10.0;
usb_length = 16.0;
usb_width  = 14.0;

ethernet_length = 21.0;
ethernet_width  = 16.0;

header_length = 52.0;
header_width  = 5.0;
header_height = 8.0;

chip_height = 2.0;
soc_size_x = 14.0;
soc_size_y = 14.0;
ram_size_x = 12.0;
ram_size_y = 10.0;
pmic_size_x = 8.0;
pmic_size_y = 8.0;

silkscreen_thickness = 0.2;
silkscreen_margin = 2.0;

overlap = 0.6; // small overlap to guarantee watertight unions/differences

// ---------- Helpers ----------
module rounded_rect_2d(L, W, R) {
    // Robust rounded rectangle (2D) using hull of corner circles
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R)]) circle(r=R);
    }
}

module pcb_solid() {
    // PCB body centered at origin, thickness along Z
    linear_extrude(height=pcb_thickness, center=true)
        rounded_rect_2d(pcb_length, pcb_width, corner_radius);
}

module mount_holes() {
    // Through holes
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(pcb_length/2 - hole_edge_offset_x),
                   sy*(pcb_width/2  - hole_edge_offset_y),
                   0])
            cylinder(d=hole_diameter, h=pcb_thickness + 2*overlap, center=true);
}

module pcb_main_body() {
    difference() {
        pcb_solid();
        mount_holes();
    }
}

// Small "solder fillet" pads to ensure all above-board parts are one connected solid
module anchor_pad(x, y, sx, sy) {
    // A very thin pad that overlaps into PCB and into the component above
    translate([x, y, pcb_thickness/2 - overlap/2])
        cube([sx, sy, 2*overlap], center=false);
}

// ---------- Components (all connected to PCB via overlap/anchor pads) ----------
module connector_usb() {
    // Place on left edge, near bottom side
    x = -pcb_length/2 + usb_length/2 - overlap;
    y = -pcb_width/2 + usb_width/2 + 6; // within board outline; formula uses dims + constant offset
    z0 = pcb_thickness/2 - overlap;     // start slightly inside PCB for guaranteed connection

    union() {
        translate([x - usb_length/2, y - usb_width/2, z0])
            cube([usb_length, usb_width, connector_height + overlap], center=false);
        anchor_pad(x - usb_length/2, y - usb_width/2, usb_length, usb_width);
    }
}

module connector_ethernet() {
    // Place on right edge, near bottom side
    x = pcb_length/2 - ethernet_length/2 + overlap;
    y = -pcb_width/2 + ethernet_width/2 + 6;
    z0 = pcb_thickness/2 - overlap;

    union() {
        translate([x - ethernet_length/2, y - ethernet_width/2, z0])
            cube([ethernet_length, ethernet_width, connector_height + overlap], center=false);
        anchor_pad(x - ethernet_length/2, y - ethernet_width/2, ethernet_length, ethernet_width);
    }
}

module connector_header() {
    // 40-pin style header along top edge
    x = 0;
    y = pcb_width/2 - header_width/2 + overlap;
    z0 = pcb_thickness/2 - overlap;

    union() {
        translate([x - header_length/2, y - header_width/2, z0])
            cube([header_length, header_width, header_height + overlap], center=false);
        anchor_pad(x - header_length/2, y - header_width/2, header_length, header_width);
    }
}

module chip_block(cx, cy, sx, sy, h) {
    z0 = pcb_thickness/2 - overlap;
    union() {
        translate([cx - sx/2, cy - sy/2, z0])
            cube([sx, sy, h + overlap], center=false);
        anchor_pad(cx - sx/2, cy - sy/2, sx, sy);
    }
}

module chips_components() {
    union() {
        chip_block(-pcb_length*0.10, 0,               soc_size_x,  soc_size_y,  chip_height);
        chip_block( pcb_length*0.15, pcb_width*0.10,  ram_size_x,  ram_size_y,  chip_height);
        chip_block( pcb_length*0.20,-pcb_width*0.15,  pmic_size_x, pmic_size_y, chip_height);
    }
}

module silkscreen_markings() {
    // Raised border ring on top surface (still connected via overlap)
    z0 = pcb_thickness/2 - overlap;
    outerL = pcb_length - 2*silkscreen_margin;
    outerW = pcb_width  - 2*silkscreen_margin;
    innerL = outerL - 2*(1.5*silkscreen_thickness);
    innerW = outerW - 2*(1.5*silkscreen_thickness);

    difference() {
        translate([0, 0, z0])
            linear_extrude(height=silkscreen_thickness + overlap, center=false)
                rounded_rect_2d(outerL, outerW, max(0.5, corner_radius - silkscreen_margin));
        translate([0, 0, z0 - overlap])
            linear_extrude(height=silkscreen_thickness + 3*overlap, center=false)
                rounded_rect_2d(innerL, innerW, max(0.5, corner_radius - silkscreen_margin - 0.5));
    }
}

// ---------- Final Model (ONE connected solid) ----------
module sbc_complete_model() {
    union() {
        pcb_main_body();
        connector_usb();
        connector_ethernet();
        connector_header();
        chips_components();
        silkscreen_markings();
    }
}

color([0.0, 0.4, 0.2])
sbc_complete_model();