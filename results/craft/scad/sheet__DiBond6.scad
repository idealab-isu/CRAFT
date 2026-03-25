// Sheet DiBond (single connected solid with visible layered structure)

// Parameters
sheet_length = 1000; //[500:2000:1]
sheet_width = 500;   //[250:1000:1]
sheet_thickness = 3; //[1.5:6:0.1]          // total panel thickness (skins + core)
corner_radius = 10;  //[0:30:1]
edge_chamfer = 1;    //[0:3:0.1]
protective_film_thickness = 0.05; //[0.02:0.2:0.01] // per-side film thickness
overlap = 0.2; //[0.05:1:0.05]              // small overlap to guarantee watertight unions

// DiBond-like construction (typical: thin aluminum skins + thicker core)
al_skin_thickness = 0.3; //[0.1:0.6:0.05]   // per-side aluminum skin thickness

$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

L = sheet_length;
W = sheet_width;

// Clamp radii/chamfer to safe values
R = clamp(corner_radius, 0, min(L, W)/2);
C = clamp(edge_chamfer, 0, min(L, W)/2);

// Thickness bookkeeping
F = max(0, protective_film_thickness);      // per-side film
S = max(0, al_skin_thickness);              // per-side skin
Ttot = max(0.1, sheet_thickness);           // total thickness must be > 0 for visibility

// Ensure layers fit inside total thickness
max_layer_sum = 2*(F + S);
core_thickness = max(0.05, Ttot - max_layer_sum);

// Recompute effective total (keeps requested Ttot if possible; otherwise uses minimum feasible)
T_eff = core_thickness + 2*(F + S);

// 2D rounded rectangle
module rounded_rect_2d(l, w, r) {
    if (r <= 0)
        square([l, w], center=true);
    else
        offset(r=r) offset(delta=-r) square([l, w], center=true);
}

// A single slab with optional top-edge chamfer (chamfer only affects the top face)
module slab_with_top_chamfer(th, chamfer) {
    th2 = max(0.05, th);
    ch = clamp(chamfer, 0, th2/2);

    if (ch <= 0) {
        linear_extrude(height=th2, center=true)
            rounded_rect_2d(L, W, R);
    } else {
        difference() {
            linear_extrude(height=th2, center=true)
                rounded_rect_2d(L, W, R);

            // Remove a tapered ring near the top to create a chamfer
            // Use scale based on inset = ch; keep formulas (no arbitrary offsets)
            translate([0, 0, th2/2 - ch/2])
                linear_extrude(
                    height = ch + 2*overlap,
                    center = true,
                    scale  = [(L - 2*ch)/L, (W - 2*ch)/W]
                )
                difference() {
                    rounded_rect_2d(L + 2*overlap, W + 2*overlap, R);
                    rounded_rect_2d(L - 2*ch, W - 2*ch, max(R - ch, 0));
                }
        }
    }
}

// Final: ONE connected solid (union of layers with slight overlaps)
module dibond_sheet() {
    union() {
        // Core (composite)
        translate([0, 0, 0])
            slab_with_top_chamfer(core_thickness + 2*overlap, 0);

        // Bottom aluminum skin
        translate([0, 0, -(core_thickness/2 + S/2) + overlap])
            slab_with_top_chamfer(S + 2*overlap, 0);

        // Top aluminum skin (gets the chamfer)
        translate([0, 0, +(core_thickness/2 + S/2) - overlap])
            slab_with_top_chamfer(S + 2*overlap, C);

        // Bottom protective film
        translate([0, 0, -(core_thickness/2 + S + F/2) + overlap])
            slab_with_top_chamfer(F + 2*overlap, 0);

        // Top protective film (follows chamfer)
        translate([0, 0, +(core_thickness/2 + S + F/2) - overlap])
            slab_with_top_chamfer(F + 2*overlap, C);
    }
}

dibond_sheet();