$fn = 64;

// =====================
// Parameters (mm)
// =====================
pcb_length = 37.5;
pcb_width  = 33.8;
pcb_thickness = 1.6;

corner_radius = 2.0;

mount_hole_diameter = 3.2;
mount_hole_edge_offset = 4.0;

silkscreen_depth = 0.2;
silkscreen_margin = 2.0;
silkscreen_overlap = 0.15;   // small overlap into PCB to ensure connectivity

// Simple "control board" features (all connected solids)
usb_w = 12.0;
usb_l = 10.0;
usb_h = 5.0;

term_w = 16.0;
term_l = 8.0;
term_h = 7.0;

pin_w = 10.0;
pin_l = 5.0;
pin_h = 4.0;

mcu_w = 12.0;
mcu_l = 12.0;
mcu_h = 1.2;

cap_r = 3.0;
cap_h = 6.0;

overlap = 0.25; // general overlap to avoid floating parts

// =====================
// Helpers
// =====================
module rounded_rect_prism(w, l, h, r) {
    // Flat, non-warped PCB: hull of 4 cylinders
    hull() {
        translate([ w/2 - r,  l/2 - r, 0]) cylinder(r=r, h=h, center=true);
        translate([-w/2 + r,  l/2 - r, 0]) cylinder(r=r, h=h, center=true);
        translate([ w/2 - r, -l/2 + r, 0]) cylinder(r=r, h=h, center=true);
        translate([-w/2 + r, -l/2 + r, 0]) cylinder(r=r, h=h, center=true);
    }
}

module mount_holes() {
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(pcb_width/2 - mount_hole_edge_offset),
                   sy*(pcb_length/2 - mount_hole_edge_offset),
                   0])
            cylinder(d=mount_hole_diameter, h=pcb_thickness*3, center=true);
    }
}

module pcb_body() {
    difference() {
        color([0.0, 0.4, 0.2])
            rounded_rect_prism(pcb_width, pcb_length, pcb_thickness, corner_radius);
        mount_holes();
    }
}

module silkscreen() {
    // Slightly embedded into top surface so it is one connected solid
    color([0.85, 0.85, 0.8])
    translate([0, 0, pcb_thickness/2 - silkscreen_depth/2 - silkscreen_overlap])
        rounded_rect_prism(pcb_width - 2*silkscreen_margin,
                           pcb_length - 2*silkscreen_margin,
                           silkscreen_depth,
                           max(0.5, corner_radius - 0.8));
}

module components() {
    // All components sit on top and overlap into PCB by "overlap" to guarantee connectivity.
    z_on_top = pcb_thickness/2 + 0; // reference plane at top surface

    // USB-like connector on +Y edge
    color([0.1, 0.1, 0.6])
    translate([0,
               pcb_length/2 - usb_l/2,
               z_on_top + usb_h/2 - overlap])
        cube([usb_w, usb_l, usb_h], center=true);

    // Screw terminal on -Y edge
    color([0.1, 0.1, 0.6])
    translate([0,
               -pcb_length/2 + term_l/2,
               z_on_top + term_h/2 - overlap])
        cube([term_w, term_l, term_h], center=true);

    // Pin header on +X edge
    color([0.1, 0.1, 0.6])
    translate([pcb_width/2 - pin_l/2,
               0,
               z_on_top + pin_h/2 - overlap])
        cube([pin_l, pin_w, pin_h], center=true);

    // MCU package near center
    color([0.15, 0.15, 0.15])
    translate([-pcb_width*0.12,
               pcb_length*0.05,
               z_on_top + mcu_h/2 - overlap])
        cube([mcu_w, mcu_l, mcu_h], center=true);

    // Capacitor cylinder near one corner
    color([0.2, 0.2, 0.2])
    translate([pcb_width/2 - (mount_hole_edge_offset + cap_r + 1.0),
               pcb_length/2 - (mount_hole_edge_offset + cap_r + 1.0),
               z_on_top + cap_h/2 - overlap])
        cylinder(r=cap_r, h=cap_h, center=true);
}

// =====================
// Final connected model
// =====================
union() {
    pcb_body();
    silkscreen();
    components();
}