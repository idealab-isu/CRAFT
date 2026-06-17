$fn = 64;

// Battery charger module overall: 26.2 x 17.5 x 1.0 mm (PCB thickness)
// Keep ONE connected solid. All features overlap into PCB by 'ov'.
// PCB is centered at origin, spanning Z = [-pcb_t/2, +pcb_t/2].

module battery_charger_module() {
    // --- Primary dimensions ---
    pcb_l = 26.2;
    pcb_w = 17.5;
    pcb_t = 1.0;

    // Corner radius for PCB outline
    pcb_r = 1.2;

    // Small overlap to guarantee connectivity between features
    ov = 0.15;

    // --- Feature sizes (low-profile) ---
    // USB-like connector block (low profile)
    usb_l = 7.2;
    usb_w = 6.8;
    usb_h = 2.2;

    // IC package
    ic_l = 6.0;
    ic_w = 5.0;
    ic_h = 1.0;

    // Inductor / large component
    ind_l = 5.0;
    ind_w = 5.0;
    ind_h = 1.2;

    // Small passives
    smd_l = 2.0;
    smd_w = 1.2;
    smd_h = 0.6;

    // Pads as raised copper (very thin)
    pad_h = 0.25;

    // --- Helper: rounded rectangle prism (centered) ---
    module rounded_plate(l, w, h, r) {
        linear_extrude(height = h, center = true)
            offset(r = r)
                square([l - 2*r, w - 2*r], center = true);
    }

    union() {
        // PCB centered at origin, thickness exactly 1.0mm
        rounded_plate(pcb_l, pcb_w, pcb_t, pcb_r);

        // Common Z placement for "on top of PCB" features (centered cubes)
        z_top = pcb_t/2 + (0) ; // PCB top surface at +pcb_t/2

        // USB connector on +X short edge, sitting on top of PCB, overlapping into PCB
        translate([
            pcb_l/2 - usb_l/2,                 // flush to right edge
            0,
            z_top + usb_h/2 - ov               // bottom at pcb_t/2 - ov
        ])
            cube([usb_l, usb_w, usb_h], center = true);

        // Main IC near center-left
        translate([
            -pcb_l*0.10,
            pcb_w*0.10,
            z_top + ic_h/2 - ov
        ])
            cube([ic_l, ic_w, ic_h], center = true);

        // Inductor near top-left quadrant
        translate([
            -pcb_l*0.25,
            pcb_w*0.25,
            z_top + ind_h/2 - ov
        ])
            cube([ind_l, ind_w, ind_h], center = true);

        // A few small passives near the USB side
        for (p = [
            [ pcb_l*0.18, -pcb_w*0.18],
            [ pcb_l*0.10, -pcb_w*0.30],
            [ pcb_l*0.02, -pcb_w*0.22]
        ]) {
            translate([p[0], p[1], z_top + smd_h/2 - ov])
                cube([smd_l, smd_w, smd_h], center = true);
        }

        // Battery pads on -X short edge, as thin raised copper, overlapping into PCB
        pad_l = 3.2;
        pad_w = 2.2;
        pad_gap = 1.6;

        for (i = [-1, 1]) {
            translate([
                -pcb_l/2 + pad_l/2,            // flush to left edge
                i*(pad_w/2 + pad_gap/2),
                z_top + pad_h/2 - ov
            ])
                cube([pad_l, pad_w, pad_h], center = true);
        }

        // Four corner mounting pads (thin), overlapping into PCB
        corner_pad = 2.4;
        inset = 1.8;
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(pcb_l/2 - inset),
                sy*(pcb_w/2 - inset),
                z_top + pad_h/2 - ov
            ])
                cube([corner_pad, corner_pad, pad_h], center = true);
        }
    }
}

battery_charger_module();