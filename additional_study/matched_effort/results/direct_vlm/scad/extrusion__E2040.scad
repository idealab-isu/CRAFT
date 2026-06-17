$fn = 96;

// 20x40 aluminium extrusion profile (approximate), 100mm long
// Cross-section: 20mm (X) x 40mm (Y), extruded along Z

length = 100;
w = 20;
h = 40;

// Profile parameters (typical-ish for 2040)
wall = 2.0;          // outer wall thickness
slot_open = 6.0;     // slot mouth opening
slot_depth = 6.0;    // how far slot cuts in from outer face
center_hole_d = 5.2; // center bore
web = 2.0;           // internal web thickness
eps = 0.05;          // tiny overlap to avoid coincident faces

module profile_2040_2d() {
    difference() {
        // ONE connected outer body
        square([w, h], center=true);

        // Center bore
        circle(d=center_hole_d);

        // Internal lightening pockets (kept inside walls/webs)
        // Four corner pockets
        pocket_w = w/2 - wall - web/2;
        pocket_h = h/2 - wall - web/2;

        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([sx*(w/4), sy*(h/4)])
                square([pocket_w, pocket_h], center=true);
        }

        // Central cross pocket to reduce mass but keep a connected "plus" web
        // (does not reach outer walls)
        square([w - 2*(wall + web), web], center=true);
        square([web, h - 2*(wall + web)], center=true);

        // T-slot cuts on all four sides (rectangular approximation)
        // +Y / -Y
        for (sy = [-1, 1]) {
            translate([0, sy*(h/2 - slot_depth/2 + eps)])
                square([slot_open, slot_depth + 2*eps], center=true);
        }
        // +X / -X
        for (sx = [-1, 1]) {
            translate([sx*(w/2 - slot_depth/2 + eps), 0])
                square([slot_depth + 2*eps, slot_open], center=true);
        }
    }
}

linear_extrude(height=length, center=false, convexity=10)
    profile_2040_2d();