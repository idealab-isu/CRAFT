$fn = 48;

// Parameters (requested PCB size)
pcb_length = 65.0;      // X
pcb_width  = 30.0;      // Y
pcb_thickness = 1.4;    // Z

// Small overlap to guarantee watertight unions
ov = 0.2;

// Feature parameters (generic SBC-like details)
corner_r = 2.0;

mount_hole_d = 2.6;
mount_hole_edge = 3.0; // distance from edges to hole center

// Components (all placed to TOUCH/OVERLAP the PCB so the model is ONE connected solid)
chip_xy = [14, 14];
chip_h  = 1.6;

usb_xy  = [12, 8];
usb_h   = 4.0;

header_xy = [22, 5];
header_h  = 3.0;

led_xy = [2.0, 1.2];
led_h  = 0.8;

module rounded_rect_2d(l, w, r) {
    // Robust rounded rectangle using hull of circles
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module pcb_with_holes() {
    difference() {
        // PCB body
        linear_extrude(height=pcb_thickness, center=true)
            rounded_rect_2d(pcb_length, pcb_width, corner_r);

        // 4 mounting holes (through)
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(pcb_length/2 - mount_hole_edge),
                sy*(pcb_width/2  - mount_hole_edge),
                0
            ])
            cylinder(h=pcb_thickness + 2, d=mount_hole_d, center=true);
        }
    }
}

module top_component(size_xy, h, pos_xy, col=[0.15,0.15,0.15]) {
    // Sits on top surface; overlaps slightly into PCB for connectivity
    color(col)
    translate([pos_xy[0], pos_xy[1], pcb_thickness/2 + h/2 - ov])
        cube([size_xy[0], size_xy[1], h], center=true);
}

module top_cylinder(d, h, pos_xy, col=[0.7,0.7,0.7]) {
    color(col)
    translate([pos_xy[0], pos_xy[1], pcb_thickness/2 + h/2 - ov])
        cylinder(h=h, d=d, center=true);
}

module sbc() {
    union() {
        // PCB
        color([0.0, 0.4, 0.2]) pcb_with_holes();

        // Main IC (center-ish)
        top_component(chip_xy, chip_h, [0, 0], [0.1, 0.1, 0.1]);

        // USB-like connector on +X edge (overlaps into PCB)
        // Place so its inner face is slightly inside the PCB edge
        usb_x = pcb_length/2 - usb_xy[0]/2 + ov;
        top_component(usb_xy, usb_h, [usb_x, 0], [0.75, 0.75, 0.75]);

        // Pin header along -Y edge
        header_y = -pcb_width/2 + header_xy[1]/2 - ov;
        top_component(header_xy, header_h, [-6, header_y], [0.05, 0.05, 0.05]);

        // Small LED near a corner
        top_component(led_xy, led_h,
                      [pcb_length/2 - 8, pcb_width/2 - 6],
                      [0.9, 0.1, 0.1]);

        // A couple of small capacitors (cylinders)
        top_cylinder(3.0, 2.2, [10, 8], [0.8, 0.8, 0.8]);
        top_cylinder(2.4, 1.8, [14, 4], [0.8, 0.8, 0.8]);
    }
}

// Final Output (ONE connected solid)
sbc();