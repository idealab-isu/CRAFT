$fn = 64;

// Target PCB dimensions
board_L = 67.0;
board_W = 31.0;
board_T = 1.7;

// Small overlap to guarantee watertight unions
overlap = 0.4;

// --- Feature parameters (generic power-supply board look) ---
corner_r = 2.0;

// Mounting holes (typical 4-corner)
hole_d = 3.2;
hole_edge = 3.5; // center distance from each edge

// Components (simple blocks)
comp_clear = 1.0; // keep components away from edges
ic_L = 14; ic_W = 10; ic_H = 3.0;
cap_r = 4.0; cap_H = 10.0;
ind_L = 12; ind_W = 12; ind_H = 6.0;

// Connectors (simple terminal blocks)
term_L = 10; term_W = 8; term_H = 9.0;
usb_L = 12; usb_W = 8; usb_H = 4.0;

// Silkscreen raised (kept as solid so model is ONE connected solid)
silk_T = 0.15;
silk_margin = 1.2;

// ---------- Helpers ----------
module rounded_rect_prism(L, W, H, r) {
    // 2D rounded rectangle extruded
    linear_extrude(height=H, center=true)
        offset(r=r)
            square([L - 2*r, W - 2*r], center=true);
}

module pcb_base() {
    color([0.0, 0.4, 0.2])
        rounded_rect_prism(board_L, board_W, board_T, corner_r);
}

module mounting_holes_cut() {
    // Through-holes cut from PCB
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(board_L/2 - hole_edge), sy*(board_W/2 - hole_edge), 0])
            cylinder(h=board_T + 2*overlap, d=hole_d, center=true);
    }
}

module silkscreen_raised() {
    // Raised border + a couple of pads/markings (no text)
    z = board_T/2 + silk_T/2 - overlap;

    color("White")
    union() {
        // Border frame
        translate([0, 0, z])
        difference() {
            rounded_rect_prism(board_L - 2*silk_margin, board_W - 2*silk_margin, silk_T, max(0.8, corner_r-0.6));
            rounded_rect_prism(board_L - 2*(silk_margin+1.2), board_W - 2*(silk_margin+1.2), silk_T + 2*overlap, max(0.6, corner_r-1.0));
        }

        // A couple of small "marking" rectangles
        translate([-(board_L*0.18), (board_W*0.18), z])
            cube([10, 3, silk_T], center=true);

        translate([(board_L*0.22), -(board_W*0.20), z])
            cube([8, 2.5, silk_T], center=true);
    }
}

module components_topside() {
    // All components sit on top surface and overlap slightly into PCB for connectivity
    z0 = board_T/2;

    union() {
        // Terminal block on +Y edge
        translate([-(board_L/2 - (term_L/2 + comp_clear)),
                   (board_W/2 - term_W/2),
                   z0 + term_H/2 - overlap])
            color([0.1, 0.1, 0.1])
                cube([term_L, term_W, term_H], center=true);

        // Second terminal block on +Y edge
        translate([(board_L/2 - (term_L/2 + comp_clear)),
                   (board_W/2 - term_W/2),
                   z0 + term_H/2 - overlap])
            color([0.1, 0.1, 0.1])
                cube([term_L, term_W, term_H], center=true);

        // USB-like connector on -Y edge
        translate([0,
                   -(board_W/2 - usb_W/2),
                   z0 + usb_H/2 - overlap])
            color([0.75, 0.75, 0.75])
                cube([usb_L, usb_W, usb_H], center=true);

        // IC block near center-left
        translate([-(board_L*0.12),
                   0,
                   z0 + ic_H/2 - overlap])
            color([0.15, 0.15, 0.15])
                cube([ic_L, ic_W, ic_H], center=true);

        // Inductor block near center-right
        translate([(board_L*0.18),
                   0,
                   z0 + ind_H/2 - overlap])
            color([0.2, 0.2, 0.2])
                cube([ind_L, ind_W, ind_H], center=true);

        // Electrolytic capacitor cylinder
        translate([-(board_L*0.28),
                   -(board_W*0.12),
                   z0 + cap_H/2 - overlap])
            color([0.05, 0.05, 0.05])
                cylinder(h=cap_H, r=cap_r, center=true);

        // Small diode/resistor-like block
        translate([(board_L*0.05),
                   (board_W*0.18),
                   z0 + 2.0/2 - overlap])
            color([0.2, 0.2, 0.2])
                cube([8, 3, 2.0], center=true);
    }
}

// ---------- Final assembly (ONE connected solid) ----------
module power_supply_board() {
    union() {
        // PCB with holes cut out
        difference() {
            pcb_base();
            mounting_holes_cut();
        }

        // Raised silkscreen (connected via overlap)
        silkscreen_raised();

        // Components (connected via overlap into PCB)
        components_topside();
    }
}

power_supply_board();