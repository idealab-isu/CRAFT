// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

$fn = 64;

// Feature parameters (derived from body dimensions)
corner_r   = min(body_width, body_height) * 0.18;
boss_r     = min(body_width, body_height) * 0.22;
boss_h     = body_height * 0.55;
boss_ovlp  = body_height * 0.08;   // overlap into body to ensure connectivity

slot_w     = body_width * 0.35;
slot_l     = body_length * 0.55;
slot_h     = body_height * 0.55;

hole_r     = min(body_width, body_height) * 0.12;
hole_x_off = body_length * 0.28;
hole_y_off = body_width  * 0.25;

// Rounded rectangular prism using hull of corner cylinders
module rounded_block(l, w, h, r) {
    r2 = min(r, min(l, w)/2 - 0.01);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r2), sy*(w/2 - r2), 0])
                cylinder(r=r2, h=h, center=true);
    }
}

// Main component: rounded body + top boss, with slot and mounting holes
module component() {
    difference() {
        union() {
            // Main body
            rounded_block(body_length, body_width, body_height, corner_r);

            // Top boss (connected via calculated placement + overlap)
            translate([0, 0, body_height/2 + boss_h/2 - boss_ovlp])
                cylinder(r=boss_r, h=boss_h, center=true);
        }

        // Central top slot/pocket (does not cut through bottom)
        translate([0, 0, body_height/2 - slot_h/2 + 0.01])
            cube([slot_l, slot_w, slot_h], center=true);

        // Two through mounting holes
        for (sx = [-1, 1])
            translate([sx*hole_x_off, hole_y_off, 0])
                cylinder(r=hole_r, h=body_height + boss_h + 2, center=true);
    }
}

// Final Output (single connected solid)
component();