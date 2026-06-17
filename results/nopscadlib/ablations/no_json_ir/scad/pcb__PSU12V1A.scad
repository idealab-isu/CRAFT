// Power supply board (single connected solid)
// Overall PCB: 67.0mm x 31.0mm x 1.7mm

$fn = 64;

// --- Parameters ---
pcb_L = 67.0;
pcb_W = 31.0;
pcb_T = 1.7;

// Corner radius (visual only; keeps exact outer dims via minkowski with reduced core)
corner_r = 1.2;

// Mounting holes (subtracted)
hole_d = 2.2;
hole_edge = 3.0; // distance from each edge to hole center

// Small overlap to guarantee connectivity between added features and PCB
ov = 0.25;

// --- Helpers ---
module rounded_pcb(L, W, T, r) {
    // Rounded rectangle prism with exact outer L/W
    minkowski() {
        translate([r, r, 0])
            cube([L - 2*r, W - 2*r, T], center=false);
        cylinder(r=r, h=0.01, center=false);
    }
}

module mounting_holes_subtract() {
    for (x = [hole_edge, pcb_L - hole_edge])
        for (y = [hole_edge, pcb_W - hole_edge])
            translate([x, y, -1])
                cylinder(h = pcb_T + 2, d = hole_d, center=false);
}

// Simple raised copper/silkscreen-like pads (kept as solid, connected)
module top_pads() {
    pad_h = 0.25;
    // Long trace strip
    translate([5, 6, pcb_T - ov])
        cube([pcb_L - 10, 0.8, pad_h + ov], center=false);

    // A few pads
    for (i = [0:5]) {
        px = 10 + i * 8;
        translate([px, pcb_W - 6, pcb_T - ov])
            cube([3.2, 2.2, pad_h + ov], center=false);
    }
}

// Connector blocks (solid, connected)
module connectors_and_components() {
    // Terminal block along one long edge
    term_L = 18;
    term_W = 8;
    term_H = 9;

    translate([(pcb_L - term_L)/2, -ov, pcb_T - ov])
        cube([term_L, term_W + ov, term_H + ov], center=false);

    // DC jack-like block on opposite edge
    jack_L = 14;
    jack_W = 10;
    jack_H = 8;

    translate([(pcb_L - jack_L)/2, pcb_W - jack_W, pcb_T - ov])
        cube([jack_L, jack_W + ov, jack_H + ov], center=false);

    // Inductor/capacitor-like components
    comp1 = [12, 10, 7];
    translate([8, (pcb_W - comp1[1])/2, pcb_T - ov])
        cube([comp1[0], comp1[1], comp1[2] + ov], center=false);

    comp2 = [10, 8, 6];
    translate([pcb_L - 8 - comp2[0], (pcb_W - comp2[1])/2, pcb_T - ov])
        cube([comp2[0], comp2[1], comp2[2] + ov], center=false);

    // Small IC block
    ic = [10, 8, 2.2];
    translate([(pcb_L - ic[0])/2, (pcb_W - ic[1])/2, pcb_T - ov])
        cube([ic[0], ic[1], ic[2] + ov], center=false);
}

// Small underside solder bumps (solid, connected)
module bottom_bumps() {
    bump_d = 1.2;
    bump_h = 0.5;

    for (x = [hole_edge, pcb_L - hole_edge])
        for (y = [hole_edge, pcb_W - hole_edge])
            translate([x, y, -bump_h + ov])
                cylinder(h=bump_h + ov, d=bump_d, center=false);
}

// --- Assembly (ONE connected solid) ---
difference() {
    union() {
        // PCB body
        rounded_pcb(pcb_L, pcb_W, pcb_T, corner_r);

        // Top details
        top_pads();
        connectors_and_components();

        // Bottom details
        bottom_bumps();
    }

    // Subtract mounting holes through PCB
    mounting_holes_subtract();
}