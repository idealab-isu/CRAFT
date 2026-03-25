// Bi-metal saw blade (single connected solid) - STRUCTURAL FIX
// Adds a clear toothed edge + a bi-metal band, with guaranteed overlap/connectivity.

// ---------- Parameters ----------
blade_L = 300; //[150:600:1]
blade_W = 12.5; //[6:25:0.1]
blade_T = 0.65; //[0.3:1.3:0.01]

tooth_pitch = 1.0; //[0.5:2.0:0.05]
tooth_h = 1.2; //[0.6:2.4:0.05]
tooth_base = 0.8; //[0.4:1.6:0.05]
tooth_edge_offset = 0.0; //[-1:1:0.05]

hole_d = 6.5; //[3:10:0.1]
hole_center_from_end = 25; //[10:60:0.5]

end_round_r = 6.25; //[3:12.5:0.05]

chamfer_xy = 0.4; //[0.1:1.0:0.05]
chamfer_z = 0.15; //[0.05:0.4:0.01]

// Teeth thickness should be at least blade thickness so they read in top view
tooth_band_T = 0.90; //[0.3:1.5:0.01]
tooth_band_overlap = 1.2; //[0.5:2.0:0.05]
tooth_set_amp = 0.15; //[0.0:0.4:0.01]

tooth_count = 280; //[50:600:1]
tooth_end_margin = 20; //[5:60:1]

// Visual bi-metal band (slightly thicker strip along tooth edge)
bimetal_band_W_frac = 0.35; // fraction of blade width near tooth edge
bimetal_band_extraT = 0.12; // extra thickness above blade_T

// Connectivity overlap (mm)
join_ol = 1.0; //[0.5:2.0:0.1]

$fn = 64;

// ---------- Helpers ----------
function teeth_fit_count() =
    max(1, floor((blade_L - 2*tooth_end_margin) / tooth_pitch));

teeth_N = min(tooth_count, teeth_fit_count());

// ---------- Base blade with rounded ends (2D then extrude) ----------
module blade_2d_profile() {
    // Rounded rectangle via hull of two circles; ensure full width is blade_W after scaling
    hull() {
        translate([-blade_L/2 + end_round_r, 0]) circle(r=end_round_r);
        translate([ blade_L/2 - end_round_r, 0]) circle(r=end_round_r);
    }
}

module blade_solid() {
    // Scale Y so the hull becomes the desired blade width
    linear_extrude(height=blade_T, center=true)
        scale([1, blade_W/(2*end_round_r)])
            blade_2d_profile();
}

module mounting_holes() {
    hole_h = blade_T + 2*(chamfer_z + 0.6);
    translate([-blade_L/2 + hole_center_from_end, 0, 0])
        cylinder(r=hole_d/2, h=hole_h, center=true, $fn=48);
    translate([ blade_L/2 - hole_center_from_end, 0, 0])
        cylinder(r=hole_d/2, h=hole_h, center=true, $fn=48);
}

module blade_with_holes() {
    difference() {
        blade_solid();
        mounting_holes();
    }
}

// ---------- Edge softening (light chamfer/round) ----------
module edge_soften_kernel() {
    // Keep small to avoid excessive Minkowski growth
    cube([2*chamfer_xy, 2*chamfer_xy, 2*chamfer_z], center=true);
}

module blade_softened() {
    minkowski() {
        blade_with_holes();
        edge_soften_kernel();
    }
}

// ---------- Teeth (triangular profile, extruded through thickness) ----------
module tooth_prism() {
    // Triangle in XY, extruded in Z
    linear_extrude(height=tooth_band_T, center=true)
        polygon(points=[
            [0, 0],
            [tooth_base, 0],
            [tooth_base*0.45, tooth_h]
        ]);
}

module toothed_edge() {
    // Teeth along +Y edge, protruding outward (+Y), overlapping into blade for connectivity.
    // Recalculated so tooth root line is inside the blade by (tooth_band_overlap + join_ol).
    y_root = blade_W/2 - (tooth_band_overlap + join_ol) + tooth_edge_offset;

    union() {
        for (i = [0:teeth_N-1]) {
            x_pos = -blade_L/2 + tooth_end_margin + i*tooth_pitch;

            // Alternate set (small lateral shift) but keep overlap into blade
            y_set = (i % 2 == 0) ? tooth_set_amp : -tooth_set_amp;

            translate([x_pos, y_root + y_set, 0])
                tooth_prism();
        }
    }
}

// ---------- Bi-metal band (thicker strip near tooth edge) ----------
module bimetal_band() {
    band_W = blade_W * bimetal_band_W_frac;

    // Place band near tooth edge (+Y) and ensure it overlaps into the blade by join_ol.
    // Make the band extend slightly beyond the blade edge so it reads as a distinct strip.
    // y_max = y_center + band_W/2 = blade_W/2 + join_ol  (guaranteed overlap)
    y_center = blade_W/2 - band_W/2 + join_ol;

    // Ensure Z intersection with blade: band thickness >= blade_T and centered at Z=0
    band_T = blade_T + bimetal_band_extraT + join_ol;

    translate([0, y_center, 0])
        cube([blade_L, band_W, band_T], center=true);
}

// ---------- Final connected model ----------
module bi_metal_saw_blade() {
    union() {
        blade_softened();
        bimetal_band();
        toothed_edge();
    }
}

bi_metal_saw_blade();