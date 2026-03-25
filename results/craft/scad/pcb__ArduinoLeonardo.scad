// Microcontroller development board (connected solid)
// Target PCB: 68.58mm x 53.34mm x 1.6mm

$fn = 48;

// Parameters
length = 68.58;
width  = 53.34;
thickness = 1.6;

// Small overlap to guarantee watertight unions
ov = 0.2;

// Helper: rounded rectangle prism (centered)
module rounded_rect_prism(l, w, h, r) {
    linear_extrude(height=h, center=true)
        offset(r=r)
            square([l-2*r, w-2*r], center=true);
}

module dev_board() {
    // PCB outline (rounded corners)
    pcb_r = 2.5;

    // Major features (kept simple but recognizable)
    usb_l = 12.0;
    usb_w = 10.0;
    usb_h = 4.0;

    header_h = 8.5;
    header_w = 5.0;
    header_l_long = length - 10.0;
    header_l_short = length - 22.0;

    mcu_l = 18.0;
    mcu_w = 18.0;
    mcu_h = 2.2;

    // Place everything so the bottom of PCB is at z=0 (easier to reason about)
    union() {
        // PCB
        translate([0, 0, thickness/2])
            rounded_rect_prism(length, width, thickness, pcb_r);

        // USB connector on one short edge (protrudes outward, but overlaps into PCB)
        // Positioned at +Y edge, centered in X
        translate([0,
                   width/2 + usb_l/2 - ov,
                   thickness + usb_h/2 - ov])
            cube([usb_w, usb_l, usb_h], center=true);

        // Two long header blocks along the long edges (top side), overlapping into PCB
        // Left edge header
        translate([0,
                   -width/2 + header_w/2 - ov,
                   thickness + header_h/2 - ov])
            cube([header_l_long, header_w, header_h], center=true);

        // Right edge header
        translate([0,
                   width/2 - header_w/2 + ov,
                   thickness + header_h/2 - ov])
            cube([header_l_short, header_w, header_h], center=true);

        // Main MCU package near center (top side)
        translate([0,
                   0,
                   thickness + mcu_h/2 - ov])
            cube([mcu_l, mcu_w, mcu_h], center=true);

        // Small power jack-like block near USB (top side), connected
        jack_l = 14.0;
        jack_w = 10.0;
        jack_h = 6.0;
        translate([-(length/2 - jack_l/2 - 6.0),
                   width/2 - jack_w/2 - 6.0,
                   thickness + jack_h/2 - ov])
            cube([jack_l, jack_w, jack_h], center=true);

        // A few low-profile components (top side) to avoid "blank slab" look
        comp_h = 1.2;
        for (p = [
            [ length*0.20,  width*0.10, 6, 4],
            [-length*0.18, -width*0.12, 7, 5],
            [ length*0.05, -width*0.22, 5, 3],
            [-length*0.05,  width*0.22, 5, 3]
        ]) {
            translate([p[0], p[1], thickness + comp_h/2 - ov])
                cube([p[2], p[3], comp_h], center=true);
        }
    }
}

dev_board();