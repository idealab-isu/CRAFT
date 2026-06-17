// Dimension-calibrated (target: 0.06 x 0.03 x 0.03 mm)
scale([0.000897, 0.000864, 0.001389])
{
// Rectangular tray-like housing with recessed panel + TRUE slot opening,
// tapered/chamfered side walls, and a slightly overhanging top flange.
// Structural fixes: ensure slot is a real cut-through into the cavity, keep all
// parts connected with small overlaps, and keep all cuts within the top surface.

$fn = 64;

// ---------- Parameters (mm) ----------
L = 60;                 // overall length (elongated axis)
W = 30;                 // overall width
H = 18;                 // overall height

wall_t = 2.2;           // side wall thickness
base_t = 2.4;           // bottom thickness

flange_overhang = 1.2;  // top flange overhang per side
flange_t = 1.6;         // flange thickness

taper_inset_bottom = 2.5; // bottom footprint inset vs top (per side)

recess_L = 44;          // recess size
recess_W = 18;
recess_depth = 2.2;     // depth of recess from top surface

slot_L = 36;            // slot size (long)
slot_W = 4.0;           // slot size (narrow)

eps = 0.05;
overlap = 1.0;          // intentional overlap for watertight unions/cuts

// ---------- Helpers ----------
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Keep features within walls
recess_L2 = clamp(recess_L, 0, L - 2*(wall_t + 1));
recess_W2 = clamp(recess_W, 0, W - 2*(wall_t + 1));
slot_L2   = clamp(slot_L,   0, recess_L2 - 2);
slot_W2   = clamp(slot_W,   0, recess_W2 - 2);

// ---------- Main geometry ----------
module outer_tapered_shell()
{
    // Outer solid with tapered walls; inner cavity open at top, leaving base thickness.
    difference() {
        // Outer: top footprint is [L,W], bottom is inset by taper_inset_bottom per side.
        linear_extrude(
            height = H,
            scale = [
                (L - 2*taper_inset_bottom)/L,
                (W - 2*taper_inset_bottom)/W
            ]
        )
            square([L, W], center=true);

        // Inner cavity: starts at base_t, leaves base thickness; also tapered.
        translate([0,0,base_t])
            linear_extrude(
                height = (H - base_t) + eps,
                scale = [
                    ((L - 2*wall_t) - 2*taper_inset_bottom) / (L - 2*wall_t),
                    ((W - 2*wall_t) - 2*taper_inset_bottom) / (W - 2*wall_t)
                ]
            )
                square([L - 2*wall_t, W - 2*wall_t], center=true);
    }
}

module top_flange()
{
    // Flange overlaps downward into the shell to guarantee a single connected solid.
    // Place it so its bottom is slightly below the shell top.
    translate([0,0, H - flange_t/2 - overlap/2])
        cube([L + 2*flange_overhang, W + 2*flange_overhang, flange_t + overlap], center=true);
}

module recess_cut()
{
    // Recess cut into the top surface (not through).
    // Ensure it starts at the very top and goes down recess_depth.
    translate([0,0, H - recess_depth/2 + eps/2])
        cube([recess_L2, recess_W2, recess_depth + eps], center=true);
}

module slot_cut()
{
    // TRUE slot opening: cut from the recessed floor down into the cavity.
    // Start at the recess floor (z = H - recess_depth) and cut down past the cavity top.
    // This guarantees a visible opening in orthographic views.
    slot_h = (H - base_t) + recess_depth + 2*overlap; // plenty to reach into cavity
    z_center = (H - recess_depth) - slot_h/2 + overlap; // ensures it begins at/above recess floor

    translate([0,0, z_center])
        cube([slot_L2, slot_W2, slot_h], center=true);
}

// ---------- Final ----------
difference() {
    union() {
        outer_tapered_shell();
        top_flange();
    }
    recess_cut();
    slot_cut();
}
}
