$fn = 64;

// Rounded box helper (centered)
module rbox(sz=[10,10,10], r=2, center=true){
    x=sz[0]; y=sz[1]; z=sz[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=r)
                square([max(0.01,x-2*r), max(0.01,y-2*r)], center=true);
}

// Main transformer model: overall bounding size = 120 x 88 x 120 (X,Y,Z)
module transformer(size=[120,88,120], corner_r=4){
    X=size[0]; Y=size[1]; Z=size[2];

    // Small overlap to guarantee manifold unions
    ov = 0.8;

    // Proportions
    base_h = Z*0.12;                 // bottom mounting base thickness
    top_h  = Z*0.10;                 // top cover thickness
    core_h = Z - base_h - top_h;     // middle stack height

    // Middle stack footprint (inset from overall)
    core_x = X*0.82;
    core_y = Y*0.82;

    // "Laminated core" look: add shallow ribs on the sides of the core
    rib_count = 9;
    rib_w = core_x*0.018;
    rib_depth = core_y*0.06;

    // Window cutout to suggest E/I core window
    win_x = core_x*0.44;
    win_y = core_y*0.34;

    // Bobbin/coil block (fills window area, overlaps into core)
    bob_x = win_x*0.92;
    bob_y = win_y*0.92;
    bob_h = core_h*0.96;

    // Coil bulge around bobbin (suggest winding)
    coil_x = bob_x*1.10;
    coil_y = bob_y*1.10;
    coil_h = bob_h*0.92;

    // Mounting feet integrated into base (with holes)
    foot_x = X*0.26;
    foot_y = Y*0.18;
    foot_h = base_h*0.60;

    hole_r = min(X,Y)*0.035;         // ~3mm for this size
    hole_z = base_h + 2*ov;

    // Terminal block on +X side, attached to core
    term_x = X*0.18;
    term_y = Y*0.30;
    term_h = core_h*0.34;

    // Leads exiting from terminal block to +X
    lead_r = min(X,Y,Z)*0.012;
    lead_len = X*0.12;
    lead_count = 6;
    lead_pitch = (term_y*0.70)/(lead_count-1);

    // Z positions
    z_base_c = -Z/2 + base_h/2;
    z_core_c = -Z/2 + base_h + core_h/2;
    z_top_c  =  Z/2 - top_h/2;

    // Terminal placement (connected to core)
    term_cx = (core_x/2 + term_x/2 - ov);
    term_cz = z_core_c + core_h*0.05;

    color([0.15,0.15,0.15])
    union() {

        // Bottom base with mounting feet and holes (single connected solid)
        difference() {
            union() {
                // Base plate (full footprint)
                translate([0,0,z_base_c])
                    rbox([X, Y, base_h], r=corner_r, center=true);

                // Feet (protrude slightly, integrated)
                for(sx=[-1,1], sy=[-1,1]) {
                    translate([
                        sx*(X/2 - foot_x/2 - corner_r),
                        sy*(Y/2 - foot_y/2 - corner_r),
                        -Z/2 + foot_h/2
                    ])
                        rbox([foot_x, foot_y, foot_h], r=corner_r*0.6, center=true);
                }
            }

            // Mounting holes through base (near corners, inside feet)
            for(sx=[-1,1], sy=[-1,1]) {
                hx = sx*(X/2 - foot_x/2 - corner_r);
                hy = sy*(Y/2 - foot_y/2 - corner_r);
                translate([hx, hy, -Z/2 + base_h/2])
                    cylinder(h=hole_z, r=hole_r, center=true);
            }
        }

        // Top cover (full footprint)
        translate([0,0,z_top_c])
            rbox([X, Y, top_h], r=corner_r, center=true);

        // Middle laminated core stack with window cutout
        translate([0,0,z_core_c])
        difference() {
            rbox([core_x, core_y, core_h], r=corner_r*0.8, center=true);

            // Window cutout (through the stack)
            rbox([win_x, win_y, core_h + 2*ov], r=corner_r*0.6, center=true);
        }

        // Laminations/ribs on both long sides (connected to core)
        for(i=[0:rib_count-1]) {
            t = (i/(rib_count-1) - 0.5);
            x_i = t*(core_x - rib_w);
            // +Y side rib
            translate([x_i, core_y/2 - rib_depth/2 + ov, z_core_c])
                rbox([rib_w, rib_depth, core_h], r=corner_r*0.25, center=true);
            // -Y side rib
            translate([x_i, -core_y/2 + rib_depth/2 - ov, z_core_c])
                rbox([rib_w, rib_depth, core_h], r=corner_r*0.25, center=true);
        }

        // Bobbin/coil former inside window (overlaps into core so it's connected)
        translate([0,0,z_core_c])
            rbox([bob_x, bob_y, bob_h], r=corner_r*0.45, center=true);

        // Coil bulge (suggest winding), also connected
        translate([0,0,z_core_c])
            rbox([coil_x, coil_y, coil_h], r=corner_r*0.55, center=true);

        // Terminal block on +X side, attached to core
        translate([term_cx, 0, term_cz])
            rbox([term_x, term_y, term_h], r=corner_r*0.4, center=true);

        // Leads exiting from terminal block to +X (all connected)
        for(i=[0:lead_count-1]) {
            y_i = -term_y*0.35 + i*lead_pitch;
            translate([
                term_cx + term_x/2 - ov + lead_len/2,
                y_i,
                term_cz
            ])
            rotate([0,90,0])
                cylinder(h=lead_len, r=lead_r, center=true);
        }
    }
}

transformer([120.0, 88.0, 120.0], corner_r=4);