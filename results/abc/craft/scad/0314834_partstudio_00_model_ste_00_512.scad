// Dimension-calibrated (target: 0.10 x 0.08 x 0.03 mm)
scale([0.990111, 1.000000, 0.600010])
{
// Rectangular frame with thicker end block and stepped angled cantilever hook tab
// Dimensions in mm (very small part). Ensures visible, connected geometry and a clear undercut pocket.

$fn = 48;

L = 0.1;
W = 0.08;
T = 0.03;

window_L = 0.07;
window_W = 0.05;

end_block_L = 0.02;
end_block_T = 0.05;

tab_L = 0.018;
tab_W = 0.02;
tab_T = 0.012;
tab_inset_from_end = 0.004;
tab_angle_deg = 25;

tab_step_drop = 0.006;
tab_step_L = 0.010;
tab_step_W = 0.016;

gap_L = 0.014;
gap_W = 0.018;
gap_T = 0.010;

overlap = 0.001;

// ---------- Base solids ----------
module frame_plate() {
    cube([L, W, T], center=true);
}

module window_cut() {
    cube([window_L, window_W, T + 6*overlap], center=true);
}

module end_block() {
    // Thicker block on +X end, connected with overlap
    translate([L/2 - end_block_L/2 + overlap, 0, 0])
        cube([end_block_L, W, end_block_T], center=true);
}

// ---------- Hook feature (built in local coordinates, then placed/rotated) ----------
module hook_feature_local() {
    // Local X: into the window (negative global X after placement)
    // Local Z: thickness direction

    // Main cantilever tab (flat-ish, near top surface)
    translate([tab_L/2, 0, 0])
        cube([tab_L, tab_W, tab_T], center=true);

    // Stepped lip at free end, dropped down to create hook profile
    // Make it slightly thicker than tab_step_drop for visibility and robustness
    step_h = max(tab_step_drop, tab_T*0.6);
    translate([tab_L - tab_step_L/2, 0, -(tab_T/2 + step_h/2 - overlap)])
        cube([tab_step_L, tab_step_W, step_h], center=true);
}

module hook_feature_placed() {
    // Inner face of end block toward window:
    // end block spans x in [L/2 - end_block_L, L/2]
    x_inner_end = L/2 - end_block_L;

    // Anchor plane for tab base: slightly inside the window from the inner face
    // Local origin is at tab base plane.
    x_base = x_inner_end - tab_inset_from_end + overlap;

    // Place near top surface of the frame so the undercut pocket is visible
    z_top = T/2;
    z_center = z_top - tab_T/2 + overlap;

    translate([x_base, 0, z_center])
        rotate([0, tab_angle_deg, 0])
            hook_feature_local();
}

// ---------- Undercut-like pocket (subtract) ----------
module undercut_gap() {
    x_inner_end = L/2 - end_block_L;

    // Put pocket under the tab, not through the whole plate
    // Centered a bit into the window from the tab base
    x_gap = x_inner_end - tab_inset_from_end - gap_L/2 + overlap;

    // Pocket sits below the tab, leaving a "ceiling" of material above it
    // Ensure it stays within the plate thickness (doesn't break through bottom)
    z_gap = (T/2 - tab_T) - gap_T/2 + overlap;

    translate([x_gap, 0, z_gap])
        cube([gap_L, gap_W, gap_T], center=true);
}

// ---------- Model ----------
module complete_model() {
    difference() {
        union() {
            // Frame + end block with through window
            difference() {
                union() {
                    frame_plate();
                    end_block();
                }
                window_cut();
            }

            // Hook feature (must be connected to frame/end block)
            hook_feature_placed();
        }

        // Undercut pocket under the tab
        undercut_gap();
    }
}

complete_model();
}
