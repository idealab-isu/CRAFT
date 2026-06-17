// A extrusion bracket: [26, 25, 4.7]
// Simple, recognizable L/angle extrusion bracket within overall bounds [L, W, T].
// Adds clear bracket silhouette + simple extrusion-interface (T-slot nut capture) on base leg.
// All parts are one connected solid; all translate() values are computed; slight overlaps used.

bracket_L = 26;   //[13:52:0.1]
bracket_W = 25;   //[12.5:50:0.1]
bracket_T = 4.7;  //[2.35:9.4:0.1]

$fn = 64;

eps = 0.02;
overlap = 1.2; // 1–2mm overlap for robust connections

L = bracket_L;
W = bracket_W;
T = bracket_T;

// Bracket proportions (kept blocky/simple)
upright_len = 14;                 // how far the upright leg extends along X (<= L)
upright_len = min(upright_len, L);
upright_thk = T;                  // upright thickness along Y
base_thk    = T;                  // base thickness along Z

// Hole sizing (typical M5 clearance)
hole_d = 5.2;
hole_r = hole_d/2;

// Safe margins for holes/slots
margin = 6;

// Base hole position (through Z)
hx_base = max(margin, min(L - margin, L*0.65));
hy_base = max(margin, min(W - margin, W*0.50));

// Upright hole position (through Y)
hx_up = max(margin, min(upright_len - margin, upright_len*0.50));
hz_up = base_thk/2; // centered in thickness

// Simple extrusion interface: T-slot nut capture pocket on underside of base
// (a shallow rectangular pocket + a narrow entry slot)
pocket_w = 10;                 // across Y
pocket_l = 12;                 // along X
pocket_d = min(2.2, base_thk - 1.0); // depth into underside (keep some roof)

entry_w  = 6;                  // narrow slot width across Y
entry_l  = pocket_l;           // same length
entry_d  = pocket_d + 0.2;     // slightly deeper to ensure opening

// Place pocket near the inside corner (where extrusion would sit)
pocket_xc = max(pocket_l/2 + 2, min(L - pocket_l/2 - 2, T + pocket_l/2 + 1));
pocket_yc = W/2;

module extrusion_bracket() {
    difference() {
        union() {
            // Base plate: spans full L x W, thickness T in Z
            translate([L/2, W/2, base_thk/2])
                cube([L, W, base_thk], center=true);

            // Upright leg: rises from base along Z, located at Y=0 edge (angle bracket look)
            // Size: X=upright_len, Y=upright_thk, Z=T
            // Positioned so its bottom sits on top of base with overlap.
            translate([upright_len/2, upright_thk/2, base_thk + T/2 - overlap/2])
                cube([upright_len, upright_thk, T + overlap], center=true);

            // Small inside gusset/fillet block to reinforce the corner (still within bounds)
            gus_x = min(8, upright_len);
            gus_y = min(8, W);
            gus_z = T;
            translate([gus_x/2, gus_y/2, base_thk + gus_z/2 - overlap/2])
                cube([gus_x, gus_y, gus_z + overlap], center=true);
        }

        // Base mounting hole (through Z)
        translate([hx_base, hy_base, base_thk/2])
            cylinder(h = base_thk + 2*eps, r = hole_r, center=true);

        // Upright mounting hole (through Y) on the upright leg
        // Centered in the upright thickness (Y) and in Z of the upright leg.
        translate([hx_up, upright_thk/2, base_thk + T/2])
            rotate([90, 0, 0])
                cylinder(h = upright_thk + 2*eps, r = hole_r, center=true);

        // Extrusion interface: nut capture pocket on underside of base (opens downward)
        // Pocket (wider) + entry slot (narrow) to suggest T-slot engagement.
        translate([pocket_xc, pocket_yc, pocket_d/2 - eps])
            cube([pocket_l, pocket_w, pocket_d + 2*eps], center=true);

        translate([pocket_xc, pocket_yc, entry_d/2 - eps])
            cube([entry_l, entry_w, entry_d + 2*eps], center=true);

        // Small inside-corner relief (clearance) at the bracket corner
        relief_r = 2.0;
        // Cut a quarter-cylinder at the inside corner (near X=0,Y=0) through the base thickness
        translate([T, T, base_thk/2])
            cylinder(h = base_thk + 2*eps, r = relief_r, center=true);
    }
}

union() {
    extrusion_bracket();
}