$fn = 64;

// Overall requested envelope (X x Y x Z)
width_mm  = 120;  // X
depth_mm  = 88;   // Y
height_mm = 120;  // Z

// Small overlap to guarantee watertight unions
ov = 0.6;

// Rounded box helper
module rbox(size=[10,10,10], r=2, center=true) {
    x=size[0]; y=size[1]; z=size[2];
    r2 = min(r, x/2-0.01, y/2-0.01, z/2-0.01);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
    minkowski() {
        cube([x-2*r2, y-2*r2, z-2*r2], center=true);
        sphere(r=r2);
    }
}

module transformer() {
    // Base and body
    base_h      = 10;

    // Feet are integrated pads on the base corners (do not exceed envelope)
    foot_w      = 18;
    foot_d      = 16;
    foot_h      = base_h;
    foot_inset  = 8;

    body_h      = height_mm - base_h;
    body_w      = width_mm - 2*foot_inset;
    body_d      = depth_mm - 2*foot_inset;

    // Cosmetic recess on front face (+Y)
    win_w       = body_w * 0.42;
    win_h       = body_h * 0.55;
    win_depth   = min(10, body_d*0.18);

    // Terminal block on top (kept within envelope)
    term_w      = body_w * 0.55;
    term_d      = body_d * 0.22;
    term_h      = 12;

    // Side lead exit bump (kept within envelope)
    lead_w      = 18;
    lead_d      = 22;
    lead_h      = 14;

    // Derived Z positions (all formula-based)
    z_base_c    = -height_mm/2 + base_h/2;
    z_body_c    = -height_mm/2 + base_h + body_h/2 - ov;
    z_term_c    = -height_mm/2 + base_h + body_h + term_h/2 - ov;
    z_lead_c    = -height_mm/2 + base_h + body_h*0.55;

    // Keep lead bump inside overall width: its outer face at +width_mm/2
    x_lead_c    = width_mm/2 - lead_w/2 + ov;

    // One connected solid with cosmetic subtractions
    difference() {
        union() {
            // Base plate
            translate([0, 0, z_base_c])
                rbox([width_mm, depth_mm, base_h], r=2.5, center=true);

            // Mounting feet (pads on base corners)
            for (sx = [-1, 1], sy = [-1, 1]) {
                translate([
                    sx*(width_mm/2 - foot_inset - foot_w/2),
                    sy*(depth_mm/2 - foot_inset - foot_d/2),
                    z_base_c
                ])
                    rbox([foot_w, foot_d, foot_h], r=2, center=true);
            }

            // Main body
            translate([0, 0, z_body_c])
                rbox([body_w, body_d, body_h], r=4, center=true);

            // Terminal block on top (connected)
            translate([0, 0, z_term_c])
                rbox([term_w, term_d, term_h], r=2, center=true);

            // Lead exit bump on +X side (connected and within envelope)
            translate([x_lead_c, 0, z_lead_c])
                rbox([lead_w, lead_d, lead_h], r=2, center=true);

            // Strain-relief cylinder on lead bump (connected)
            // Place it so it stays within +width_mm/2
            cyl_h = lead_w*0.7;
            cyl_r = 4;
            x_cyl_c = (width_mm/2 - cyl_h/2) - 0.01; // tiny margin inside envelope
            translate([x_cyl_c, 0, z_lead_c])
                rotate([0,90,0])
                    cylinder(h=cyl_h, r=cyl_r, center=true);
        }

        // Front "window" recess (on +Y face of body), shallow
        translate([
            0,
            body_d/2 - win_depth/2 + 0.01,
            -height_mm/2 + base_h + body_h/2
        ])
            rbox([win_w, win_depth, win_h], r=2, center=true);

        // Side lamination grooves (shallow channels on both sides)
        groove_w = 2.2;
        groove_d = body_d * 0.85;
        groove_h = body_h * 0.85;
        num_grooves = 7;

        for (i = [0:num_grooves-1]) {
            xoff = (-body_w*0.35) + i*(body_w*0.70/(num_grooves-1));

            // Left face groove
            translate([
                -body_w/2 + groove_w/2 + 0.01,
                0,
                -height_mm/2 + base_h + body_h/2
            ])
                translate([xoff, 0, 0])
                    rbox([groove_w, groove_d, groove_h], r=0.8, center=true);

            // Right face groove
            translate([
                body_w/2 - groove_w/2 - 0.01,
                0,
                -height_mm/2 + base_h + body_h/2
            ])
                translate([xoff, 0, 0])
                    rbox([groove_w, groove_d, groove_h], r=0.8, center=true);
        }

        // Terminal screw dimples (shallow)
        dimple_r = 2.2;
        dimple_h = 2.5;
        for (sx = [-1, 1], sy = [-1, 1]) {
            translate([
                sx*(term_w*0.28),
                sy*(term_d*0.25),
                (-height_mm/2 + base_h + body_h + term_h) - dimple_h/2 + 0.01
            ])
                cylinder(h=dimple_h, r=dimple_r, center=true);
        }
    }
}

transformer();