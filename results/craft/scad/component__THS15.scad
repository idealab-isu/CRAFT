$fn = 96;

// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

// Detail parameters (derived)
corner_r = min(3, min(body_length, body_width)/8);
lip_h    = max(2, body_height*0.35);
lip_t    = max(2, min(body_length, body_width)*0.08);

slot_w   = max(6, body_width*0.22);
slot_l   = max(18, body_length*0.55);
slot_h   = body_height + 2;

hole_r   = max(2.2, min(body_length, body_width)*0.06);
hole_off = min(body_length, body_width)*0.22;

boss_r   = hole_r + max(2.2, min(body_length, body_width)*0.05);
boss_h   = max(2.5, body_height*0.55);

overlap  = 0.6;

// Rounded rectangle prism
module rounded_box(l, w, h, r) {
    r2 = min(r, min(l, w)/2 - 0.01);
    linear_extrude(height=h, center=true)
        offset(r=r2)
            square([l - 2*r2, w - 2*r2], center=true);
}

module component() {
    color([0.85, 0.85, 0.8])
    difference() {
        union() {
            // Main body with rounded corners
            rounded_box(body_length, body_width, body_height, corner_r);

            // Raised lip/step on top (connected with slight overlap)
            translate([0, 0, body_height/2 + lip_h/2 - overlap])
                rounded_box(body_length - 2*lip_t, body_width - 2*lip_t, lip_h, max(0.8, corner_r*0.7));

            // Two mounting bosses on top (connected)
            for (sx = [-1, 1])
                translate([sx*(body_length/2 - boss_r - lip_t), 0, body_height/2 + boss_h/2 - overlap])
                    cylinder(h=boss_h, r=boss_r, center=true);
        }

        // Through holes in bosses
        for (sx = [-1, 1])
            translate([sx*(body_length/2 - boss_r - lip_t), 0, 0])
                cylinder(h=body_height + lip_h + boss_h + 4, r=hole_r, center=true);

        // Central slot cutout (adds identifiable feature)
        translate([0, 0, 0])
            cube([slot_l, slot_w, slot_h], center=true);

        // Side notch cutout to make left/right distinguishable
        notch_w = max(6, body_width*0.28);
        notch_l = max(10, body_length*0.22);
        notch_h = body_height*0.7;
        translate([body_length/2 - notch_l/2 + overlap, -body_width/2 + notch_w/2, -body_height/2 + notch_h/2])
            cube([notch_l, notch_w, notch_h + 0.2], center=true);

        // Small chamfer-like corner relief (asymmetric)
        relief = max(4, min(body_length, body_width)*0.12);
        translate([-body_length/2 + relief/2, body_width/2 - relief/2, 0])
            rotate([0, 0, 45])
                cube([relief, relief, body_height + lip_h + boss_h + 2], center=true);
    }
}

// Final Model (one connected solid)
component();