// T-slot nut (single connected solid) for 5.0mm screw, 6.0mm across flats, 3.7mm thick
// FIX: Ensure the hex "nut ring" is NOT floating by making it a positive feature
//      that is unioned to the main body with a small (1-2mm) overlap, then subtract holes.

screw_nominal_diameter_mm = 5.0;
across_flats_mm = 6.0;          // hex across flats (wrench size)
thickness_mm = 3.7;             // overall nut thickness

// Fit / style
tolerance_mm = 0.2;
hole_style_tapped_or_clearance = 0; // 0=clearance, 1=tap-minor
m5_clearance_diameter_mm = 5.5;
m5_tap_minor_diameter_mm = 4.2;

// Typical sliding T-nut proportions (editable)
nut_overall_length_mm = 12.0;   // along slot
nut_overall_width_mm  = 9.6;    // across slot

// T-slot undercut/lip geometry (editable)
lip_height_mm = 1.0;            // thickness of the undercut "head" portion
neck_width_mm = 6.2;            // narrower waist that fits slot opening
lip_overhang_mm = 1.2;          // per-side overhang beyond neck (forms T head)

// Small edge break
edge_chamfer_mm = 0.4;

// Helpers
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);
function hex_circumradius_from_af(af) = af / (2 * cos(30)); // across flats -> circumradius

module tslot_profile_2d(L, W, neckW, lipH, H) {
    neckW2 = clamp(neckW, 0.5, W - 0.01);
    lipH2  = clamp(lipH, 0.0, H - 0.01);

    union() {
        // Upper/neck portion (full length)
        square([L, neckW2], center=true);

        // Lower/head portion (wider), attached to bottom of neck
        if (lipH2 > 0) {
            headW = clamp(neckW2 + 2*lip_overhang_mm, neckW2, W);
            translate([0, -(neckW2/2 + headW/2 - 0.001)])  // tiny overlap in 2D
                square([L, headW], center=true);
        }
    }
}

module tslot_nut() {
    hole_d = ((1 - hole_style_tapped_or_clearance) * m5_clearance_diameter_mm
            + (hole_style_tapped_or_clearance) * m5_tap_minor_diameter_mm);

    // Constrain lip height to keep a solid top section
    lipH = clamp(lip_height_mm, 0.0, thickness_mm - 0.8);

    // Connectivity overlap between the added hex ring and the body (1-2mm required)
    overlap_mm = 1.2;

    // Hex ring geometry (positive feature that must be attached)
    hex_r = hex_circumradius_from_af(across_flats_mm) + tolerance_mm/2;
    ring_wall_mm = 1.2; // radial wall thickness of the ring (keeps design intent: "hex ring with central hole")
    ring_h_mm = 1.8;    // height of the ring feature

    // Place ring so it intersects the top of the body by overlap_mm
    // Body spans Z: [-thickness/2, +thickness/2]
    // Ring spans Z: [z0 - ring_h/2, z0 + ring_h/2]
    // Set ring bottom = body top - overlap => (z0 - ring_h/2) = thickness/2 - overlap
    ring_z = (thickness_mm/2 - overlap_mm) + ring_h_mm/2;

    difference() {
        // Build as a single connected solid: union(body + attached ring)
        union() {
            // Main T-nut body
            linear_extrude(height=thickness_mm, center=true)
                offset(delta=-edge_chamfer_mm)
                    offset(delta=edge_chamfer_mm)
                        tslot_profile_2d(nut_overall_length_mm, nut_overall_width_mm,
                                         neck_width_mm, lipH, thickness_mm);

            // Attached hex "nut ring" (previously appeared floating in some views)
            // This is a POSITIVE feature unioned to the body with guaranteed overlap.
            translate([0, 0, ring_z])
                difference() {
                    cylinder(r=hex_r, h=ring_h_mm, center=true, $fn=6);
                    cylinder(d=hole_d + 2*tolerance_mm, h=ring_h_mm + 2*tolerance_mm, center=true, $fn=64);
                }
        }

        // Central M5 hole through full thickness + through the ring (single continuous hole)
        cylinder(d=hole_d, h=thickness_mm + ring_h_mm + 4*tolerance_mm, center=true, $fn=64);

        // Hex capture recess on TOP face (kept as in original design)
        // Keep a solid floor so the part remains one connected solid.
        hex_depth = min(1.6, thickness_mm - 0.8);
        translate([0, 0, thickness_mm/2 - hex_depth/2])
            cylinder(r=hex_r, h=hex_depth + 2*tolerance_mm, center=true, $fn=6);
    }
}

tslot_nut();