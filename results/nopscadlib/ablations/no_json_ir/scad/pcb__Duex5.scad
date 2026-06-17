$fn = 64;

// =====================
// 3D Printer Control Board (approximate but recognizable)
// Overall: 123.0mm x 100.0mm x 1.6mm PCB
// One connected solid (all parts overlap slightly into PCB)
// =====================

// Board overall size (mm)
pcb_L = 123.0;
pcb_W = 100.0;
pcb_T = 1.6;

// Small overlap to guarantee watertight unions
ov = 0.25;

// Corner radius
corner_r = 3.0;

// Mounting holes (typical M3 clearance)
hole_d = 3.2;
hole_edge = 6.0; // hole center offset from edges

// Component sizes (mm) - simplified but recognizable
usb_w = 14; usb_d = 16; usb_h = 8;      // USB-B-ish block
eth_w = 16; eth_d = 21; eth_h = 13;     // RJ45-ish block
term_w = 52; term_d = 12; term_h = 12;  // screw terminal block
header_w = 40; header_d = 6; header_h = 8; // pin header
step_w = 12; step_d = 18; step_h = 6;   // stepper driver modules
ic_w = 18; ic_d = 18; ic_h = 3;         // main IC
cap_d = 10; cap_h = 14;                 // electrolytic caps

// Extra features for "control board" look
heatsink_w = 28; heatsink_d = 22; heatsink_h = 10;
ind_d = 12; ind_h = 6;                  // inductor
sd_w = 16; sd_d = 18; sd_h = 3.5;       // microSD-ish low profile
btn_d = 6; btn_h = 3;                   // button
crystal_w = 10; crystal_d = 4; crystal_h = 3;

// ---------- Helpers ----------
module rounded_rect_2d(l, w, r){
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module pcb_plate(){
    linear_extrude(height=pcb_T, center=true)
        rounded_rect_2d(pcb_L, pcb_W, corner_r);
}

module mount_holes(){
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(pcb_L/2 - hole_edge), sy*(pcb_W/2 - hole_edge), 0])
            cylinder(h=pcb_T + 2, d=hole_d, center=true);
}

// Places a box component sitting on top surface of PCB with slight overlap
module component_box(size_xyz, pos_xy){
    translate([pos_xy[0], pos_xy[1], pcb_T/2 + size_xyz[2]/2 - ov])
        cube(size_xyz, center=true);
}

// Places a cylinder component sitting on top surface of PCB with slight overlap
module component_cyl(d, h, pos_xy){
    translate([pos_xy[0], pos_xy[1], pcb_T/2 + h/2 - ov])
        cylinder(d=d, h=h, center=true);
}

// Simple finned heatsink block (still one solid)
module heatsink(pos_xy){
    // Base block
    component_box([heatsink_d, heatsink_w, heatsink_h], pos_xy);

    // Fins on top, overlapping into base
    fin_t = 1.2;
    fin_gap = 2.2;
    fin_h = heatsink_h * 0.75;
    fin_count = floor((heatsink_d - fin_t) / fin_gap);

    for (i = [0:fin_count-1]) {
        x = -heatsink_d/2 + fin_t/2 + i*fin_gap;
        translate([pos_xy[0] + x, pos_xy[1], pcb_T/2 + heatsink_h - fin_h/2 - ov])
            cube([fin_t, heatsink_w*0.92, fin_h], center=true);
    }
}

// ---------- Main Model ----------
module control_board(){
    union() {
        // PCB with mounting holes
        difference() {
            pcb_plate();
            mount_holes();
        }

        // --- Edge connectors (touch PCB edges and sit on top) ---
        // Left edge: USB (lower-left area)
        component_box(
            [usb_d, usb_w, usb_h],
            [-(pcb_L/2 - usb_d/2), -(pcb_W/2) + usb_w/2 + pcb_W*0.18]
        );

        // Left edge: Ethernet (upper-left area)
        component_box(
            [eth_d, eth_w, eth_h],
            [-(pcb_L/2 - eth_d/2), (pcb_W/2) - eth_w/2 - pcb_W*0.18]
        );

        // Right edge: screw terminal block (center-right)
        component_box(
            [term_d, term_w, term_h],
            [(pcb_L/2 - term_d/2), 0]
        );

        // Top edge: pin header (center-top)
        component_box(
            [header_w, header_d, header_h],
            [0, (pcb_W/2 - header_d/2)]
        );

        // Bottom edge: microSD-ish low profile (center-bottom)
        component_box(
            [sd_d, sd_w, sd_h],
            [0, -(pcb_W/2 - sd_w/2)]
        );

        // --- Central components ---
        // Main IC near center
        component_box([ic_d, ic_w, ic_h], [0, 0]);

        // Heatsink near center-right (typical driver/regulator area)
        heatsink([pcb_L*0.18, pcb_W*0.10]);

        // Inductor near heatsink
        component_cyl(ind_d, ind_h, [pcb_L*0.18, pcb_W*0.26]);

        // Crystal near main IC
        component_box([crystal_d, crystal_w, crystal_h], [-pcb_L*0.10, pcb_W*0.05]);

        // Reset button near top-right quadrant
        component_cyl(btn_d, btn_h, [pcb_L*0.28, pcb_W*0.30]);

        // Capacitors (cylinders) near right side
        for (i = [-1, 0, 1])
            component_cyl(
                cap_d, cap_h,
                [pcb_L*0.22, i*(pcb_W*0.14)]
            );

        // Stepper driver modules (3x2 array) left/center area
        for (ix = [-1, 0, 1], iy = [-1, 1])
            component_box(
                [step_d, step_w, step_h],
                [ix*(pcb_L*0.18) - pcb_L*0.12, iy*(pcb_W*0.18)]
            );

        // Small "MOSFET" blocks near terminal (adds recognizable density)
        mos_w = 8; mos_d = 10; mos_h = 4;
        for (k = [-1, 0, 1, 2])
            component_box(
                [mos_d, mos_w, mos_h],
                [pcb_L*0.33, (k-0.5)*pcb_W*0.10]
            );
    }
}

control_board();