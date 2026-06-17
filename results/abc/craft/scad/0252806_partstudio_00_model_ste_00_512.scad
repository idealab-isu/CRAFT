// Dimension-calibrated (target: 0.10 x 0.02 x 0.01 mm)
scale([1.071429, 1.216814, 0.694444])
{
// Thin nameplate/keychain tag with chamfered ends, a DISTINCT circular boss at one end,
// a DIAMOND-shaped through-hole inside that boss, raised "ASTRID" text, and a small
// geometric logo near the holed end. One connected solid (minus the through-hole).

// ---------- Parameters (mm) ----------
bbox_L = 0.1;    // overall length target (approx)
bbox_W = 0.02;   // overall width target (approx)
bbox_H = 0.01;   // overall thickness target (approx)

plate_L = 0.082;
plate_W = 0.018;
plate_T = 0.006;

chamfer_L = 0.006;

boss_D = 0.018;          // circular boss diameter
boss_T = 0.006;          // boss thickness (same as plate for flat tag)
boss_overlap_xy = 0.002; // how much boss overlaps into plate in X (ensures connection)

hole_diamond_flat_to_flat = 0.008;
hole_clearance = 0.0002;

text_H = 0.0012;
text_size = 0.010;
text_margin_side = 0.002;
text_margin_end  = 0.020;

logo_size = 0.004;
logo_H = 0.001;

eps = 0.0005;

// ---------- Quality ----------
$fn = 128;

// ---------- Helpers ----------
function clamp(x, a, b) = min(max(x, a), b);

// Chamfer wedge used to cut the plate ends (in XY, extruded in Z)
module chamfer_wedge(w, chamfer_len, h) {
    linear_extrude(height=h, center=true)
        polygon(points=[
            [0,  w/2 + eps],
            [0, -w/2 - eps],
            [chamfer_len + eps, 0]
        ]);
}

// Diamond hole (flat-to-flat = dff)
module diamond_hole(dff, h) {
    d = dff/2;
    linear_extrude(height=h, center=true)
        polygon(points=[[0,d],[d,0],[0,-d],[-d,0]]);
}

// Small geometric logo: outlined diamond + 2 bars (embossed)
module small_logo(size, h) {
    // Outline diamond (ring)
    difference() {
        linear_extrude(height=h, center=false)
            polygon(points=[[0,size],[size,0],[0,-size],[-size,0]]);
        translate([0,0,-eps])
            linear_extrude(height=h+2*eps, center=false)
                polygon(points=[[0,size*0.62],[size*0.62,0],[0,-size*0.62],[-size*0.62,0]]);
    }
    // Two small bars above the diamond
    for (yy = [size*0.95, size*1.35]) {
        translate([0, yy, h/2])
            cube([size*1.6, size*0.22, h], center=true);
    }
}

// ---------- Main solids ----------
module plate_body() {
    // Base plate with chamfered ends
    difference() {
        cube([plate_L, plate_W, plate_T], center=true);

        // Right end chamfer
        translate([ plate_L/2 - chamfer_L, 0, 0])
            chamfer_wedge(plate_W, chamfer_L, plate_T + 4*eps);

        // Left end chamfer
        translate([-plate_L/2 + chamfer_L, 0, 0])
            rotate([0,0,180])
                chamfer_wedge(plate_W, chamfer_L, plate_T + 4*eps);
    }
}

module boss_solid() {
    // Boss center placed so the boss is clearly round and protrudes beyond the plate end,
    // while still overlapping the plate by boss_overlap_xy to guarantee connectivity.
    boss_cx = plate_L/2 + boss_D/2 - boss_overlap_xy;
    translate([boss_cx, 0, 0])
        cylinder(h=boss_T, r=boss_D/2, center=true);
}

module embossed_text() {
    usable_L = plate_L - 2*text_margin_end;
    usable_W = plate_W - 2*text_margin_side;

    // Rough width estimate for "ASTRID"
    est_text_w = text_size * 6 * 0.62;
    scale_x = clamp(usable_L / max(est_text_w, 1e-9), 0.6, 1.2);
    scale_y = clamp(usable_W / max(text_size, 1e-9), 0.7, 1.1);

    // Shift text away from boss end so it stays on the rectangular plate area
    tx = -plate_L*0.06;

    translate([tx, 0, plate_T/2 - eps])
        linear_extrude(height=text_H + eps, center=false)
            scale([scale_x, scale_y, 1])
                text("ASTRID",
                     size=text_size,
                     halign="center",
                     valign="center",
                     font="Liberation Sans:style=Bold");
}

module embossed_logo() {
    boss_cx = plate_L/2 + boss_D/2 - boss_overlap_xy;

    // Place logo on plate near boss, but not on the hole center
    lx = boss_cx - boss_D*0.70;
    ly = plate_W*0.18;

    translate([lx, ly, plate_T/2 - eps])
        small_logo(logo_size, logo_H + eps);
}

module tag_solid() {
    union() {
        plate_body();
        boss_solid();
        embossed_text();
        embossed_logo();
    }
}

module final_model() {
    boss_cx = plate_L/2 + boss_D/2 - boss_overlap_xy;

    difference() {
        tag_solid();

        // Diamond through-hole centered in the circular boss
        translate([boss_cx, 0, 0])
            rotate([0,0,45])
                diamond_hole(hole_diamond_flat_to_flat + hole_clearance,
                             max(plate_T, boss_T) + 6*eps);
    }
}

// ---------- Render ----------
final_model();
}
