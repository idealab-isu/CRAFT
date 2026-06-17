$fn = 128;

// Aluminium foil tape (sheet with adhesive layer + slight edge curl + crinkle texture)
// ONE connected solid, all translates derived from dimensions.

length      = 120;
width       = 60;

foil_t      = 0.18;   // foil thickness
adh_t       = 0.22;   // adhesive thickness (gives visible body)
total_t     = foil_t + adh_t;

corner_r    = 2.0;

curl_len    = 10;     // curled edge length along X
curl_r      = 1.2;    // curl radius
curl_lip_t  = 0.35;   // thickness of curled lip (visual)
curl_inset  = 0.6;    // inset from side edges so curl doesn't exceed width

eps = 0.02;

// ---------- helpers ----------
module rounded_rect_2d(l, w, r){
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)])
                circle(r=r);
    }
}

module rounded_sheet(l, w, t, r){
    linear_extrude(height=t, center=false, convexity=10)
        rounded_rect_2d(l, w, r);
}

// deterministic pseudo-random in [0,1)
function hash01(x,y) = let(v = abs(sin(x*12.9898 + y*78.233) * 43758.5453)) (v - floor(v));

module crinkle_bumps(l, w, base_z, bump_max){
    step = 6;
    for (x = [-l/2 + step/2 : step : l/2 - step/2])
        for (y = [-w/2 + step/2 : step : w/2 - step/2]) {
            v = hash01(x,y);
            h = v * bump_max;
            if (h > bump_max*0.25)
                translate([x, y, base_z - eps])  // overlap into base so it's connected
                    cylinder(h=h + eps, r=0.9, center=false);
        }
}

// curled leading edge (a thin rolled lip) that is CONNECTED to the sheet
module edge_curl(l, w, base_t, curl_len, curl_r, lip_t, inset){
    // Place curl at +X edge, centered in Y, sitting on top of foil surface.
    // Use rotate_extrude to make a quarter-roll profile, then intersect to width.
    x_edge = l/2;
    y_w    = w - 2*inset;

    // Profile: small rectangle at radius curl_r, swept 90 degrees around Z.
    // Then positioned so its start overlaps the sheet top near the edge.
    translate([x_edge - curl_len + 0.5*curl_len, 0, base_t - eps])  // overlap into foil
    intersection() {
        // limit to tape width
        translate([0, 0, 0])
            cube([curl_len + 2*curl_r, y_w, 2*curl_r + lip_t], center=true);

        // build curl by sweeping a thin strip around Z, then rotate to align along X
        translate([-(curl_len/2), 0, 0])
        rotate([0, 90, 0])  // make the swept shape extend along X
        linear_extrude(height=y_w, center=true, convexity=10)
            // 2D cross-section in XZ plane: quarter ring segment approximated by hull of two circles
            // (kept simple and robust)
            hull() {
                translate([0, curl_r]) circle(r=lip_t/2);
                translate([curl_len, curl_r]) circle(r=lip_t/2);
            }
    }
}

// subtle edge bead to suggest thickness and cut edge
module edge_bead(l, w, z0, bead_r){
    // Bead runs around perimeter on top surface, overlaps into foil.
    translate([0,0,z0 - eps])
    linear_extrude(height=bead_r*1.2 + eps, center=false, convexity=10)
        difference() {
            offset(r=bead_r) rounded_rect_2d(l, w, corner_r);
            rounded_rect_2d(l, w, corner_r);
        }
}

// ---------- main ----------
module foil_tape_sheet(l, w, foil_t, adh_t, r){
    bump_max = max(0.05, foil_t*0.6);

    union() {
        // Adhesive layer (bottom)
        color([0.92, 0.86, 0.55])
            rounded_sheet(l, w, adh_t, r);

        // Foil layer (top), sits on adhesive
        translate([0, 0, adh_t])
        color([0.78, 0.80, 0.83])
        union() {
            rounded_sheet(l, w, foil_t, r);

            // Crinkle bumps on top of foil
            crinkle_bumps(l, w, foil_t, bump_max);

            // Slight perimeter bead on top for edge definition
            edge_bead(l, w, foil_t, bead_r=0.35);

            // Curled leading edge (connected)
            edge_curl(l, w, foil_t, curl_len, curl_r, curl_lip_t, curl_inset);
        }
    }
}

foil_tape_sheet(length, width, foil_t, adh_t, corner_r);