$fn = 64;

// -------------------- Parameters --------------------
pcb_L = 100.75;   // mm
pcb_W = 70.25;    // mm
pcb_T = 1.6;      // mm
corner_R = 3.0;   // mm

hole_d = 3.2;             // mm
hole_edge_offset = 5.0;   // mm (from each edge to hole center)
hole_overlap = 0.8;       // mm (extra cut depth)

component_clearance = 0.6; // mm (gap from PCB edge to component body)
overlap = 0.6;             // mm (ensures solids intersect -> one connected solid)

// --- Mainboard feature sizes (simple but recognizable) ---
usb_L = 14.0; usb_W = 12.0; usb_H = 7.0;          // USB-B-ish block
usb_tongue_L = 8.0; usb_tongue_W = 8.0; usb_tongue_H = 3.0;

term_L = 34.0; term_W = 12.0; term_H = 12.0;      // screw terminal block
term_slot_L = 28.0; term_slot_W = 4.0; term_slot_H = 4.0;

header_L = 44.0; header_W = 7.0; header_H = 9.0;  // pin header shroud
header_pin_pitch = 2.54;
header_pin_r = 0.6;
header_pin_h = 3.0;

chip_L = 16.0; chip_W = 16.0; chip_H = 2.2;       // main MCU
chip_pin_L = 1.2; chip_pin_W = 0.6; chip_pin_H = 0.6;

cap_r = 3.0; cap_h = 6.0;                          // electrolytic cap
ind_L = 10.0; ind_W = 10.0; ind_H = 5.0;           // inductor block

sd_L = 16.0; sd_W = 14.0; sd_H = 2.2;              // microSD socket-ish
sd_lip_L = 12.0; sd_lip_W = 10.0; sd_lip_H = 1.2;

ic_L = 10.0; ic_W = 8.0; ic_H = 1.6;               // small driver IC

silk_T = 0.25;
silk_inset = 2.0;
silk_line_w = 0.9;

// -------------------- Geometry helpers --------------------
module pcb_main_rounded() {
    linear_extrude(height = pcb_T, center = true)
        hull() {
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(pcb_L/2 - corner_R), sy*(pcb_W/2 - corner_R)])
                    circle(r = corner_R);
        }
}

module mounting_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(pcb_L/2 - hole_edge_offset), sy*(pcb_W/2 - hole_edge_offset), 0])
            cylinder(h = pcb_T + 2*hole_overlap, r = hole_d/2, center = true);
}

module silkscreen_markings() {
    // Slightly above PCB top, but overlapping into PCB to keep ONE connected solid
    z = pcb_T/2 + silk_T/2 - overlap;
    difference() {
        translate([0, 0, z])
            cube([pcb_L - 2*silk_inset, pcb_W - 2*silk_inset, silk_T], center = true);
        translate([0, 0, z])
            cube([pcb_L - 2*(silk_inset + silk_line_w),
                  pcb_W - 2*(silk_inset + silk_line_w),
                  silk_T + 2*overlap], center = true);
    }
}

// -------------------- Components (all intersect PCB by overlap) --------------------
module usb_connector() {
    // On left edge, centered in Y
    x = -pcb_L/2 + component_clearance + usb_L/2;
    z = pcb_T/2 + usb_H/2 - overlap;

    union() {
        // main shell
        translate([x, 0, z])
            cube([usb_L, usb_W, usb_H], center = true);

        // inner tongue (protrudes slightly outward, still connected via overlap into shell)
        tongue_x = x - usb_L/2 + usb_tongue_L/2 - overlap;
        tongue_z = pcb_T/2 + usb_tongue_H/2 - overlap;
        translate([tongue_x, 0, tongue_z])
            cube([usb_tongue_L, usb_tongue_W, usb_tongue_H], center = true);
    }
}

module screw_terminal() {
    // On top edge (+Y), centered in X
    y = pcb_W/2 - component_clearance - term_W/2;
    z = pcb_T/2 + term_H/2 - overlap;

    union() {
        translate([0, y, z])
            cube([term_L, term_W, term_H], center = true);

        // wire entry slot (a shallow recess look by adding a "lip" block)
        slot_y = y + term_W/2 - term_slot_W/2 - overlap;
        slot_z = pcb_T/2 + term_slot_H/2 - overlap;
        translate([0, slot_y, slot_z])
            cube([term_slot_L, term_slot_W, term_slot_H], center = true);
    }
}

