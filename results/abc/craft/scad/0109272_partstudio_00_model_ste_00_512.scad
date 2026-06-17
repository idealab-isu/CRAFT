// Dimension-calibrated (target: 0.07 x 0.01 x 0.06 mm)
scale([0.650000, 0.950000, 5.000000])
{
// Thin rectangular mounting plate with rounded corners, 4 corner through-holes,
// stepped side notch on one edge, and mirrored engraved text on both faces.

// ---------- Parameters (mm) ----------
L = 0.10;                 // overall length (elongated axis)
W = 0.06;                 // overall width
T = 0.001;                // thickness

corner_r = 0.006;         // corner radius
hole_d = 0.006;           // through-hole diameter
hole_edge_offset_L = 0.010;
hole_edge_offset_W = 0.010;

notch_edge = "W+";        // "W+", "W-", "L+", "L-"
notch_len = 0.030;
notch_depth1 = 0.012;
notch_depth2 = 0.006;
notch_step_len = 0.012;
notch_edge_margin = 0.010;

engrave_depth = 0.00035;
text_size = 0.010;
text_str = "Sleepy Pi 2";

$fn = 32;

// ---------- Helpers ----------
module rounded_rect_2d(l, w, r) {
    // Fast rounded rectangle: hull of 4 circles
    rr = min(r, min(l, w)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2-rr), sy*(w/2-rr)]) circle(r=rr);
    }
}

module plate_solid() {
    linear_extrude(height=T, center=true, convexity=5)
        rounded_rect_2d(L, W, corner_r);
}

module holes_4x() {
    h = T + 0.01; // generous to avoid coplanar issues
    for (sx = [-1, 1], sy = [-1, 1]) {
        translate([sx*(L/2 - hole_edge_offset_L), sy*(W/2 - hole_edge_offset_W), 0])
            cylinder(h=h, r=hole_d/2, center=true);
    }
}

module stepped_notch_cutout() {
    // Base notch defined for edge "W+" (top edge, +Y)
    u0 = -L/2 + notch_edge_margin;
    u1 = u0 + notch_len;
    us0 = u0;
    us1 = us0 + notch_step_len;

    primary_size = [notch_len, notch_depth1, T + 0.01];
    primary_ctr  = [ (u0+u1)/2,  W/2 - notch_depth1/2, 0 ];

    step_size    = [notch_step_len, notch_depth1 + notch_depth2, T + 0.01];
    step_ctr     = [ (us0+us1)/2,   W/2 - (notch_depth1 + notch_depth2)/2, 0 ];

    module notch_Wplus() {
        union() {
            translate(primary_ctr) cube(primary_size, center=true);
            translate(step_ctr)    cube(step_size, center=true);
        }
    }

    if (notch_edge == "W+") {
        notch_Wplus();
    } else if (notch_edge == "W-") {
        rotate([0,0,180]) notch_Wplus();
    } else if (notch_edge == "L+") {
        rotate([0,0,-90]) notch_Wplus();
    } else if (notch_edge == "L-") {
        rotate([0,0,90]) notch_Wplus();
    } else {
        notch_Wplus();
    }
}

module engraved_text_both_faces() {
    // Use direct text() in each extrude (avoid assigning 2D geometry to a variable)
    h = engrave_depth + 0.0002;

    // Top face engraving
    translate([0, 0,  T/2 - engrave_depth/2])
        linear_extrude(height=h, center=true, convexity=10)
            text(text_str, size=text_size, halign="center", valign="center");

    // Bottom face engraving (mirrored)
    translate([0, 0, -T/2 + engrave_depth/2])
        mirror([1,0,0])
            linear_extrude(height=h, center=true, convexity=10)
                text(text_str, size=text_size, halign="center", valign="center");
}

// ---------- Final Model ----------
difference() {
    plate_solid();
    holes_4x();
    stepped_notch_cutout();
    engraved_text_both_faces();
}
}
