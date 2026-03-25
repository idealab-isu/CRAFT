// Dimension-calibrated (target: 0.10 x 0.02 x 0.01 mm)
scale([1.050137, 1.100079, 0.416697])
{
// Thin elongated tag/plate with chamfered ends, circular boss at one end,
// diamond-shaped through-hole, raised "ASTRID" text, and a small geometric logo.
// Units: mm

$fn = 128;

// --- Parameters (kept tiny as provided) ---
L = 0.1;      // overall length
W = 0.02;     // overall width
T = 0.01;     // plate thickness

chamfer_L = 0.006;

// Boss (circular pad) at one end
boss_r = 0.010;                 // slightly larger for clear boss silhouette
boss_center_from_end = boss_r;  // center one radius in from end => boss tangent to end

// Diamond through-hole
hole_diamond_flat = 0.008;      // larger so it reads as a diamond in ortho views
hole_rotation_deg = 45;

eps = 0.001;

// Emboss details
emboss_h = 0.002;
text_size = 0.010;
text_font = "Liberation Sans:style=Bold";

logo_size = 0.006;
logo_h = emboss_h;

// --- Helpers ---
function clamp(x, a, b) = min(max(x, a), b);

// Boss center X (at left end)
boss_x = -L/2 + boss_center_from_end;

// Keep chamfer sane
chL = clamp(chamfer_L, 0, min(L/2 - eps, W/2 - eps));

// --- 2D profile for the plate with chamfered ends ---
module plate_profile_2d() {
    polygon(points=[
        [-L/2 + chL, -W/2],
        [ L/2 - chL, -W/2],
        [ L/2,       -W/2 + chL],
        [ L/2,        W/2 - chL],
        [ L/2 - chL,  W/2],
        [-L/2 + chL,  W/2],
        [-L/2,        W/2 - chL],
        [-L/2,       -W/2 + chL]
    ]);
}

module plate_body() {
    linear_extrude(height=T, center=true)
        plate_profile_2d();
}

module end_boss() {
    // Make boss clearly visible and guaranteed connected (overlap into plate)
    boss_h = T + 2*eps;
    translate([boss_x, 0, 0])
        cylinder(r=boss_r, h=boss_h, center=true);
}

module diamond_hole() {
    // Through-hole cut: taller than combined thickness
    translate([boss_x, 0, 0])
        rotate([0, 0, hole_rotation_deg])
            linear_extrude(height=T + 6*eps, center=true)
                polygon(points=[
                    [0,  hole_diamond_flat/2],
                    [ hole_diamond_flat/2, 0],
                    [0, -hole_diamond_flat/2],
                    [-hole_diamond_flat/2, 0]
                ]);
}

module embossed_text() {
    // Place text centered on the long body, away from boss.
    // Use halign="center" so it stays on the plate even at tiny scale.
    text_x = (boss_x + boss_r + (L/2 - chL)) / 2; // midpoint between boss edge and far chamfer start
    translate([text_x, 0, T/2 - eps])
        linear_extrude(height=emboss_h, center=false)
            text("ASTRID", size=text_size, font=text_font, halign="center", valign="center");
}

module logo_geom() {
    // Small geometric logo near the holed end, between boss and text.
    // Keep it outside the hole by offsetting from boss center by (hole radius + margin).
    hole_clear = hole_diamond_flat/2 + 0.0015;
    logo_x = boss_x + hole_clear + logo_size*0.9;

    translate([logo_x, 0, T/2 - eps])
        linear_extrude(height=logo_h, center=false)
            union() {
                // Solid diamond
                rotate(45) square([logo_size, logo_size], center=true);
                // Small notch/bar to suggest a simple mark
                translate([logo_size*0.75, 0])
                    square([logo_size*0.35, logo_size*0.18], center=true);
            }
}

// --- Final model (one connected solid) ---
difference() {
    union() {
        plate_body();
        end_boss();
        embossed_text();
        logo_geom();
    }
    diamond_hole();
}
}