module pin_header() {
    // On bottom-right area: near +X and -Y edges
    x = pcb_L/2 - component_clearance - header_L/2;
    y = -pcb_W/2 + component_clearance + header_W/2;
    z = pcb_T/2 + header_H/2 - overlap;

    union() {
        // shroud
        translate([x, y, z])
            cube([header_L, header_W, header_H], center = true);

        // pins (small cylinders) on top of shroud
        pins_z = pcb_T/2 + header_H - overlap + header_pin_h/2;
        // number of pins along length (approx)
        n = floor((header_L - 2.0) / header_pin_pitch);
        start = -((n-1) * header_pin_pitch)/2;

        for (i = [0:n-1]) {
            px = x + start + i*header_pin_pitch;
            translate([px, y, pins_z])
                cylinder(h = header_pin_h, r = header_pin_r, center = true);
        }
    }
}

module main_chip() {
    // Centered IC with simple "pins" on two sides
    z = pcb_T/2 + chip_H/2 - overlap;

    union() {
        translate([0, 0, z])
            cube([chip_L, chip_W, chip_H], center = true);

        // pins on left/right sides (as small ribs), connected by overlap into body
        pin_z = pcb_T/2 + chip_pin_H/2 - overlap;
        pin_x_off = chip_L/2 + chip_pin_L/2 - overlap;

        // count along Y
        n = 10;
        pitch = (chip_W - 2.0) / (n-1);
        start = - (chip_W - 2.0)/2;

        for (i = [0:n-1]) {
            py = start + i*pitch;
            translate([ pin_x_off, py, pin_z])
                cube([chip_pin_L, chip_pin_W, chip_pin_H], center = true);
            translate([-pin_x_off, py, pin_z])
                cube([chip_pin_L, chip_pin_W, chip_pin_H], center = true);
        }
    }
}

module micro_sd_socket() {
    // On right edge, upper half
    x = pcb_L/2 - component_clearance - sd_L/2;
    y = pcb_W/4;
    z = pcb_T/2 + sd_H/2 - overlap;

    union() {
        translate([x, y, z])
            cube([sd_L, sd_W, sd_H], center = true);

        // front lip (toward +X edge), slightly taller
        lip_x = x + sd_L/2 - sd_lip_L/2 - overlap;
        lip_z = pcb_T/2 + (sd_H + sd_lip_H)/2 - overlap;
        translate([lip_x, y, lip_z])
            cube([sd_lip_L, sd_lip_W, sd_lip_H], center = true);
    }
}

module power_capacitor() {
    // Near top-left quadrant
    x = -pcb_L/4;
    y = pcb_W/4;
    z = pcb_T/2 + cap_h/2 - overlap;

    union() {
        translate([x, y, z])
            cylinder(h = cap_h, r = cap_r, center = true);

        // small base to look like can base, still connected
        base_h = 1.0;
        base_r = cap_r + 0.6;
        base_z = pcb_T/2 + base_h/2 - overlap;
        translate([x, y, base_z])
            cylinder(h = base_h, r = base_r, center = true);
    }
}

module inductor_block() {
    // Near bottom-left quadrant
    x = -pcb_L/4;
    y = -pcb_W/4;
    z = pcb_T/2 + ind_H/2 - overlap;

    translate([x, y, z])
        cube([ind_L, ind_W, ind_H], center = true);
}

module driver_ics_row() {
    // Row of small ICs near bottom edge
    y = -pcb_W/2 + component_clearance + ic_W/2 + 10;
    z = pcb_T/2 + ic_H/2 - overlap;

    // place 4 ICs across X
    n = 4;
    span = pcb_L * 0.55;
    pitch = span/(n-1);
    start = -span/2;

    for (i = [0:n-1]) {
        x = start + i*pitch;
        translate([x, y, z])
            cube([ic_L, ic_W, ic_H], center = true);
    }
}

// -------------------- Complete model (ONE connected solid) --------------------
module complete_mainboard_model() {
    union() {
        // PCB with holes
        difference() {
            pcb_main_rounded();
            mounting_holes();
        }

        // Add-on solids (all overlap into PCB)
        silkscreen_markings();

        usb_connector();
        screw_terminal();
        pin_header();
        micro_sd_socket();

        main_chip();
        power_capacitor();
        inductor_block();
        driver_ics_row();
    }
}

// Render
color([0.0, 0.4, 0.2])
complete_mainboard_model();