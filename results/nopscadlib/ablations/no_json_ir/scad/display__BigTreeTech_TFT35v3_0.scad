$fn = 64;

module rounded_rect_prism(size=[10,10,1], r=1, center=true){
    // size = [x,y,z]
    x = size[0]; y = size[1]; z = size[2];
    rr = min(r, x/2, y/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            offset(r=rr)
                square([x-2*rr, y-2*rr], center=true);
}

module display_module_v3(){
    // Target overall footprint: 84.5mm x 54.5mm
    W = 84.5;
    H = 54.5;

    // Thickness stack (kept as one connected solid)
    pcb_t   = 1.6;
    bezel_t = 3.0;
    glass_t = 0.6;
    total_t = pcb_t + bezel_t + glass_t;

    // Z references (centered model)
    z_bot = -total_t/2;
    z_top =  total_t/2;

    // Bezel outer and window
    corner_r = 2.0;
    bezel_w = W;
    bezel_h = H;

    // Window sized to look like a display opening (not full cut-through)
    win_w = 70.0;
    win_h = 44.0;
    win_r = 1.2;

    // Window recess depth into bezel (from top)
    recess_d = 1.6;

    // Mounting holes (through PCB+bezel, not through glass)
    hole_r = 1.6;
    hole_inset_x = 4.0;
    hole_inset_y = 4.0;
    hole_x = bezel_w/2 - hole_inset_x;
    hole_y = bezel_h/2 - hole_inset_y;

    // Connector bump on back (kept connected)
    conn_w = 18.0;
    conn_h = 8.0;
    conn_t = 3.0;
    conn_r = 1.0;

    // Place connector near left side, slightly above center
    conn_x = -bezel_w/2 + conn_w/2 + 6.0;
    conn_y =  bezel_h/2 - conn_h/2 - 10.0;

    // Small standoffs/pins on back (connected)
    pin_r = 1.2;
    pin_h = 3.0;
    pin_inset_x = 6.0;
    pin_inset_y = 6.0;
    pin_x = bezel_w/2 - pin_inset_x;
    pin_y = bezel_h/2 - pin_inset_y;

    union(){
        // Main body: PCB + bezel as one solid, with window recess and mounting holes removed
        difference(){
            union(){
                // PCB slab (bottom)
                translate([0,0, z_bot + pcb_t/2])
                    rounded_rect_prism([W, H, pcb_t], r=corner_r, center=true);

                // Bezel slab (middle)
                translate([0,0, z_bot + pcb_t + bezel_t/2])
                    rounded_rect_prism([bezel_w, bezel_h, bezel_t], r=corner_r, center=true);

                // Glass layer (top) - slightly inset to show edge
                translate([0,0, z_top - glass_t/2])
                    rounded_rect_prism([W-0.8, H-0.8, glass_t], r=max(corner_r-0.4,0.2), center=true);

                // Back connector bump (overlaps into PCB to ensure connectivity)
                translate([conn_x, conn_y, z_bot + pcb_t/2 - 0.2])
                    rounded_rect_prism([conn_w, conn_h, pcb_t + conn_t], r=conn_r, center=true);

                // Back pins/standoffs (overlap into PCB)
                for (sx = [-1, 1])
                    for (sy = [-1, 1])
                        translate([sx*pin_x, sy*pin_y, z_bot + pin_h/2 - 0.2])
                            cylinder(h=pin_h + 0.4, r=pin_r, center=true);
            }

            // Display window recess (does NOT cut through entire module)
            // Starts at top surface and goes down recess_d into bezel/glass
            translate([0, 0, z_top - recess_d/2 + 0.01])
                rounded_rect_prism([win_w, win_h, recess_d + 0.02], r=win_r, center=true);

            // Mounting holes (through PCB+bezel, stop before glass)
            hole_h = pcb_t + bezel_t + 0.4;
            hole_z = z_bot + hole_h/2 - 0.2;
            for (sx = [-1, 1])
                for (sy = [-1, 1])
                    translate([sx*hole_x, sy*hole_y, hole_z])
                        cylinder(h=hole_h, r=hole_r, center=true);
        }

        // Subtle raised bezel lip around window (adds recognizable feature, connected)
        lip_t = 0.6;
        lip_w = win_w + 6.0;
        lip_h = win_h + 6.0;
        lip_r = win_r + 0.8;

        translate([0,0, z_top - glass_t - lip_t/2 + 0.01])
            difference(){
                rounded_rect_prism([lip_w, lip_h, lip_t], r=lip_r, center=true);
                translate([0,0,0])
                    rounded_rect_prism([win_w+1.0, win_h+1.0, lip_t+0.2], r=win_r, center=true);
            }
    }
}

display_module_v3();