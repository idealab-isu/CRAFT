$fn = 64;

// Rounded rectangular prism (centered)
module rrect_prism(size=[10,10,10], r=1) {
    x=size[0]; y=size[1]; z=size[2];
    r2 = min(r, min(x,y)/2);
    linear_extrude(height=z, center=true)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

// Mains transformer with core window, bobbin, mounting feet, and leads.
// Overall envelope matches body=[38,32,33] (X,Y,Z).
module transformer(body=[38,32,33], corner_r=2.0) {
    x = body[0];
    y = body[1];
    z = body[2];

    overlap = 0.8; // connectivity overlap

    // Feet: extend in X but keep overall X within x by shrinking main body accordingly
    foot_ext = x*0.12;                 // extension per side
    foot_w   = foot_ext;               // foot thickness in X
    foot_y   = y*0.55;                 // foot depth in Y
    foot_t   = max(2.0, z*0.09);       // foot thickness in Z
    foot_r   = min(1.2, corner_r);

    // Main body reduced so feet bring total X back to x
    core_x = x - 2*foot_ext;
    core_y = y;
    core_z = z;

    // Core window: through in Y, leaving top/bottom yokes in Z and side legs in X
    leg_x   = max(3.0, core_x*0.18);
    yoke_z  = max(3.0, core_z*0.16);
    win_x   = max(2.0, core_x - 2*leg_x);
    win_y   = y + 2;                   // ensure full cut-through in Y
    win_z   = max(2.0, core_z - 2*yoke_z);

    // Bobbin/winding pack (kept inside overall envelope)
    bob_x = max(6.0, win_x + 2*max(2.0, core_x*0.08));
    bob_y = y*0.62;
    bob_z = core_z*0.78;

    // Leads exiting +Y side, attached to bobbin
    lead_r      = 0.7;
    lead_len    = y*0.22;
    lead_z_off  = -core_z/2 + core_z*0.22;
    lead_x_span = bob_x*0.55;

    union() {
        // Laminated core block with window
        difference() {
            rrect_prism([core_x, core_y, core_z], r=corner_r);

            // Window cut: centered, through Y
            rrect_prism([win_x, win_y, win_z], r=corner_r*0.6);
        }

        // Bobbin/winding pack (overlaps into core for connectivity)
        rrect_prism([bob_x, bob_y, bob_z], r=corner_r*0.8);

        // Mounting feet (tabs) on left and right, attached at bottom
        for (sx = [-1, 1]) {
            translate([
                sx*(core_x/2 + foot_w/2 - overlap),
                0,
                -(core_z/2 - foot_t/2 + overlap)
            ])
                rrect_prism([foot_w, foot_y, foot_t], r=foot_r);
        }

        // Leads/terminals: two cylinders exiting +Y, overlapping into bobbin
        for (sx = [-1, 1]) {
            translate([sx*lead_x_span/2, (bob_y/2 - overlap), lead_z_off])
                rotate([90, 0, 0])
                    cylinder(h=lead_len, r=lead_r, center=false);
        }
    }
}

transformer([38.0, 32.0, 33.0], corner_r=2.0);