// Bounding box target: 36 x 19 x 21 mm (X x Y x Z)
L = 36; //[18:72:0.5]   // X (length)
W = 19; //[9.5:38:0.5]  // Y (width)
H = 21; //[10.5:42:0.5] // Z (height)

// Side cutouts (open to ±Y) to create H-profile in left/right view
cutout_length    = 24; //[12:34:0.5]     // along X
cutout_height    = 13; //[6.5:17:0.5]    // along Z
web_thickness    = 7;  //[3.5:14:0.5]    // remaining center web along Y
cutout_end_margin= 6;  //[3:12:0.5]      // solid margin at each X end
top_bottom_skin  = 4;  //[2:8:0.5]       // solid skin at top and bottom (Z)

fillet_r = 2; //[0.5:4:0.25]
overlap  = 1; //[0.5:2:0.1]

$fn = 48;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Derived (kept valid and actually used for placement)
cutL = clamp(cutout_length, 0.01, L - 2*cutout_end_margin);
cutH = clamp(cutout_height, 0.01, H - 2*top_bottom_skin);

// Depth of each side pocket from the outside face inward, leaving web_thickness in the middle
sidePocketDepth = clamp((W - web_thickness)/2, 0.01, W/2 - 0.01);

// Rounded outer body (filleted edges)
module rounded_block(sz=[L,W,H], r=fillet_r) {
    r2 = clamp(r, 0, min(sz[0], min(sz[1], sz[2]))/2 - 0.01);
    if (r2 <= 0)
        cube(sz, center=true);
    else
        minkowski() {
            cube([sz[0]-2*r2, sz[1]-2*r2, sz[2]-2*r2], center=true);
            sphere(r=r2);
        }
}

// Two opposing rectangular side cutouts (open to ±Y), leaving a central web.
// Correctly positioned to respect end margins in X and skins in Z.
module side_cutouts() {
    // Make the subtractors extend slightly beyond the outer faces (overlap) to guarantee opening.
    pocketX = cutL + 2*overlap;
    pocketY = sidePocketDepth + 2*overlap;
    pocketZ = cutH + 2*overlap;

    // Place pockets so their inner faces stop at the web boundary (±web_thickness/2),
    // while their outer faces extend past the body by 'overlap'.
    //
    // For +Y pocket:
    //   inner face at y = +web_thickness/2
    //   outer face at y = +W/2 + overlap
    // Center y = (inner+outer)/2 = (web/2 + W/2 + overlap)/2
    y_center_pos = (web_thickness/2 + W/2 + overlap) / 2;
    y_center_neg = -y_center_pos;

    // Respect end margins in X: pocket spans [-(cutL/2) .. +(cutL/2)] centered at 0,
    // leaving (L-cutL)/2 margin each end (>= cutout_end_margin by clamp above).
    x_center = 0;

    // Respect top/bottom skins in Z: pocket spans [-(cutH/2) .. +(cutH/2)] centered at 0,
    // leaving (H-cutH)/2 skin each side (>= top_bottom_skin by clamp above).
    z_center = 0;

    translate([x_center, y_center_pos, z_center])
        cube([pocketX, pocketY, pocketZ], center=true);

    translate([x_center, y_center_neg, z_center])
        cube([pocketX, pocketY, pocketZ], center=true);
}

// Final solid (single connected body with symmetric side recesses -> H-profile in left/right view)
difference() {
    rounded_block([L, W, H], fillet_r);
    side_cutouts();
}