$fn = 64;

// Target overall PCB size (verifiable)
pcb_L = 26.2;
pcb_W = 17.5;
pcb_T = 1.0;

// Connectivity / robustness
corner_r = 1.2;
overlap  = 0.25;   // ensures all features intersect the PCB (one connected solid)

// --- Feature sizes (charger-module cues) ---
usb_W = 7.6;   // micro-USB shell width
usb_D = 5.2;   // protrusion beyond PCB edge
usb_H = 2.6;   // height above PCB

chip_L = 6.0;
chip_W = 5.0;
chip_H = 1.0;

ind_L = 5.0;
ind_W = 5.0;
ind_H = 1.6;

pad_L = 3.2;
pad_W = 2.2;
pad_H = 0.25;

header_L = 10.0;
header_W = 3.0;
header_H = 2.0;

// Extra recognizable details (still connected)
led_L = 1.6;
led_W = 0.8;
led_H = 0.6;

res_L = 2.0;
res_W = 1.2;
res_H = 0.6;

module rounded_pcb(L, W, T, r) {
    // Exact outer size L x W, thickness T
    linear_extrude(height=T, center=true)
        offset(r=r)
            square([L - 2*r, W - 2*r], center=true);
}

module block(sz=[1,1,1]) { cube(sz, center=true); }

module battery_charger_module() {
    union() {
        // PCB body (exact 26.2 x 17.5 x 1.0)
        rounded_pcb(pcb_L, pcb_W, pcb_T, corner_r);

        // Micro-USB-like connector on +Y edge (connected)
        translate([0,
                   pcb_W/2 + usb_D/2 - overlap,
                   pcb_T/2 + usb_H/2 - overlap])
            block([usb_W, usb_D, usb_H]);

        // Small "tongue" inside USB (still one solid; just a cue)
        tongue_W = usb_W * 0.55;
        tongue_D = usb_D * 0.55;
        tongue_H = 0.8;
        translate([0,
                   pcb_W/2 + tongue_D/2 - overlap,
                   pcb_T/2 + tongue_H/2 - overlap])
            block([tongue_W, tongue_D, tongue_H]);

        // 2-pin battery pads on -Y edge (connected)
        pad_y = -(pcb_W/2 - pad_W/2);
        pad_z = pcb_T/2 + pad_H/2 - overlap;
        pad_x_off = 3.2;
        translate([ pad_x_off, pad_y, pad_z]) block([pad_L, pad_W, pad_H]);
        translate([-pad_x_off, pad_y, pad_z]) block([pad_L, pad_W, pad_H]);

        // Small IC on top (connected)
        chip_x = -(pcb_L/2 - (chip_L/2 + 2.0));
        translate([chip_x,
                   0,
                   pcb_T/2 + chip_H/2 - overlap])
            block([chip_L, chip_W, chip_H]);

        // Inductor / larger component on top (connected)
        ind_x = (pcb_L/2 - (ind_L/2 + 2.0));
        translate([ind_x,
                   0,
                   pcb_T/2 + ind_H/2 - overlap])
            block([ind_L, ind_W, ind_H]);

        // Side header block along +X edge (connected)
        translate([pcb_L/2 + header_W/2 - overlap,
                   0,
                   pcb_T/2 + header_H/2 - overlap])
            block([header_W, header_L, header_H]);

        // Two small LEDs near +Y edge (connected)
        led_y = pcb_W/2 - (led_W/2 + 1.2);
        led_z = pcb_T/2 + led_H/2 - overlap;
        led_x_off = 3.0;
        translate([ led_x_off, led_y, led_z]) block([led_L, led_W, led_H]);
        translate([-led_x_off, led_y, led_z]) block([led_L, led_W, led_H]);

        // Two resistors near IC (connected)
        res_y = -(pcb_W/2 - (res_W/2 + 3.0));
        res_z = pcb_T/2 + res_H/2 - overlap;
        translate([chip_x, res_y, res_z]) block([res_L, res_W, res_H]);
        translate([chip_x + (res_L + 0.8), res_y, res_z]) block([res_L, res_W, res_H]);
    }
}

// Render
color([0.0, 0.4, 0.2])
battery_charger_module();