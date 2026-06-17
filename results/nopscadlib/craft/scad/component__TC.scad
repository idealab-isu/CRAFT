$fn = 64;

// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

// Detail parameters (derived)
wall = max(2, body_height*0.18);
corner_r = min(body_width, body_length) * 0.12;

boss_r = min(body_width, body_length) * 0.12;
boss_h = body_height * 0.55;

hole_r = boss_r * 0.45;

slot_w = body_width * 0.22;
slot_l = body_length * 0.55;
slot_depth = body_height * 0.55;

tab_w = body_width * 0.35;
tab_l = body_length * 0.22;
tab_h = body_height * 0.55;

overlap = 0.6;

// Rounded rectangle prism via hull of cylinders
module rounded_block(l, w, h, r) {
    r2 = min(r, min(l, w)/2 - 0.01);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r2), sy*(w/2 - r2), 0])
                cylinder(r=r2, h=h, center=true);
    }
}

// Main component
module component() {
    difference() {
        union() {
            // Base body
            rounded_block(body_length, body_width, body_height, corner_r);

            // Side mounting tab (connected with overlap)
            translate([body_length/2 + tab_l/2 - overlap, 0, 0])
                rounded_block(tab_l, tab_w, tab_h, min(corner_r*0.8, tab_w/2 - 0.01));

            // Two top bosses (connected)
            boss_x = body_length*0.22;
            boss_y = body_width*0.22;
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*boss_x, sy*boss_y, body_height/2 + boss_h/2 - overlap])
                    cylinder(r=boss_r, h=boss_h, center=true);
        }

        // Through holes in bosses
        boss_x = body_length*0.22;
        boss_y = body_width*0.22;
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*boss_x, sy*boss_y, 0])
                cylinder(r=hole_r, h=body_height + boss_h + 2, center=true);

        // Central top pocket/slot (non-through)
        translate([0, 0, body_height/2 - slot_depth/2 + overlap])
            rounded_block(slot_l, slot_w, slot_depth + overlap, min(corner_r*0.6, slot_w/2 - 0.01));

        // Side tab mounting hole (through tab)
        translate([body_length/2 + tab_l/2 - overlap, 0, 0])
            rotate([0, 90, 0])
                cylinder(r=hole_r*0.95, h=tab_l + 2, center=true);

        // Bottom relief notch (adds asymmetry)
        notch_l = body_length*0.28;
        notch_w = body_width*0.35;
        notch_h = body_height*0.45;
        translate([-body_length*0.18, 0, -body_height/2 + notch_h/2 - overlap])
            rounded_block(notch_l, notch_w, notch_h + overlap, min(corner_r*0.6, notch_w/2 - 0.01));
    }
}

// Final Model (single connected solid)
component();