// 3D printer mainboard (generic) - 110.0mm x 85.0mm x 1.6mm
// FIXED: ensure ALL components physically intersect the PCB (no floating parts)
// - All solids are in a single union() (with holes subtracted after)
// - Components overlap into PCB by 1.2mm to guarantee attachment

$fn = 48;

// Parameters
length_mm    = 110.0;  // X
width_mm     = 85.0;   // Y
thickness_mm = 1.6;    // Z (PCB)

// Small overlap to guarantee watertight unions / attachments
eps = 0.2;
attach_overlap = 1.2;   // 1–2mm required overlap into PCB

// ---------- Helpers ----------
module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
    x = size[0]; y = size[1]; z = size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([x-2*r, y-2*r], center=true);
}

module pin_header_block(x=10, y=6, z=8, base=1.2) {
    union() {
        cube([x, y, z], center=true);
        translate([0, 0, -z/2 - base/2 + eps])
            cube([x+1.0, y+1.0, base], center=true);
    }
}

module usb_block(x=14, y=12, z=8) {
    union() {
        cube([x, y, z], center=true);
        translate([0, 0, z/2 - 1.2])
            cube([x-2.0, y-2.0, 2.4], center=true);
    }
}

module terminal_block(x=18, y=12, z=12) {
    union() {
        cube([x, y, z], center=true);
        translate([0, 0, z/2 - 2.0])
            cube([x-2.0, y-2.0, 4.0], center=true);
    }
}

module stepper_socket(x=16, y=14, z=10) {
    union() {
        cube([x, y, z], center=true);
        translate([0, 0, z/2 - 1.5])
            cube([x-2.0, y-2.0, 3.0], center=true);
    }
}

module chip_qfp(x=18, y=18, z=3) {
    union() {
        cube([x, y, z], center=true);
        translate([0, 0, z/2 - 0.6])
            cube([x-3.0, y-3.0, 1.2], center=true);
    }
}

module capacitor_cyl(r=3.2, h=7.5) {
    cylinder(r=r, h=h, center=true);
}

// ---------- Mainboard ----------
module mainboard_110x85x1p6() {
    L = length_mm;
    W = width_mm;
    T = thickness_mm;

    // Mounting holes
    hole_d = 3.2;
    hole_r = hole_d/2;
    inset_x = 5.0;
    inset_y = 5.0;

    pcb_top_z = T/2;

    // Place components so their bottoms penetrate into PCB by attach_overlap
    // For a component of height h (centered), bottom is at (z - h/2).
    // We want bottom = pcb_top_z - attach_overlap  => z = pcb_top_z + h/2 - attach_overlap
    function comp_center_z(h) = pcb_top_z + h/2 - attach_overlap;

    difference() {
        union() {
            // PCB slab
            color([0.0, 0.4, 0.2])
                rounded_rect_prism([L, W, T], r=2.0, center=true);

            // --- Major connectors along one long edge (Y = +W/2) ---
            usb_h = 8;
            translate([
                -L/2 + 18,
                W/2 - 7,
                comp_center_z(usb_h)
            ])
                color([0.75, 0.75, 0.78]) usb_block(x=14, y=12, z=usb_h);

            term_h = 12;
            translate([
                L/2 - 20,
                W/2 - 7,
                comp_center_z(term_h)
            ])
                color([0.1, 0.55, 0.1]) terminal_block(x=20, y=12, z=term_h);

            // --- Stepper driver sockets (row) ---
            sock_h = 10;
            sock_y = 6;
            for (i = [0:4]) {
                x_pos = -L/2 + 25 + i*17;
                translate([x_pos, sock_y, comp_center_z(sock_h)])
                    color([0.15, 0.15, 0.15]) stepper_socket(x=16, y=14, z=sock_h);
            }

            // --- MCU / main chip near center-left ---
            mcu_h = 3.2;
            translate([-10, -8, comp_center_z(mcu_h)])
                color([0.12, 0.12, 0.12]) chip_qfp(x=20, y=20, z=mcu_h);

            // --- Heatsink-like block near center-right ---
            hs_h = 6;
            translate([18, -6, comp_center_z(hs_h)])
                color([0.25, 0.25, 0.25]) cube([22, 18, hs_h], center=true);

            // --- Capacitors near power input ---
            cap_h = 7.5;
            translate([L/2 - 35, W/2 - 18, comp_center_z(cap_h)])
                color([0.08, 0.08, 0.08]) capacitor_cyl(r=3.2, h=cap_h);
            translate([L/2 - 28, W/2 - 18, comp_center_z(cap_h)])
                color([0.08, 0.08, 0.08]) capacitor_cyl(r=3.2, h=cap_h);

            // --- Pin headers along bottom edge (Y = -W/2) ---
            hdr_h = 8;
            translate([-L/2 + 30, -W/2 + 6, comp_center_z(hdr_h)])
                color([0.1, 0.1, 0.1]) pin_header_block(x=40, y=8, z=hdr_h, base=1.2);

            translate([L/2 - 28, -W/2 + 6, comp_center_z(hdr_h)])
                color([0.1, 0.1, 0.1]) pin_header_block(x=30, y=8, z=hdr_h, base=1.2);

            // --- Small components cluster (low-profile) ---
            // Ensure these also overlap into PCB (previously could appear offset)
            smd_h = 1.6;
            for (ix = [0:3])
                for (iy = [0:2]) {
                    translate([
                        -35 + ix*8,
                        18 + iy*6,
                        comp_center_z(smd_h)
                    ])
                        color([0.2, 0.2, 0.2]) cube([5.5, 3.0, smd_h], center=true);
                }
        }

        // Mounting holes (through PCB only)
        for (sx = [-1, 1])
            for (sy = [-1, 1]) {
                translate([
                    sx*(L/2 - inset_x),
                    sy*(W/2 - inset_y),
                    0
                ])
                    cylinder(r=hole_r, h=T + 2*eps, center=true);
            }
    }
}

// Assembly
mainboard_110x85x1p6();