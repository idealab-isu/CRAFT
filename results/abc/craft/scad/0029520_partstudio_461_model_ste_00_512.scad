// Dimension-calibrated (target: 0.01 x 0.04 x 0.01 mm)
scale([1.100000, 0.856947, 1.366901])
{
// Elongated faceted sleeve with tapered low-poly outer surface,
// stepped boss on one end (-Y), rounded/flush opposite end (+Y),
// and a continuous hexagonal through-bore along the main axis (Y).

// ---------------- Parameters (meters; keep as given) ----------------
L = 0.04; //[0.02:0.08:0.001]                 // overall length (along Y)
body_r_max = 0.005; //[0.0025:0.01:0.0001]    // larger end outer radius (near -Y)
body_r_min = 0.0046; //[0.0023:0.0092:0.0001] // smaller end outer radius (near +Y)

boss_L = 0.006; //[0.003:0.012:0.0005]        // boss length (on -Y end)
boss_r = 0.0036; //[0.0018:0.0072:0.0001]     // boss radius (reduced diameter)

hex_af = 0.0028; //[0.0014:0.0056:0.0001]     // across flats
hex_clearance = 0.0001; //[0.0:0.0005:0.00005]

facet_count = 10; //[6:24:1]                  // low-poly outer facets
round_end_L = 0.003; //[0.0015:0.006:0.0005]  // rounded cap length (on +Y end)

overlap = 0.0005; //[0.0002:0.0015:0.0001]    // boolean overlap

// Irregular flats (subtractive "dings" along the grip)
irregular_flat_depth = 0.00025; //[0.0:0.001:0.00005]
irregular_flat_L = 0.01; //[0.005:0.02:0.0005]
irregular_count = 4; //[0:8:1]

// ---------------- Helpers ----------------
function hex_R_from_AF(af) = af / sqrt(3); // circumradius for pointy-top hex

module hex_prism_y(af, h) {
    R = hex_R_from_AF(af);
    rotate([90,0,0])
        linear_extrude(height=h, center=true)
            polygon([ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module faceted_taper_y(r1, r2, h, fn) {
    rotate([90,0,0])
        cylinder(h=h, r1=r1, r2=r2, center=true, $fn=fn);
}

module faceted_cyl_y(r, h, fn) {
    rotate([90,0,0])
        cylinder(h=h, r=r, center=true, $fn=fn);
}

module rounded_cap_plusY(r_end, capL, fn) {
    // Rounded/flush end on +Y: short faceted section + hemisphere
    union() {
        translate([0, L/2 - capL/2, 0])
            faceted_cyl_y(r_end, capL + 2*overlap, fn);
        translate([0, L/2 - capL + overlap, 0])
            sphere(r=r_end, $fn=max(24, fn*2));
    }
}

module stepped_boss_minusY(r_boss, bossL, fn) {
    // Reduced diameter boss on -Y end, clearly stepped from main body
    translate([0, -L/2 - bossL/2 + overlap, 0])
        faceted_cyl_y(r_boss, bossL + 2*overlap, fn);
}

module irregular_flats_cuts() {
    // Shallow planar cuts to create irregular flats; ensure they actually intersect the shell.
    // Use Z-offset to hit the surface regardless of rotation about Y.
    for (i = [0:irregular_count-1]) {
        ang = i*360/max(1,irregular_count) + (i%2)*17;
        y0  = -L/2 + (i+1)*(L/(irregular_count+1));
        rotate([0, ang, 0])
            translate([0, y0, body_r_max - irregular_flat_depth/2])
                cube([2*body_r_max*2.2, irregular_flat_L, irregular_flat_depth], center=true);
    }
}

// ---------------- Model ----------------
module outer_shell() {
    // Main grip: faceted tapered sleeve body (larger at -Y, smaller at +Y)
    // Add a short transition collar so the boss reads as a step.
    collar_L = min(0.0025, boss_L*0.6);
    union() {
        // Main body
        faceted_taper_y(body_r_max, body_r_min, L, facet_count);

        // Transition collar at -Y end (slight reduction before boss)
        translate([0, -L/2 - collar_L/2 + overlap, 0])
            faceted_taper_y(body_r_max*0.98, boss_r*1.05, collar_L + 2*overlap, facet_count);

        // Boss on -Y end (stepped)
        stepped_boss_minusY(boss_r, boss_L, facet_count);

        // Rounded/flush end on +Y
        rounded_cap_plusY(body_r_min, round_end_L, facet_count);
    }
}

module outer_with_irregularity() {
    difference() {
        outer_shell();
        irregular_flats_cuts();
    }
}

module hex_through_bore() {
    // Continuous through-bore along Y, extended beyond ends for clean subtraction
    total_len = L + boss_L + 2*round_end_L + 6*overlap;
    hex_prism_y(hex_af + hex_clearance, total_len);
}

// Final: one connected solid with through-bore
difference() {
    outer_with_irregularity();
    hex_through_bore();
}
}
