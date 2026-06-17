// 20x80 aluminium extrusion (approximate T-slot profile), 100mm long
// Cross-section: X=20mm, Y=80mm, Length along Z=100mm

$fn = 64;

module extrusion_20x80(len=100, w=20, h=80) {
    wall = 2.0;          // outer wall thickness
    slot_open = 6.0;     // opening at the surface
    slot_depth = 8.0;    // depth of slot from surface inward
    slot_neck = 3.0;     // narrow neck inside slot
    slot_wide = 10.0;    // wider cavity inside slot
    bore_r = 2.6;        // center bore radius (approx M5 clearance)
    web = 2.0;           // intended internal web thickness

    // Robust boolean tolerances
    eps = 0.05;

    // Required overlap to guarantee physical attachment (1-2mm)
    overlap = 1.5;

    inner_w = max(w - 2*wall, 0.01);
    inner_h = max(h - 2*wall, 0.01);

    // Keep a guaranteed solid mid-web, and ensure cavities never meet at center.
    web_keep = web + 2*overlap;

    // Each side cavity width; never exceed available space
    cav_w = max((inner_w - web_keep)/2, 0.01);

    // Place cavities so their inner faces are at +/- web_keep/2 (leaves solid web)
    cav_x = (web_keep/2) + (cav_w/2);

    // Add a central "stitch" rib that overlaps both halves to eliminate any mid-plane split.
    // Make it slightly taller than inner_h to ensure it intersects the remaining material
    // even if slot subtractions create near-coplanar faces.
    stitch_w = web_keep + 2*overlap;     // overlaps into both sides
    stitch_h = inner_h + 2*overlap;      // overlaps into top/bottom inner walls
    stitch_z = len + 2*overlap;          // overlaps along length

    union() {
        // Main body with subtractive features
        difference() {
            // Outer envelope
            cube([w, h, len], center=true);

            // Internal lightening cavities (left/right), leaving a guaranteed central web
            for (sx = [-1, 1]) {
                translate([sx*cav_x, 0, 0])
                    cube([cav_w, inner_h + 2*eps, len + 2*eps], center=true);
            }

            // Center bore
            cylinder(r=bore_r, h=len + 2*eps, center=true);

            // T-slots on all four faces (subtractive)
            // X faces (left/right)
            for (sx = [-1, 1]) {
                // Surface opening
                translate([sx*(w/2 - slot_depth/2 + eps), 0, 0])
                    cube([slot_depth + 2*eps, slot_open, len + 2*eps], center=true);

                // Neck (slightly deeper)
                translate([sx*(w/2 - (slot_depth*0.65)/2 + eps), 0, 0])
                    cube([slot_depth*0.65 + 2*eps, slot_neck, len + 2*eps], center=true);

                // Inner wider cavity (kept within wall region so it doesn't sever the web)
                translate([sx*(w/2 - wall - (slot_depth*0.35)/2), 0, 0])
                    cube([slot_depth*0.35 + 2*eps, slot_wide, len + 2*eps], center=true);
            }

            // Y faces (front/back)
            for (sy = [-1, 1]) {
                // Surface opening
                translate([0, sy*(h/2 - slot_depth/2 + eps), 0])
                    cube([slot_open, slot_depth + 2*eps, len + 2*eps], center=true);

                // Neck
                translate([0, sy*(h/2 - (slot_depth*0.65)/2 + eps), 0])
                    cube([slot_neck, slot_depth*0.65 + 2*eps, len + 2*eps], center=true);

                // Inner wider cavity
                translate([0, sy*(h/2 - wall - (slot_depth*0.35)/2), 0])
                    cube([slot_wide, slot_depth*0.35 + 2*eps, len + 2*eps], center=true);
            }
        }

        // Central stitch rib (adds material) to eliminate any mid-plane split/gap.
        // Oversized slightly so it *intersects* both halves by >= 1mm everywhere.
        cube([stitch_w, stitch_h, stitch_z], center=true);
    }
}

extrusion_20x80(len=100, w=20, h=80);