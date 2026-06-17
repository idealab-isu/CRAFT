// Battery charger module (PCB + components) — one connected solid
// Overall PCB: 26.2mm x 17.5mm x 1.0mm

$fn = 48;

// Board dimensions
length_mm    = 26.2;
width_mm     = 17.5;
thickness_mm = 1.0;

// Structural overlap to guarantee watertight unions (1–2mm as required)
overlap = 1.2;

// Helper: rounded rectangle prism
module rounded_rect_prism(l, w, h, r, center=false) {
    r2 = min(r, min(l, w)/2);
    translate(center ? [0,0,0] : [l/2, w/2, h/2])
        linear_extrude(height=h, center=true)
            offset(r=r2)
                square([l-2*r2, w-2*r2], center=true);
}

// Main model
module charger_module() {
    // PCB
    pcb_r = 1.2;
    pcb_h = thickness_mm;

    // Component heights (above PCB top)
    comp_h_low  = 0.8;
    comp_h_mid  = 1.6;
    comp_h_tall = 2.6;

    // Z references (PCB centered at Z=0)
    pcb_zc      = 0;
    pcb_top_z   = pcb_zc + pcb_h/2;
    pcb_bot_z   = pcb_zc - pcb_h/2;

    union() {
        // PCB body
        color([0.0, 0.45, 0.25])
            rounded_rect_prism(length_mm, width_mm, pcb_h, pcb_r, center=true);

        // --- USB connector: ensure it is physically attached (overlap into PCB) ---
        usb_w = 7.6;
        usb_l = 5.8;   // protrudes outward from board edge (Y+)
        usb_h = 2.6;

        // Inner face must penetrate PCB by 'overlap'
        // inner face y = usb_y - usb_l/2 = width/2 - overlap
        usb_y = width_mm/2 + usb_l/2 - overlap;

        // Bottom must penetrate PCB top by 'overlap'
        // bottom z = usb_z - usb_h/2 = pcb_top_z - overlap
        usb_z = pcb_top_z + usb_h/2 - overlap;

        translate([0, usb_y, usb_z])
            color([0.75, 0.75, 0.78])
                cube([usb_w, usb_l, usb_h], center=true);

        // Small "tongue" under connector (also overlaps into PCB)
        tongue_w = 5.6;
        tongue_l = 2.2;
        tongue_h = 0.8;

        tongue_y = width_mm/2 + tongue_l/2 - overlap;
        tongue_z = pcb_top_z + tongue_h/2 - overlap;

        translate([0, tongue_y, tongue_z])
            color([0.65, 0.65, 0.68])
                cube([tongue_w, tongue_l, tongue_h], center=true);

        // Robust bridge/anchor that straddles PCB edge and intersects USB body
        // (guarantees no visible gap in side views)
        anchor_w = usb_w * 0.80;
        anchor_l = overlap * 2.0;          // straddles the PCB edge in Y
        anchor_h = pcb_h + overlap * 2.0;  // spans through PCB thickness a bit
        anchor_y = width_mm/2 - overlap/2; // centered on PCB edge
        anchor_z = 0;

        translate([0, anchor_y, anchor_z])
            color([0.70, 0.70, 0.72])
                cube([anchor_w, anchor_l, anchor_h], center=true);

        // Battery pads at opposite short edge (two pads) - overlap into PCB
        pad_w = 3.2;
        pad_l = 2.6;
        pad_h = 0.25;

        pad_y = -width_mm/2 + pad_l/2;
        pad_z = pcb_top_z + pad_h/2 - overlap;

        translate([-3.2, pad_y, pad_z])
            color([0.85, 0.7, 0.2])
                cube([pad_w, pad_l, pad_h], center=true);

        translate([ 3.2, pad_y, pad_z])
            color([0.85, 0.7, 0.2])
                cube([pad_w, pad_l, pad_h], center=true);

        // Main charger IC (center-ish) - overlap into PCB
        ic_l = 6.0;
        ic_w = 6.0;
        ic_h = comp_h_mid;

        translate([0, 0.5, pcb_top_z + ic_h/2 - overlap])
            color([0.12, 0.12, 0.12])
                cube([ic_l, ic_w, ic_h], center=true);

        // --- Small light-gray rectangular component near center: FIXED (no hovering) ---
        // Ensure bottom penetrates PCB top by 'overlap' (same rule as other top components)
        smd_l = 2.6;
        smd_w = 1.8;
        smd_h = 0.9;

        // Place it near the IC (left side), matching the visual intent
        smd_x = -length_mm*0.18;
        smd_y = 0.5;

        // bottom z = pcb_top_z - overlap  => z = pcb_top_z + smd_h/2 - overlap
        smd_z = pcb_top_z + smd_h/2 - overlap;

        translate([smd_x, smd_y, smd_z])
            color([0.78, 0.78, 0.78])
                cube([smd_l, smd_w, smd_h], center=true);

        // Inductor / large component (taller block) - overlap into PCB
        ind_l = 7.0;
        ind_w = 6.0;
        ind_h = comp_h_tall;

        translate([length_mm*0.22, -0.5, pcb_top_z + ind_h/2 - overlap])
            color([0.2, 0.2, 0.2])
                cube([ind_l, ind_w, ind_h], center=true);

        // Two capacitors (small cylinders) - overlap into PCB
        cap_r = 1.4;
        cap_h = comp_h_mid;

        translate([-length_mm*0.28,  2.0, pcb_top_z + cap_h/2 - overlap])
            color([0.18, 0.18, 0.18])
                cylinder(r=cap_r, h=cap_h, center=true);

        translate([-length_mm*0.28, -2.2, pcb_top_z + cap_h/2 - overlap])
            color([0.18, 0.18, 0.18])
                cylinder(r=cap_r, h=cap_h, center=true);

        // Status LEDs (two tiny blocks near USB edge) - overlap into PCB
        led_l = 1.6;
        led_w = 1.0;
        led_h = comp_h_low;

        led_y = width_mm/2 - 3.2;
        translate([-2.0, led_y, pcb_top_z + led_h/2 - overlap])
            color([0.9, 0.1, 0.1])
                cube([led_l, led_w, led_h], center=true);

        translate([ 2.0, led_y, pcb_top_z + led_h/2 - overlap])
            color([0.1, 0.8, 0.1])
                cube([led_l, led_w, led_h], center=true);

        // Bottom-side solder blobs/pads (kept connected by overlap into PCB)
        bot_pad_l = 10.0;
        bot_pad_w = 3.0;
        bot_pad_h = 0.25;

        // top of bottom pad penetrates PCB bottom by 'overlap'
        // top z = z_center + bot_pad_h/2 = pcb_bot_z + overlap
        translate([0, -1.0, pcb_bot_z - bot_pad_h/2 + overlap])
            color([0.75, 0.75, 0.75])
                cube([bot_pad_l, bot_pad_w, bot_pad_h], center=true);

        // Side header pads (4 pads) along one long edge - overlap into PCB
        hp_w = 1.6;
        hp_l = 2.2;
        hp_h = 0.25;

        hp_x0 = -length_mm/2 + 5.0;
        hp_dx = 3.0;
        hp_y  = -width_mm/2 + hp_l/2 + 0.6;
        hp_z  = pcb_top_z + hp_h/2 - overlap;

        for (i = [0:3]) {
            translate([hp_x0 + i*hp_dx, hp_y, hp_z])
                color([0.85, 0.7, 0.2])
                    cube([hp_w, hp_l, hp_h], center=true);
        }
    }
}

charger_module();