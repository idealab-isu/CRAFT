// DC-DC power converter module (ONE connected solid)
// Overall PCB: 78.0mm x 47.0mm x 1.6mm

$fn = 64;

// --- Parameters ---
length = 78.0;
width  = 47.0;
thickness = 1.6;

// Use a larger overlap (1-2mm) to guarantee watertight connectivity
overlap = 1.2;

// Typical DC-DC module features (approximate)
terminal_len = 10.0;
terminal_w   = 12.0;
terminal_h   = 10.0;

ind_r = 9.0;
ind_h = 7.0;

cap_r = 4.0;
cap_h = 10.0;

ic_len = 10.0;
ic_w   = 10.0;
ic_h   = 2.0;

heatsink_len = 18.0;
heatsink_w   = 14.0;
heatsink_h   = 8.0;

pin_count = 6;
pin_pitch = 2.54;
pin_d = 1.0;
pin_h = 6.0;

// Added: header plastic body to physically connect pins to PCB (and to each other)
hdr_body_h = 3.0;                 // small plastic spacer height
hdr_body_w = pin_pitch * 2.2;     // ~5.6mm for 2.54mm pitch headers
hdr_body_l = (pin_count - 1) * pin_pitch + 2.0; // span + margins

// --- Helpers ---
module rounded_pcb(l, w, h, r) {
    // Robust rounded rectangle prism (no Minkowski degeneracy)
    // Centered at origin.
    linear_extrude(height=h, center=true, convexity=10)
        offset(r=r)
            square([l - 2*r, w - 2*r], center=true);
}

module place_on_top(pcb_top_z, h) {
    // Places a centered object of height h so it sits on top of PCB with slight overlap
    translate([0, 0, pcb_top_z + h/2 - overlap]) children();
}

module place_on_bottom(pcb_bot_z, h) {
    // Places a centered object of height h so it sits on bottom of PCB with slight overlap
    translate([0, 0, pcb_bot_z - h/2 + overlap]) children();
}

// --- Main assembly (ONE connected solid) ---
module dcdc_module() {
    pcb_r = 2.0;
    pcb_top_z = thickness/2;
    pcb_bot_z = -thickness/2;

    // Pin header placement
    pins_span = (pin_count - 1) * pin_pitch;
    pin_row_y = -(width/2 - 3.0);

    union() {
        // PCB body
        rounded_pcb(length, width, thickness, pcb_r);

        // Terminal blocks on opposite short edges (left/right)
        translate([-(length/2 - terminal_len/2), 0, 0])
            place_on_top(pcb_top_z, terminal_h)
                cube([terminal_len, terminal_w, terminal_h], center=true);

        translate([(length/2 - terminal_len/2), 0, 0])
            place_on_top(pcb_top_z, terminal_h)
                cube([terminal_len, terminal_w, terminal_h], center=true);

        // Inductor (large cylinder) near left-middle
        translate([-(length*0.18), width*0.12, 0])
            place_on_top(pcb_top_z, ind_h)
                cylinder(r=ind_r, h=ind_h, center=true);

        // Electrolytic capacitor near right-middle
        translate([(length*0.18), -width*0.10, 0])
            place_on_top(pcb_top_z, cap_h)
                cylinder(r=cap_r, h=cap_h, center=true);

        // Controller IC near center
        translate([0, 0, 0])
            place_on_top(pcb_top_z, ic_h)
                cube([ic_len, ic_w, ic_h], center=true);

        // Heatsink block near center-right
        translate([length*0.10, width*0.18, 0])
            place_on_top(pcb_top_z, heatsink_h)
                cube([heatsink_len, heatsink_w, heatsink_h], center=true);

        // --- FIX: Pin header row must be physically attached (no floating pins) ---
        // Add a small header plastic body that overlaps into the PCB,
        // and make pins overlap into that body as well.
        translate([0, pin_row_y, 0]) {
            // Header plastic body (sits under PCB, overlaps into PCB by 'overlap')
            place_on_bottom(pcb_bot_z, hdr_body_h)
                cube([hdr_body_l, hdr_body_w, hdr_body_h], center=true);

            // Pins: place so their TOP penetrates into the header body by ~overlap
            // Header body top Z (global) = pcb_bot_z + overlap
            // Pin center Z = (header_top - overlap) - pin_h/2
            pin_center_z = (pcb_bot_z + overlap - overlap) - pin_h/2; // = pcb_bot_z - pin_h/2

            for (i = [0:pin_count-1]) {
                translate([i*pin_pitch - pins_span/2, 0, pin_center_z])
                    cylinder(d=pin_d, h=pin_h, center=true);
            }
        }

        // Small SMD resistor/capacitor cluster (top side)
        smd_h = 1.2;
        smd_l = 3.2;
        smd_w = 1.6;

        for (dx = [-1, 0, 1], dy = [-1, 1]) {
            translate([dx*6.0, dy*8.0, 0])
                place_on_top(pcb_top_z, smd_h)
                    cube([smd_l, smd_w, smd_h], center=true);
        }
    }
}

dcdc_module();