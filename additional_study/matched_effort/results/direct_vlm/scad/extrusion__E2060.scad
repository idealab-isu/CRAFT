$fn = 64;

// 20x60 aluminium extrusion profile (T-slot style), 100mm long
length = 100;
w = 60;
h = 20;

// Typical-ish proportions for 20-series extrusion (kept parametric)
wall      = 2.0;   // outer wall thickness
web       = 2.0;   // internal cross web thickness (keeps ONE connected solid)
slot_w    = 6.0;   // slot opening width
slot_depth= 5.0;   // slot depth from outer face inward
lip       = 1.5;   // small "T-slot lip" thickness near the opening
eps       = 0.05;  // tiny overlap to avoid coincident faces

module extrusion_20x60_profile_2d() {
    difference() {
        // Outer boundary
        square([w, h], center=true);

        // Hollow interior (leave outer wall)
        square([w - 2*wall, h - 2*wall], center=true);

        // Re-add internal webs so the profile is ONE connected solid
        union() {
            square([web, h - 2*wall + 2*eps], center=true); // vertical web
            square([w - 2*wall + 2*eps, web], center=true); // horizontal web
        }

        // T-slot openings (cut from outside inward), with a slight undercut behind the lips
        // Right slot
        translate([ w/2 - slot_depth/2, 0 ])
            square([slot_depth + eps, slot_w], center=true);
        translate([ w/2 - (slot_depth - lip)/2 - lip, 0 ])
            square([slot_depth - lip + eps, slot_w + 2*lip], center=true);

        // Left slot
        translate([ -w/2 + slot_depth/2, 0 ])
            square([slot_depth + eps, slot_w], center=true);
        translate([ -w/2 + (slot_depth - lip)/2 + lip, 0 ])
            square([slot_depth - lip + eps, slot_w + 2*lip], center=true);

        // Top slot
        translate([ 0,  h/2 - slot_depth/2 ])
            square([slot_w, slot_depth + eps], center=true);
        translate([ 0,  h/2 - (slot_depth - lip)/2 - lip ])
            square([slot_w + 2*lip, slot_depth - lip + eps], center=true);

        // Bottom slot
        translate([ 0, -h/2 + slot_depth/2 ])
            square([slot_w, slot_depth + eps], center=true);
        translate([ 0, -h/2 + (slot_depth - lip)/2 + lip ])
            square([slot_w + 2*lip, slot_depth - lip + eps], center=true);
    }
}

color([0.75, 0.75, 0.78])
linear_extrude(height=length, center=false, convexity=10)
    extrusion_20x60_profile_2d();