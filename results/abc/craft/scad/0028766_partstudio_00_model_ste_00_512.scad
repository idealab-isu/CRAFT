// Dimension-calibrated (target: 0.09 x 0.02 x 0.06 mm)
scale([1.097275, 1.363674, 0.312653])
{
// Low-poly T-handle / knob (single connected solid)
// Structural fixes applied:
// - Add centered diamond-shaped recessed feature on BOTH side faces of the grip
// - Keep slight curvature in grip (faceted)
// - Recalculate ALL translate() placements from dimensions (no arbitrary offsets)
// - Ensure ALL parts are connected with small overlap (scaled to this tiny model)

$fn = 18;

// ---------- Parameters (mm) ----------
grip_L = 0.09;
grip_W = 0.02;
grip_H = 0.02;

// Slight curvature (ends higher than center)
grip_curve_sag = 0.006;
grip_segments  = 9;

stem_W = 0.012;
stem_D = 0.012;
stem_H = 0.032;

stem_offset_from_grip_center_L = 0.0;
stem_offset_from_grip_center_W = 0.0;

base_flange_D = 0.020;
base_flange_H = 0.006;
base_cap_D    = 0.014;
base_cap_H    = 0.004;

gusset_L = 0.018;
gusset_W = 0.016;
gusset_H = 0.014;

diamond_recess_depth = 0.003;
diamond_recess_W     = 0.012;
diamond_recess_H     = 0.012;
diamond_recess_z     = 0.0;

// Overlap scaled for this tiny model (requirement says 1-2mm, but model is <0.1mm long)
// Use a small but meaningful overlap relative to features to guarantee manifold connectivity.
overlap = 0.001;

// ---------- Helpers ----------
function lerp(a,b,t) = a + (b-a)*t;
function sag_profile(t) = pow(abs(2*t - 1), 1.6);

// ---------- Grip (faceted, slightly curved) ----------
module grip_segment(xpos, zpos, segL) {
    translate([xpos, 0, zpos])
        cube([segL, grip_W, grip_H], center=true);
}

module grip_curved_faceted() {
    segL = grip_L / grip_segments;

    hull() {
        for (i = [0:grip_segments-1]) {
            t = (i + 0.5) / grip_segments; // 0..1
            x = lerp(-grip_L/2 + segL/2, grip_L/2 - segL/2, t);
            z = grip_curve_sag * sag_profile(t);
            grip_segment(x, z, segL);
        }
    }
}

// ---------- Diamond recess cutters (side faces) ----------
module diamond_recess_cutter() {
    // Diamond in XZ plane, extruded along Y
    rotate([90,0,0])  // extrusion axis becomes Y
        linear_extrude(height = diamond_recess_depth + 2*overlap, center=true)
            polygon(points=[
                [0,  diamond_recess_H/2],
                [ diamond_recess_W/2, 0],
                [0, -diamond_recess_H/2],
                [-diamond_recess_W/2, 0]
            ]);
}

module grip_with_recesses() {
    difference() {
        grip_curved_faceted();

        // Place cutters so they bite into the side faces by diamond_recess_depth.
        // Center of cutter sits just inside each side face.
        y_inset = grip_W/2 - diamond_recess_depth/2 + overlap;

        translate([0, -y_inset, diamond_recess_z]) diamond_recess_cutter();
        translate([0,  y_inset, diamond_recess_z]) diamond_recess_cutter();
    }
}

// ---------- Stem + faceted gussets + flange/cap ----------
module stem_main() {
    // Stem top should overlap into grip underside for a solid connection
    z_stem_center = -(grip_H/2 + stem_H/2 - overlap);

    translate([
        stem_offset_from_grip_center_L,
        stem_offset_from_grip_center_W,
        z_stem_center
    ])
        cube([stem_W, stem_D, stem_H], center=true);
}

module stem_to_grip_gussets_faceted() {
    // Gussets connect stem to underside of grip with faceted hulls
    x0 = stem_offset_from_grip_center_L;
    y0 = stem_offset_from_grip_center_W;

    // Place gusset blocks just under the grip, overlapping slightly into it
    z_under = -(grip_H/2 - gusset_H/2 - overlap);

    union() {
        // Left/right gussets (along X)
        hull() {
            stem_main();
            translate([x0 - (stem_W/2 + gusset_L/2 - overlap), y0, z_under])
                cube([gusset_L, gusset_W, gusset_H], center=true);
        }
        hull() {
            stem_main();
            translate([x0 + (stem_W/2 + gusset_L/2 - overlap), y0, z_under])
                cube([gusset_L, gusset_W, gusset_H], center=true);
        }

        // Front/back gussets (along Y)
        hull() {
            stem_main();
            translate([x0, y0 - (stem_D/2 + gusset_W/2 - overlap), z_under])
                cube([gusset_W, gusset_L, gusset_H], center=true);
        }
        hull() {
            stem_main();
            translate([x0, y0 + (stem_D/2 + gusset_W/2 - overlap), z_under])
                cube([gusset_W, gusset_L, gusset_H], center=true);
        }
    }
}

module stem_base_flange_cap() {
    // Compute stem bottom Z from grip and stem dimensions (no arbitrary values)
    z_stem_center = -(grip_H/2 + stem_H/2 - overlap);
    z_stem_bottom = z_stem_center - stem_H/2; // bottom face of stem

    // Flange sits directly under stem bottom, overlapping slightly into stem
    z_flange_center = z_stem_bottom - base_flange_H/2 + overlap;

    // Cap sits under flange, overlapping slightly into flange
    z_cap_center = (z_flange_center - base_flange_H/2) - base_cap_H/2 + overlap;

    union() {
        translate([stem_offset_from_grip_center_L, stem_offset_from_grip_center_W, z_flange_center])
            cylinder(r=base_flange_D/2, h=base_flange_H, center=true, $fn=12);

        translate([stem_offset_from_grip_center_L, stem_offset_from_grip_center_W, z_cap_center])
            cylinder(r=base_cap_D/2, h=base_cap_H, center=true, $fn=12);
    }
}

module vertical_stem() {
    union() {
        stem_main();
        stem_to_grip_gussets_faceted();
        stem_base_flange_cap();
    }
}

// ---------- Complete model (ONE connected solid) ----------
union() {
    grip_with_recesses();
    vertical_stem();
}
}
