$fn = 48;

// Target overall PCB size
length = 26.2;
width  = 17.5;
thickness = 1.0;

// Small overlap to guarantee watertight unions
overlap = 0.2;

// Feature sizes (approximate, for recognizable charger-module look)
usb_w = 7.6;
usb_d = 5.8;
usb_h = 2.6;

chip_l = 6.2;
chip_w = 5.2;
chip_h = 1.2;

ind_r = 3.2;
ind_h = 1.8;

cap_r = 1.6;
cap_h = 2.2;

pad_l = 3.2;
pad_w = 2.2;
pad_h = 0.35;

hole_r = 0.75;

// Helpers
module rounded_board(l, w, h, r) {
    // Rounded rectangle prism via hull of corner cylinders
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r), 0])
                cylinder(r=r, h=h, center=true);
    }
}

module battery_charger_module() {
    // Build as ONE connected solid (union of board + components + pads + connector)
    union() {
        // PCB (slightly rounded corners)
        pcb_r = 1.2;
        color([0.05, 0.15, 0.55])
            rounded_board(length, width, thickness, pcb_r);

        // Mount holes (as shallow recesses, not through-holes, to keep single solid)
        hole_depth = 0.35;
        hole_z = -thickness/2 + hole_depth/2; // recess into bottom face
        hole_x = length/2 - 2.0;
        hole_y = width/2 - 2.0;
        color([0.03, 0.10, 0.40])
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*hole_x, sy*hole_y, hole_z])
                cylinder(r=hole_r, h=hole_depth + overlap, center=true);

        // USB connector at one short edge (protrudes outward, overlaps into PCB)
        usb_z = thickness/2 + usb_h/2 - overlap;
        usb_x = 0;
        usb_y = width/2 + usb_d/2 - overlap; // attached to +Y edge
        color([0.75, 0.75, 0.78])
            translate([usb_x, usb_y, usb_z])
                cube([usb_w, usb_d, usb_h], center=true);

        // Main charger IC (top side)
        chip_z = thickness/2 + chip_h/2 - overlap;
        chip_x = -length*0.10;
        chip_y = -width*0.05;
        color([0.12, 0.12, 0.12])
            translate([chip_x, chip_y, chip_z])
                cube([chip_l, chip_w, chip_h], center=true);

        // Inductor / coil (top side)
        ind_z = thickness/2 + ind_h/2 - overlap;
        ind_x = length*0.22;
        ind_y = -width*0.10;
        color([0.20, 0.20, 0.20])
            translate([ind_x, ind_y, ind_z])
                cylinder(r=ind_r, h=ind_h, center=true);

        // Two capacitors (top side)
        cap_z = thickness/2 + cap_h/2 - overlap;
        cap_x1 = length*0.28;
        cap_y1 = width*0.22;
        cap_x2 = -length*0.30;
        cap_y2 = width*0.18;
        color([0.35, 0.35, 0.35]) {
            translate([cap_x1, cap_y1, cap_z]) cylinder(r=cap_r, h=cap_h, center=true);
            translate([cap_x2, cap_y2, cap_z]) cylinder(r=cap_r, h=cap_h, center=true);
        }

        // Battery pads at opposite short edge (bottom side pads, but kept solid)
        pad_z = -thickness/2 + pad_h/2; // sits on bottom face
        pad_y = -width/2 + pad_w/2;     // near -Y edge
        pad_x_off = 4.2;
        color([0.85, 0.70, 0.20]) {
            translate([-pad_x_off, pad_y, pad_z])
                cube([pad_l, pad_w, pad_h + overlap], center=true);
            translate([ pad_x_off, pad_y, pad_z])
                cube([pad_l, pad_w, pad_h + overlap], center=true);
        }

        // Small status LED bump near USB edge (top side)
        led_l = 1.6;
        led_w = 1.0;
        led_h = 0.7;
        led_z = thickness/2 + led_h/2 - overlap;
        led_x = length*0.30;
        led_y = width/2 - 3.0;
        color([0.80, 0.10, 0.10])
            translate([led_x, led_y, led_z])
                cube([led_l, led_w, led_h], center=true);
    }
}

battery_charger_module();