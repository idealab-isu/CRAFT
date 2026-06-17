// 3D Printer Control Board (PCB) - 123.0mm x 100.0mm x 1.6mm
// One connected solid with recognizable PCB features (outline, mounting holes, connectors/components)

$fn = 64;

// Parameters
pcb_length = 123.0;
pcb_width  = 100.0;
pcb_thickness = 1.6;

// Board styling
corner_r = 3.0;

// Mounting holes
hole_d = 3.2;
hole_edge_margin = 6.0; // from each edge to hole center

// Component heights (above PCB)
comp_base_h = 0.8;   // slight soldermask/feature relief
usb_h = 8.0;
usb_w = 14.0;
usb_d = 12.0;

term_h = 10.0;
term_w = 36.0;
term_d = 12.0;

headers_h = 6.0;
headers_w = 50.0;
headers_d = 8.0;

driver_h = 12.0;
driver_w = 18.0;
driver_d = 22.0;

mcu_h = 3.0;
mcu_w = 18.0;
mcu_d = 18.0;

cap_h = 12.0;
cap_r = 5.0;

// Small overlap to guarantee connectivity
overlap = 0.4;

// Helpers
module rounded_rect_prism(l, w, h, r) {
    // Rounded rectangle extruded to height h, centered
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([l - 2*r, w - 2*r], center=true);
}

module pcb_outline() {
    rounded_rect_prism(pcb_length, pcb_width, pcb_thickness, corner_r);
}

module mounting_holes() {
    // Through-holes (subtracted)
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([
            sx * (pcb_length/2 - hole_edge_margin),
            sy * (pcb_width/2  - hole_edge_margin),
            0
        ])
        cylinder(h=pcb_thickness + 2, d=hole_d, center=true);
    }
}

module component_block(size_xyz, pos_xy, h_above) {
    // Places a block sitting on top of PCB, with slight overlap into PCB
    // size_xyz = [x,y,z] where z = h_above
    translate([pos_xy[0], pos_xy[1], pcb_thickness/2 + h_above/2 - overlap])
        cube([size_xyz[0], size_xyz[1], h_above], center=true);
}

module component_cyl(r, h_above, pos_xy) {
    translate([pos_xy[0], pos_xy[1], pcb_thickness/2 + h_above/2 - overlap])
        cylinder(r=r, h=h_above, center=true);
}

module pcb_with_features() {
    union() {
        // PCB body with mounting holes
        color([0.0, 0.4, 0.2])
        difference() {
            pcb_outline();
            mounting_holes();
        }

        // Slight raised "silkscreen/trace" relief to make top view non-blank
        // (kept very thin but visible)
        color([0.0, 0.5, 0.25])
        translate([0, 0, pcb_thickness/2 + comp_base_h/2 - overlap])
            cube([pcb_length - 10, pcb_width - 10, comp_base_h], center=true);

        // Connectors/components (all connected via calculated Z placement)

        // USB connector on left edge
        color([0.75, 0.75, 0.75])
        component_block([usb_d, usb_w, usb_h],
                        [-(pcb_length/2 - usb_d/2), 0],
                        usb_h);

        // Screw terminal block on right edge
        color([0.1, 0.35, 0.1])
        component_block([term_d, term_w, term_h],
                        [(pcb_length/2 - term_d/2), 0],
                        term_h);

        // Pin headers along top edge
        color([0.1, 0.1, 0.1])
        component_block([headers_w, headers_d, headers_h],
                        [0, (pcb_width/2 - headers_d/2)],
                        headers_h);

        // Stepper driver modules (3x) near bottom half
        color([0.0, 0.2, 0.6])
        for (i = [-1, 0, 1]) {
            component_block([driver_d, driver_w, driver_h],
                            [i * (driver_d + 6), -(pcb_width*0.20)],
                            driver_h);
        }

        // MCU in center
        color([0.15, 0.15, 0.15])
        component_block([mcu_d, mcu_w, mcu_h],
                        [0, 0],
                        mcu_h);

        // Electrolytic capacitor near right-bottom quadrant
        color([0.05, 0.05, 0.05])
        component_cyl(cap_r, cap_h, [pcb_length*0.25, -(pcb_width*0.25)]);
    }
}

// Final output
pcb_with_features();