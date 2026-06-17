$fn = 64;

// --- Parameters (mm) ---
pcb_length = 203.2;
pcb_width  = 49.53;
pcb_thickness = 1.6;

corner_radius = 3.0;

mount_hole_diameter = 3.2;
mount_hole_edge_offset_x = 6.0;
mount_hole_edge_offset_y = 6.0;

overlap = 0.6;          // small intentional overlap to guarantee connectivity
eps = 0.01;

// --- Helper: rounded rectangle prism (single solid) ---
module rounded_rect_prism(L, W, H, R, center=true) {
    // 2D rounded rectangle via hull of circles, then linear_extrude
    module rr2d() {
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(L/2 - R), sy*(W/2 - R)])
                    circle(r=R);
        }
    }

    if (center)
        translate([0,0,-H/2])
            linear_extrude(height=H) rr2d();
    else
        linear_extrude(height=H) rr2d();
}

// --- PCB body with holes (connected solid) ---
module pcb_with_holes() {
    difference() {
        color([0.0, 0.4, 0.2])
            rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius, center=true);

        // mounting holes
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(pcb_length/2 - mount_hole_edge_offset_x),
                       sy*(pcb_width/2  - mount_hole_edge_offset_y),
                       0])
                cylinder(h=pcb_thickness + 2*overlap, r=mount_hole_diameter/2, center=true);
        }
    }
}

// --- Simple 3D components (all connected to PCB with calculated Z placement) ---
module components() {
    z_top = pcb_thickness/2;

    // Long terminal block along one long edge
    term_L = pcb_length * 0.62;
    term_W = 12.0;
    term_H = 14.0;
    translate([0,
               pcb_width/2 - term_W/2 + overlap,                 // overlap into PCB edge
               z_top + term_H/2 - overlap])                      // overlap into PCB top
        color([0.15,0.15,0.15])
            cube([term_L, term_W, term_H], center=true);

    // USB-like connector near left end
    usb_L = 16.0;
    usb_W = 14.0;
    usb_H = 11.0;
    translate([-(pcb_length/2 - usb_L/2 - 10.0),
               -(pcb_width/2 - usb_W/2) - overlap,               // overlap into PCB edge
               z_top + usb_H/2 - overlap])
        color([0.7,0.7,0.7])
            cube([usb_L, usb_W, usb_H], center=true);

    // Power jack near right end
    jack_L = 18.0;
    jack_W = 14.0;
    jack_H = 13.0;
    translate([ (pcb_length/2 - jack_L/2 - 10.0),
               -(pcb_width/2 - jack_W/2) - overlap,              // overlap into PCB edge
               z_top + jack_H/2 - overlap])
        color([0.1,0.1,0.1])
            cube([jack_L, jack_W, jack_H], center=true);

    // Main MCU/driver package (center)
    ic_L = 22.0;
    ic_W = 22.0;
    ic_H = 3.0;
    translate([0, 0, z_top + ic_H/2 - overlap])
        color([0.05,0.05,0.05])
            cube([ic_L, ic_W, ic_H], center=true);

    // Heatsink block on top of IC
    hs_L = 18.0;
    hs_W = 18.0;
    hs_H = 8.0;
    translate([0, 0, z_top + ic_H - overlap + hs_H/2 - overlap])
        color([0.25,0.25,0.25])
            cube([hs_L, hs_W, hs_H], center=true);

    // Two electrolytic capacitors
    cap_r = 5.0;
    cap_h = 12.0;
    cap_x = pcb_length*0.18;
    cap_y = pcb_width*0.18;
    for (sx = [-1, 1]) {
        translate([sx*cap_x, cap_y, z_top + cap_h/2 - overlap])
            color([0.0,0.0,0.0])
                cylinder(r=cap_r, h=cap_h, center=true);
    }

    // Small stepper-driver headers (row of low blocks)
    hdr_count = 5;
    hdr_pitch = 14.0;
    hdr_L = 10.0;
    hdr_W = 8.0;
    hdr_H = 6.0;
    hdr_y = -(pcb_width*0.10);
    for (i = [0:hdr_count-1]) {
        x = (i - (hdr_count-1)/2) * hdr_pitch;
        translate([x, hdr_y, z_top + hdr_H/2 - overlap])
            color([0.2,0.2,0.2])
                cube([hdr_L, hdr_W, hdr_H], center=true);
    }
}

// --- Complete model: ONE connected solid (union of touching/overlapping parts) ---
union() {
    pcb_with_holes();
    components();
}