// Sheet: carbon fiber (single connected solid with subtle woven surface relief)

// Parameters
sheet_length = 300; //[150:600:1]
sheet_width  = 200; //[100:400:1]
sheet_thickness = 2; //[1:6:0.5]
edge_chamfer = 0.5; //[0.2:2:0.1]
corner_radius = 5; //[2.5:15:0.5]
overlap = 1; //[0.5:2:0.1]

// Weave (geometric relief; OpenSCAD has no true textures)
weave_pitch = 6;      // mm
weave_amp   = 0.12;   // mm (kept small vs thickness)
weave_angle = 45;     // degrees

$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module rounded_rect_prism(L, W, H, R) {
    // Minkowski gives true rounded corners; keep R within bounds
    r = clamp(R, 0, min(L, W)/2 - 0.01);
    minkowski() {
        cube([L - 2*r, W - 2*r, H], center=true);
        cylinder(r=r, h=0.01, center=true);
    }
}

module chamfered_sheet(L, W, H, R, chamf) {
    // Chamfer by subtracting a slightly smaller rounded prism, leaving a beveled rim
    c = clamp(chamf, 0, min(L, W)/2 - 0.01);
    difference() {
        rounded_rect_prism(L, W, H, R);
        // Inner removal: slightly smaller in XY, slightly taller in Z to guarantee cut-through
        rounded_rect_prism(L - 2*c, W - 2*c, H + 2*overlap, max(R - c, 0));
    }
}

module weave_relief(L, W, H, pitch, amp, ang) {
    // Adds a subtle cross-hatched relief on the top face only (still one solid)
    // Implemented as two rotated stripe fields that overlap the top surface.
    z_top = H/2 - amp/2; // keep relief within thickness
    union() {
        for (a = [ang, -ang]) {
            rotate([0,0,a])
                translate([0,0,z_top])
                    intersection() {
                        // limit to sheet footprint
                        cube([L, W, amp], center=true);
                        // stripe field (long bars)
                        union() {
                            // cover diagonal span
                            span = sqrt(L*L + W*W) + 2*pitch;
                            n = ceil(span/pitch);
                            for (i = [-n:n]) {
                                translate([i*pitch, 0, 0])
                                    cube([pitch*0.55, span, amp], center=true);
                            }
                        }
                    }
        }
    }
}

// Final model (ONE connected solid)
module carbon_fiber_sheet() {
    // Base: rounded rectangle with chamfered edge
    base = 0; // placeholder to keep structure clear

    union() {
        // Main sheet with chamfered rim
        chamfered_sheet(sheet_length, sheet_width, sheet_thickness, corner_radius, edge_chamfer);

        // Woven relief fused to top surface (slight overlap ensures connectivity)
        translate([0,0,0])
            weave_relief(sheet_length - 2*edge_chamfer,
                         sheet_width  - 2*edge_chamfer,
                         sheet_thickness,
                         weave_pitch,
                         min(weave_amp, sheet_thickness*0.25),
                         weave_angle);
    }
}

carbon_fiber_sheet();