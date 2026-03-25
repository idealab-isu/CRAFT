$fn = 48;

// Target overall size (module footprint)
length = 26.2;
width  = 17.5;
thickness = 1.0;

// Overlap to guarantee a single connected solid (1–2mm as required)
overlap = 1.0;

// Rounded rectangle prism
module rounded_plate(l, w, h, r=0, center=true) {
    r2 = min(r, min(l, w)/2);
    if (r2 <= 0) {
        cube([l, w, h], center=center);
    } else {
        translate(center ? [0,0,0] : [l/2, w/2, h/2])
            linear_extrude(height=h, center=true)
                offset(r=r2)
                    square([l-2*r2, w-2*r2], center=true);
    }
}

// Battery charger module (single connected solid)
module charger_module() {
    // PCB thickness (kept within overall thickness)
    pcb_t = 0.8;

    // Component heights
    usb_h = 2.6;
    pad_h = 0.6;
    ic_h  = 1.2;
    led_h = 0.8;

    // Feature sizes (within footprint)
    usb_w = 7.6;
    usb_d = 5.8;

    pad_w = 3.0;
    pad_d = 2.2;

    ic_l = 5.0;
    ic_w = 4.0;

    led_r = 0.7;

    // --- Z references (PCB centered so bottom is at -thickness/2) ---
    pcb_z      = -thickness/2 + pcb_t/2;
    pcb_top_z  = -thickness/2 + pcb_t;
    pcb_bot_z  = -thickness/2;

    // Place each TOP component so its bottom penetrates into PCB by `overlap`
    usb_z = pcb_top_z - overlap + usb_h/2;
    pad_z = pcb_top_z - overlap + pad_h/2;
    ic_z  = pcb_top_z - overlap + ic_h/2;

    // Place BOTTOM feature (red) so its top penetrates into PCB by `overlap`
    led_z = pcb_bot_z + overlap - led_h/2;

    // --- XY positions (recalculated to ensure seated/flush and within footprint) ---
    // USB connector: seated at the LEFT edge (as in side view), centered in Y
    usb_x = -length/2 + usb_w/2;
    usb_y = 0;

    // Two solder pads: near left/right, centered in Y (as in top view)
    pad_y = 0;
    pad_x_off = length*0.28;

    // Charger IC: slightly right of center, slightly down (matches typical layout)
    ic_x = length*0.10;
    ic_y = -width*0.10;

    // Small red feature: on bottom side, near lower-right quadrant
    led_x = length*0.30;
    led_y = -width*0.18;

    union() {
        // PCB
        color([0.0, 0.45, 0.2])
            translate([0, 0, pcb_z])
                rounded_plate(length, width, pcb_t, r=1.0, center=true);

        // USB connector block (fused into PCB via overlap)
        color([0.75, 0.75, 0.75])
            translate([usb_x, usb_y, usb_z])
                cube([usb_w, usb_d, usb_h], center=true);

        // Two solder pads (fused into PCB via overlap)
        color([0.85, 0.7, 0.2])
            for (sx = [-pad_x_off, pad_x_off]) {
                translate([sx, pad_y, pad_z])
                    cube([pad_w, pad_d, pad_h], center=true);
            }

        // Charger IC (fused into PCB via overlap)
        color([0.15, 0.15, 0.15])
            translate([ic_x, ic_y, ic_z])
                cube([ic_l, ic_w, ic_h], center=true);

        // Small red feature on the BOTTOM (fused into PCB via overlap)
        color([0.9, 0.1, 0.1])
            translate([led_x, led_y, led_z])
                cylinder(r=led_r, h=led_h, center=true);
    }
}

charger_module();