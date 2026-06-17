// Dimension-calibrated (target: 10.00 x 23.00 x 6.35 mm)
scale([0.833333, 0.635000, 2.300000])
{
$fn = 96;

// Target bounding box: 23.0 x 10.0 x 6.3 mm (X x Y x Z), elongated along X
bbox_L = 23;
bbox_W = 10;
bbox_H = 6.3;

// Main dimensions (kept within bbox)
head_d   = 10;   // max Y/Z
head_t   = 2;

shank_d  = 6;
shank_L  = 14;

tip_L      = 7;
tip_end_d  = 4;

// Split-tip slot
slot_w = 1.2;   // slot width (Y)
slot_L = 6;     // slot length along X (within tip)

// Wedge opening near the end (widens toward the tip end)
wedge_open_w = 3.2;  // slot widens toward the very end (Y)
wedge_L      = 4.5;  // length of widening region from tip end back along X

// Overlap to guarantee connectivity / clean booleans (1-2mm as requested)
overlap = 1.2;

// Derived: keep total length exactly bbox_L
transition_L = bbox_L - (head_t + shank_L + tip_L);
transition_L = (transition_L < 0) ? 0 : transition_L;

// Axis: part runs along +X, centered at origin
x0 = -bbox_L/2;

// Segment extents (explicit faces so everything touches/overlaps deterministically)
x_head_L = x0;
x_head_R = x_head_L + head_t;

x_trans_L = x_head_R;
x_trans_R = x_trans_L + transition_L;

x_shank_L = x_trans_R;
x_shank_R = x_shank_L + shank_L;

x_tip_Lf  = x_shank_R;
x_tip_Rf  = x_tip_Lf + tip_L;   // should equal +bbox_L/2

// Helpers: cylinders oriented along X
module cylX_len(len, r1, r2) {
    rotate([0,90,0]) cylinder(h=len, r1=r1, r2=r2, center=true);
}

module cylX_between(xL, xR, r1, r2) {
    translate([(xL + xR)/2, 0, 0])
        cylX_len((xR - xL), r1, r2);
}

module fastener_body() {
    union() {
        // Head (disk)
        cylX_between(x_head_L, x_head_R + overlap, head_d/2, head_d/2);

        // Transition (head -> shank) if needed
        if (transition_L > 0)
            cylX_between(x_trans_L - overlap, x_trans_R + overlap, head_d/2, shank_d/2);

        // Shank (long cylindrical body)
        cylX_between(x_shank_L - overlap, x_shank_R + overlap, shank_d/2, shank_d/2);

        // Tip (tapered continuation of shank)
        cylX_between(x_tip_Lf - overlap, x_tip_Rf, shank_d/2, tip_end_d/2);
    }
}

module tip_slot_cut() {
    // Slot must be cut into the *end of the shank/tip* to create two prongs (single connected part)
    x_tip_start = x_tip_Lf;
    x_tip_end   = x_tip_Rf;

    // Clamp lengths to tip length
    x_slot_L  = min(slot_L, tip_L);
    x_wedge_L = min(wedge_L, tip_L);

    // Place constant-width slot so it starts at the tip start and runs toward the end
    // (ensures the split is actually at the end region and connected to the shank)
    x_slot_center = x_tip_start + x_slot_L/2;

    // Wedge widening near the very end
    x_wedge_start_c = x_tip_end - x_wedge_L/2;
    x_wedge_end_c   = x_tip_end - overlap/2;

    // Tip-only mask (hard limit so we don't cut into the shank/head)
    module tip_mask() {
        translate([(x_tip_start + x_tip_end)/2, 0, 0])
            cube([tip_L + 2*overlap, bbox_W + 2*overlap, bbox_H + 4*overlap], center=true);
    }

    intersection() {
        union() {
            // Constant-width slot (full height so it splits into two prongs)
            translate([x_slot_center, 0, 0])
                cube([x_slot_L + overlap, slot_w, bbox_H + 4*overlap], center=true);

            // Widening wedge near the end to suggest tapered wedge-shaped legs
            hull() {
                translate([x_tip_end - x_wedge_L + overlap/2, 0, 0])
                    cube([overlap, slot_w, bbox_H + 4*overlap], center=true);

                translate([x_wedge_end_c, 0, 0])
                    cube([overlap, wedge_open_w, bbox_H + 4*overlap], center=true);
            }
        }
        tip_mask();
    }
}

difference() {
    // Single continuous fastener: head + long shank + tapered tip
    fastener_body();

    // Longitudinal slot cut into the tip to form two prongs (not separate bodies)
    tip_slot_cut();
}
}
