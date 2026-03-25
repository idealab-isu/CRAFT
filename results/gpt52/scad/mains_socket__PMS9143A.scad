$fn=96;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
    }
}

module countersunk_hole(th, d_through=4.2, d_head=8.5, head_depth=2.2){
    union(){
        cylinder(h=th+0.2, d=d_through, center=false);
        translate([0,0,th-head_depth]) cylinder(h=head_depth+0.3, d1=d_head, d2=d_through, center=false);
    }
}

module uk_socket_faceplate(){
    plate_w = 86;
    plate_h = 86;
    plate_t = 9.5;
    corner_r = 6;

    recess_w = 70;
    recess_h = 70;
    recess_depth = 1.6;
    recess_r = 4;

    screw_spacing = 60.3;
    screw_d_through = 4.2;
    screw_d_head = 8.5;
    screw_head_depth = 2.2;

    difference(){
        linear_extrude(height=plate_t)
            rounded_rect_2d(plate_w, plate_h, corner_r);

        translate([0,0,plate_t-recess_depth])
            linear_extrude(height=recess_depth+0.2)
                rounded_rect_2d(recess_w, recess_h, recess_r);

        for(y=[-screw_spacing/2, screw_spacing/2]){
            translate([0,y,0])
                countersunk_hole(plate_t, screw_d_through, screw_d_head, screw_head_depth);
        }
    }
}

module uk_socket_apertures(){
    plate_t = 9.5;

    // Positions based on typical UK socket geometry
    y_top = 18.5;
    y_bottom = -10.5;
    x_lr = 12.7;

    // Earth (top) slot
    earth_w = 6.6;
    earth_h = 14.0;

    // Live/Neutral (bottom) slots
    ln_w = 6.6;
    ln_h = 18.0;

    // Safety shutter/inner clearance (subtle)
    inner_clear_d = 36;

    union(){
        // Earth
        translate([0,y_top,0])
            linear_extrude(height=plate_t+0.6)
                rounded_rect_2d(earth_w, earth_h, 1.2);

        // Live
        translate([ x_lr, y_bottom,0])
            linear_extrude(height=plate_t+0.6)
                rounded_rect_2d(ln_w, ln_h, 1.2);

        // Neutral
        translate([-x_lr, y_bottom,0])
            linear_extrude(height=plate_t+0.6)
                rounded_rect_2d(ln_w, ln_h, 1.2);

        // Inner clearance pocket (very shallow) to suggest shutter area
        translate([0,2.5,plate_t-0.9])
            cylinder(h=1.2, d=inner_clear_d, center=false);
    }
}

module uk_socket_body(){
    // Simplified back box protrusion
    body_w = 70;
    body_h = 70;
    body_d = 28;
    body_r = 4;

    translate([0,0,-body_d])
        linear_extrude(height=body_d)
            rounded_rect_2d(body_w, body_h, body_r);
}

module uk_socket_detail(){
    // Subtle raised bezel around apertures
    bezel_w = 52;
    bezel_h = 52;
    bezel_t = 0.9;
    bezel_r = 3;

    translate([0,0,9.5-bezel_t])
        linear_extrude(height=bezel_t)
            rounded_rect_2d(bezel_w, bezel_h, bezel_r);

    // Screw head rings
    screw_spacing = 60.3;
    ring_od = 12.0;
    ring_id = 8.8;
    ring_t = 0.6;

    for(y=[-screw_spacing/2, screw_spacing/2]){
        translate([0,y,9.5-ring_t])
            difference(){
                cylinder(h=ring_t, d=ring_od, center=false);
                translate([0,0,-0.1]) cylinder(h=ring_t+0.2, d=ring_id, center=false);
            }
    }
}

module mains_socket_screwfix_essential_unswitched(){
    // Centered at origin: faceplate centered in X/Y, mid-thickness around Z=0
    plate_t = 9.5;

    translate([0,0,-plate_t/2])
    difference(){
        union(){
            uk_socket_faceplate();
            uk_socket_detail();
            uk_socket_body();
        }
        uk_socket_apertures();
    }
}

mains_socket_screwfix_essential_unswitched();