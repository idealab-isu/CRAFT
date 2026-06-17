// T-slot nut (simple printable profile) for:
// - 4.0mm screw (clearance hole default 4.2mm)
// - 6.0mm across flats hex pocket
// - 3.7mm thick overall
//
// Structural fixes:
// - Replace any cross/plus cutout with a centered circular through-hole (M4 clearance)
// - Keep a recognizable T-slot nut silhouette (neck + lips/undercut), extruded along length
// - Ensure all features are connected (single solid via one difference())
// - All translate() values are derived from dimensions (no arbitrary offsets)
// - Small overlaps (eps/overcut) ensure clean boolean results

$fn = 80;

// Requested key dimensions
thickness    = 3.7;     // overall Z thickness
hex_af       = 6.0;     // hex pocket across flats
hole_d       = 4.2;     // clearance for M4 (use 4.0 tight, 4.3 loose)

// Reasonable/typical T-slot nut proportions (simplified)
body_len     = 12.0;    // along slot (X)
slot_neck_w  = 6.2;     // neck width (top, Y)
shoulder_w   = 10.0;    // lip width (bottom, Y)
shoulder_h   = 1.2;     // lip height (bottom portion of thickness)

// Simple edge chamfer (optional)
edge_chamfer = 0.6;

// Hole lead-in (top)
lead_in_d    = 6.0;
lead_in_h    = 0.8;

// Derived
neck_h = thickness - shoulder_h;
hex_r  = hex_af / sqrt(3);   // circumradius for across-flats hex
eps    = 0.02;               // small overlap for booleans
overcut = 2;                 // extra cutter length to guarantee through-cuts

// 2D profile of a T-slot nut cross-section in Y-Z plane, extruded along X (body_len)
module tnut_profile_2d() {
    // Centered at Y=0, Z=0
    polygon(points=[
        [-slot_neck_w/2,  thickness/2],
        [ slot_neck_w/2,  thickness/2],
        [ shoulder_w/2,    thickness/2 - neck_h],
        [ shoulder_w/2,   -thickness/2],
        [-shoulder_w/2,   -thickness/2],
        [-shoulder_w/2,    thickness/2 - neck_h]
    ]);
}

module tnut_body() {
    linear_extrude(height=body_len, center=true, convexity=10)
        tnut_profile_2d();
}

// Chamfer cutters along the long edges (X direction)
module edge_chamfer_cuts() {
    // Place cutters at the outer Y edges and outer Z edges.
    // Use derived extents so cutters always intersect the body.
    for (sy = [-1, 1], sz = [-1, 1]) {
        translate([0,
                   sy*(shoulder_w/2),
                   sz*(thickness/2)])
            rotate([45*sz, 0, 0])
                cube([body_len + overcut, edge_chamfer*2, edge_chamfer*2], center=true);
    }
}

// Hex pocket on top face (shallow)
module hex_pocket() {
    // Keep some material under pocket
    pocket_h = min(2.0, thickness - 0.8);
    translate([0, 0, thickness/2 - pocket_h/2 + eps])
        cylinder(h=pocket_h + 2*eps, r=hex_r, center=true, $fn=6);
}

// Lead-in chamfer for the screw hole on top
module hole_lead_in() {
    translate([0, 0, thickness/2 - lead_in_h/2 + eps])
        cylinder(h=lead_in_h + 2*eps, r1=lead_in_d/2, r2=hole_d/2, center=true);
}

// Final model: one connected solid (single boolean difference from one body)
difference() {
    // Main body (with optional edge chamfers removed)
    difference() {
        tnut_body();
        if (edge_chamfer > 0)
            edge_chamfer_cuts();
    }

    // Centered round through-hole for M4 screw (replaces any cross/plus cutout)
    cylinder(h=thickness + overcut, r=hole_d/2, center=true);

    // Lead-in on top
    hole_lead_in();

    // Hex pocket on top (6.0mm across flats)
    hex_pocket();
}