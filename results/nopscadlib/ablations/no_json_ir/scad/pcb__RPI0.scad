$fn = 64;

// Target dimensions (PCB only)
pcb_length = 65.0;
pcb_width  = 30.0;
pcb_thickness = 1.4;

// Styling / features
corner_radius = 2.0;
eps = 0.2;                 // small overlap to guarantee connectivity
hole_d = 2.6;              // mounting hole diameter
hole_edge = 3.0;           // hole center offset from edges

// Component sizes (simple SBC features)
chip_size = [12, 12, 1.2];
chip2_size = [8, 10, 1.0];

usb_size = [12, 14, 6];    // x, y, z
usb_inset = 1.0;           // how far connector sits onto PCB

hdmi_size = [10, 8, 4];
hdmi_inset = 1.0;

header_size = [30, 5, 6];
header_inset = 1.0;

module rounded_rect_prism(l, w, h, r) {
    // Centered at origin
    hull() {
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx*(l/2 - r), sy*(w/2 - r), 0])
                    cylinder(h=h, r=r, center=true);
    }
}

module pcb_with_holes() {
    difference() {
        rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_radius);

        // 4 mounting holes (through)
        for (sx = [-1, 1])
            for (sy = [-1, 1])
                translate([sx*(pcb_length/2 - hole_edge), sy*(pcb_width/2 - hole_edge), 0])
                    cylinder(h=pcb_thickness + 2*eps, d=hole_d, center=true);
    }
}

module place_on_top(size, x, y) {
    // Places a box on top of PCB with slight overlap into PCB
    translate([x, y, pcb_thickness/2 + size[2]/2 - eps])
        cube(size, center=true);
}

module place_on_side(size, side="right", y=0, z=0, inset=1.0) {
    // Places a box protruding from a PCB edge, overlapping into PCB by inset+eps
    x = (side=="right")
        ? (pcb_length/2 + size[0]/2 - (inset + eps))
        : -(pcb_length/2 + size[0]/2 - (inset + eps));

    translate([x, y, z])
        cube(size, center=true);
}

module sbc() {
    union() {
        // PCB
        pcb_with_holes();

        // Main SoC chip (top)
        place_on_top(chip_size, x = -pcb_length*0.10, y = 0);

        // Secondary chip (top)
        place_on_top(chip2_size, x = pcb_length*0.18, y = -pcb_width*0.18);

        // 2x USB-like connectors on right edge (stacked along Y)
        place_on_side(usb_size, side="right",
                      y =  usb_size[1]/2 - pcb_width*0.05,
                      z = pcb_thickness/2 + usb_size[2]/2 - eps,
                      inset = usb_inset);

        place_on_side(usb_size, side="right",
                      y = -(usb_size[1]/2 - pcb_width*0.05),
                      z = pcb_thickness/2 + usb_size[2]/2 - eps,
                      inset = usb_inset);

        // HDMI-like connector on left edge
        place_on_side(hdmi_size, side="left",
                      y = 0,
                      z = pcb_thickness/2 + hdmi_size[2]/2 - eps,
                      inset = hdmi_inset);

        // Pin header along top edge (positive Y)
        translate([0,
                   pcb_width/2 + header_size[1]/2 - (header_inset + eps),
                   pcb_thickness/2 + header_size[2]/2 - eps])
            cube(header_size, center=true);
    }
}

sbc();