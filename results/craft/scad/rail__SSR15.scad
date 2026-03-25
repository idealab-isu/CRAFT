// Miniature linear guide rail (SSR15-like) — 15.0mm wide, 12.5mm tall, 100mm long
// Axes: X=width, Y=length, Z=height

$fn = 96;

// -------------------- Parameters --------------------
width_mm  = 15.0;
height_mm = 12.5;
length_mm = 100.0;

mounting_hole_diameter_mm = 3.2;   // through hole
countersink_diameter_mm   = 6.0;   // counterbore/countersink look
countersink_depth_mm      = 2.2;

mounting_hole_spacing_mm  = 25.0;
mounting_hole_count       = 4;

chamfer_mm                = 0.8;
overlap_mm                = 0.6;

// Profile detail (kept proportional; does not change overall W/H)
top_flat_w_mm      = 7.0;
bottom_flat_w_mm   = 11.0;
side_step_h_mm     = 2.0;

// Raceway grooves (side)
raceway_r_mm       = 1.25;
raceway_depth_mm   = 1.0;
raceway_z_mm       = 3.0;   // center height above bottom

// Top relief groove
top_groove_w_mm    = 4.0;
top_groove_d_mm    = 0.8;

// -------------------- Helpers --------------------
function clamp(v, lo, hi) = min(max(v, lo), hi);

ch = clamp(chamfer_mm, 0.2, min(width_mm, height_mm)/4);

top_flat_w    = clamp(top_flat_w_mm,    2.0, width_mm - 2*ch - 0.2);
bottom_flat_w = clamp(bottom_flat_w_mm, 3.0, width_mm - 2*ch - 0.2);
side_step_h   = clamp(side_step_h_mm,   0.8, height_mm/2.5);

raceway_r     = clamp(raceway_r_mm,     0.6, min(width_mm, height_mm)/5);
raceway_depth = clamp(raceway_depth_mm, 0.4, width_mm/4);
raceway_z     = clamp(raceway_z_mm, raceway_r + 0.4, height_mm - raceway_r - 0.6);

cs_d = clamp(countersink_diameter_mm, mounting_hole_diameter_mm + 1.0, width_mm - 2.0);
cs_h = clamp(countersink_depth_mm, 0.8, height_mm/3);

// -------------------- 2D rail cross-section (X-Z), extruded along Y --------------------
module rail_profile_2d() {
    w = width_mm;
    h = height_mm;

    z0 = -h/2;
    z1 = z0 + side_step_h;
    z2 =  h/2;

    xb = bottom_flat_w/2;
    xt = top_flat_w/2;

    // Clean, SSR-like stepped profile with chamfered top corners
    pts = [
        [-xb, z0],
        [ xb, z0],
        [ xb, z1],
        [ w/2 - ch, z1 + ch],
        [ w/2,      z1 + 2*ch],
        [ w/2,      z2 - 2*ch],
        [ w/2 - 2*ch, z2],
        [ xt, z2],
        [-xt, z2],
        [-w/2 + 2*ch, z2],
        [-w/2, z2 - 2*ch],
        [-w/2, z1 + 2*ch],
        [-w/2 + ch, z1 + ch],
        [-xb, z1]
    ];

    polygon(points=pts);
}

module rail_body() {
    linear_extrude(height=length_mm, center=true, convexity=12)
        rail_profile_2d();
}

// -------------------- Cutters --------------------
module mounting_hole_with_counterbore(y_pos) {
    // Through hole
    translate([0, y_pos, 0])
        cylinder(h=height_mm + 2*overlap_mm,
                 r=mounting_hole_diameter_mm/2,
                 center=true);

    // Counterbore from top face (Z+)
    translate([0, y_pos, height_mm/2 - cs_h/2 + overlap_mm*0.1])
        cylinder(h=cs_h + overlap_mm,
                 r=cs_d/2,
                 center=true);
}

module raceway_groove(side=1) {
    // side: +1 right, -1 left
    // Cylinder axis along Y, biting into side wall by raceway_depth
    x_center = side * (width_mm/2 - raceway_depth + raceway_r);
    z_center = -height_mm/2 + raceway_z;

    translate([x_center, 0, z_center])
        rotate([90, 0, 0])
            cylinder(h=length_mm + 2*overlap_mm, r=raceway_r, center=true);
}

module top_relief_groove() {
    groove_w = clamp(top_groove_w_mm, 2.0, top_flat_w - 0.6);
    groove_d = clamp(top_groove_d_mm, 0.4, height_mm/5);

    // Cut from the top surface downward
    translate([0, 0, height_mm/2 - groove_d/2 + overlap_mm*0.1])
        cube([groove_w, length_mm + 2*overlap_mm, groove_d + overlap_mm], center=true);
}

// -------------------- Rail --------------------
module rail() {
    difference() {
        rail_body();

        // Mounting holes along Y (centered pattern)
        y0 = -mounting_hole_spacing_mm*(mounting_hole_count-1)/2;
        for (i = [0:mounting_hole_count-1]) {
            mounting_hole_with_counterbore(y0 + i*mounting_hole_spacing_mm);
        }

        // Side raceways (both sides)
        raceway_groove( 1);
        raceway_groove(-1);

        // Top relief groove
        top_relief_groove();
    }
}

// Single connected solid
rail();