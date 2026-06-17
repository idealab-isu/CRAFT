// Dimension-calibrated (target: 12.00 x 22.98 x 24.00 mm)
scale([0.999087, 1.043261, 0.500000])
{
// Rotationally symmetric spool-like turned sleeve/roller
// FIX: Replace frustum/cone-looking artifacts with a clean stepped cylindrical profile
// using a single continuous r-z polygon (rotate_extrude).
// Target bounding box: 23 x 23 x 24 mm (X x Y x Z), elongated along Z

$fn = 200;

// --- Parameters (mm) ---
L = 24;                 // overall length (Z)
D_max = 23;             // max OD (raised bands)
D_min = 12;             // min OD (grooves)
end_land_L = 4;         // raised end land length (each end)
groove_L = 3;           // recessed groove length (each groove)
band_L = 5;             // raised band length (between grooves)
fillet_r = 0.8;         // fillet radius at steps (r-z profile)
end_edge_r = 0.4;       // end edge rounding (r-z profile)

// --- Derived radii ---
R_max = D_max/2;
R_min = D_min/2;

// --- Axial layout (exactly fills L) ---
center_band_L = L - (2*end_land_L + 2*groove_L + band_L);
center_band_L = (center_band_L < 0) ? 0 : center_band_L;

z0 = -L/2;
z1 = z0 + end_land_L;
z2 = z1 + groove_L;
z3 = z2 + band_L;
z4 = z3 + groove_L;
z5 = z4 + center_band_L;
z6 = z0 + L;

// --- Helpers ---
function min3(a,b,c) = min(a, min(b,c));

// Rounded outer edge at left end: from (R-fe, z0) to (R, z0+fe)
function end_round_left(R, z0, fe, nsteps) =
    (fe <= 0) ? [] :
    [ for (i=[0:nsteps])
        let(t = i*90/nsteps)
        [ (R - fe) + fe*cos(t), z0 + fe*sin(t) ]
    ];

// Rounded outer edge at right end: from (R, z6-fe) to (R-fe, z6)
function end_round_right(R, z6, fe, nsteps) =
    (fe <= 0) ? [] :
    [ for (i=[0:nsteps])
        let(t = i*90/nsteps)
        [ R - fe*sin(t), (z6 - fe) + fe*cos(t) ]
    ];

module spool_profile() {
    // Clamp fillets so they fit within adjacent axial segments
    f1 = min3(fillet_r, end_land_L/2, groove_L/2);
    f2 = min3(fillet_r, groove_L/2, band_L/2);
    f3 = min3(fillet_r, band_L/2, groove_L/2);
    f4 = min3(fillet_r, groove_L/2, center_band_L/2);
    fe = min(end_edge_r, end_land_L/2);

    n  = 24;
    ne = max(10, floor(n/2));

    // Build ONE continuous, monotonic-in-z outer contour with explicit cylindrical steps.
    // Each shoulder uses a quarter-circle fillet that advances in z (no backwards arcs),
    // preventing self-intersections and "split/frustum" artifacts.

    pts = concat(
        // Start on axis at left end
        [[0, z0]],

        // Move to outer surface with end rounding
        [[R_max - fe, z0]],
        end_round_left(R_max, z0, fe, ne),

        // --- Segment A: left end land (R_max) ---
        [[R_max, z1 - f1]],

        // Fillet down: R_max -> R_min across z1..z1+f1
        [ for (i=[0:n])
            let(t = i*90/n)
            [ R_max - (R_max - R_min)*sin(t), (z1 - f1) + f1*(1 - cos(t)) ]
        ],

        // --- Segment B: groove 1 (R_min) ---
        [[R_min, z2 - f2]],

        // Fillet up: R_min -> R_max across z2..z2+f2
        [ for (i=[0:n])
            let(t = i*90/n)
            [ R_min + (R_max - R_min)*sin(t), (z2 - f2) + f2*(1 - cos(t)) ]
        ],

        // --- Segment C: raised band (R_max) ---
        [[R_max, z3 - f3]],

        // Fillet down: R_max -> R_min across z3..z3+f3
        [ for (i=[0:n])
            let(t = i*90/n)
            [ R_max - (R_max - R_min)*sin(t), (z3 - f3) + f3*(1 - cos(t)) ]
        ],

        // --- Segment D: groove 2 (R_min) ---
        [[R_min, z4 - f4]],

        // Fillet up: R_min -> R_max across z4..z4+f4
        [ for (i=[0:n])
            let(t = i*90/n)
            [ R_min + (R_max - R_min)*sin(t), (z4 - f4) + f4*(1 - cos(t)) ]
        ],

        // --- Segment E: final raised section (R_max) to right end rounding ---
        [[R_max, z6 - fe]],
        end_round_right(R_max, z6, fe, ne),
        [[R_max - fe, z6]],

        // Close back to axis at right end
        [[0, z6]]
    );

    rotate_extrude(convexity=12)
        polygon(points=pts);
}

// --- Final model: ONE connected solid (single body) ---
union() {
    spool_profile();
}
}
