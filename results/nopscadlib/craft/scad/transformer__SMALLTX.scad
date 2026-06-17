// Mains transformer (stylized) - overall envelope: 38.0 x 32.0 x 33.0 mm
// One connected solid, with recognizable features (laminated core, bobbin, leads)

$fn = 64;

// Overall requested dimensions
width_mm  = 38.0;  // X
depth_mm  = 32.0;  // Y
height_mm = 33.0;  // Z

// Overlap to guarantee watertight unions (use 1-2mm as requested)
ov = 1.2;

// Helper: rounded box (robust; avoids minkowski "blank" issues)
module rbox(size=[10,10,10], r=1.5, center=true) {
    sx=size[0]; sy=size[1]; sz=size[2];
    rr = min(r, sx/2, sy/2, sz/2);

    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
        hull() {
            for (x = [-1,1], y = [-1,1], z = [-1,1])
                translate([x*(sx/2-rr), y*(sy/2-rr), z*(sz/2-rr)])
                    sphere(r=rr);
        }
}

module transformer() {
    // Allocate envelope into: top core + bobbin + bottom core
    core_t   = 8.0;                         // top/bottom lamination thickness
    bobbin_h = height_mm - 2*core_t;        // middle height

    // Core footprint inside envelope
    core_w = width_mm;
    core_d = depth_mm;

    // Bobbin footprint (slightly smaller than core)
    bob_w = width_mm * 0.78;
    bob_d = depth_mm * 0.72;

    // Center leg (visible through window impression)
    leg_w = width_mm * 0.22;
    leg_d = depth_mm * 0.22;

    // Window impression (subtracted from bobbin to suggest core window)
    win_w = max(1, bob_w - 2*(leg_w*0.55));
    win_d = max(1, bob_d - 2*(leg_d*0.55));

    // Leads (side)
    lead_r = 0.9;
    lead_len = 7.0;
    lead_pitch = 2.54;
    num_leads = 4;

    // Lead block (strain relief) on one side
    leadblk_w = 6.0;
    leadblk_d = 10.0;
    leadblk_h = 6.0;

    // Bottom terminals/pins (4 small circular features) + small rectangular tab
    term_r = 1.1;
    term_h = 2.6;
    tab_w  = 12.0;
    tab_d  = 6.0;
    tab_h  = 2.2;

    // Z positions computed from dimensions
    z_core_top =  height_mm/2 - core_t/2;
    z_core_bot = -height_mm/2 + core_t/2;
    z_bobbin   = 0;

    // Side for leads: +Y face
    y_face = depth_mm/2;

    union() {
        // Bottom core (laminations)
        translate([0,0,z_core_bot])
            rbox([core_w, core_d, core_t], r=1.2, center=true);

        // Top core (laminations)
        translate([0,0,z_core_top])
            rbox([core_w, core_d, core_t], r=1.2, center=true);

        // Center leg connecting top and bottom cores (ensures single connected solid)
        translate([0,0,0])
            rbox([leg_w, leg_d, bobbin_h + 2*ov], r=0.8, center=true);

        // Bobbin / coil former (with window impression)
        difference() {
            translate([0,0,z_bobbin])
                rbox([bob_w, bob_d, bobbin_h + ov], r=1.0, center=true);

            // Window impression (not through entire bobbin)
            translate([0,0,z_bobbin])
                rbox([win_w, win_d, bobbin_h*0.70], r=0.8, center=true);
        }

        // Lead block attached to +Y side of bobbin (connected with overlap)
        translate([0,
                   y_face - leadblk_d/2 + ov,
                   -height_mm/2 + leadblk_h/2 + ov])
            rbox([leadblk_w, leadblk_d, leadblk_h], r=0.8, center=true);

        // Leads (4 pins) exiting from lead block, protruding outward +Y
        // Ensure they overlap into the lead block by ov
        y_leadblk_center = y_face - leadblk_d/2 + ov;
        y_leadblk_outer  = y_leadblk_center + leadblk_d/2; // outer (+Y) face of lead block
        for (i = [0:num_leads-1]) {
            x_i = (i - (num_leads-1)/2) * lead_pitch;

            // Cylinder axis along +Y (after rotate), so place center so it penetrates the block by ov
            translate([x_i,
                       y_leadblk_outer + (lead_len/2 - ov),
                       -height_mm/2 + leadblk_h*0.35])
                rotate([90,0,0])
                    cylinder(h=lead_len, r=lead_r, center=true);
        }

        // --- FIX: Bottom tab + 4 bottom terminals must be physically attached (no floating) ---
        // Place tab so its TOP penetrates into the bottom core by ov.
        z_bottom_core_bottom = z_core_bot - core_t/2; // bottom face of bottom core
        z_tab_center = z_bottom_core_bottom - tab_h/2 + ov;

        // Put tab near the lead side (+Y), but still under the body; ensure it intersects bottom core.
        y_tab_center = y_face - tab_d/2 + ov;

        translate([0, y_tab_center, z_tab_center])
            rbox([tab_w, tab_d, tab_h], r=0.6, center=true);

        // Terminals: place so their TOP penetrates into the tab by ov (and thus into the main body).
        z_tab_top = z_tab_center + tab_h/2;
        z_term_center = z_tab_top - ov - term_h/2;

        // Arrange 4 terminals in a 2x2 pattern on the tab
        term_dx = 3.6;
        term_dy = 2.2;

        for (ix = [-0.5, 0.5], iy = [-0.5, 0.5]) {
            translate([ix*term_dx,
                       y_tab_center + iy*term_dy,
                       z_term_center])
                cylinder(h=term_h, r=term_r, center=true);
        }
    }
}

transformer();