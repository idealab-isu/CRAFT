$fn = 64;

module segment_bar(len=8, w=1.2, t=0.9, chamfer=0.35){
    // 2D chamfered rectangle extruded
    linear_extrude(height=t)
    polygon(points=[
        [-len/2+chamfer, -w/2],
        [ len/2-chamfer, -w/2],
        [ len/2, -w/2+chamfer],
        [ len/2,  w/2-chamfer],
        [ len/2-chamfer,  w/2],
        [-len/2+chamfer,  w/2],
        [-len/2,  w/2-chamfer],
        [-len/2, -w/2+chamfer]
    ]);
}

module seven_segment_digit(dW=7.2, dH=12.7, segW=1.2, segT=0.9){
    // Segment naming: a (top), b (upper right), c (lower right), d (bottom), e (lower left), f (upper left), g (middle)
    // Choose geometry proportions
    margin = 0.35;
    hLen = dW - 2*segW - 2*margin;
    vLen = (dH - 3*segW - 2*margin)/2;

    // Safety clamps
    hLen2 = max(1, hLen);
    vLen2 = max(1, vLen);

    z0 = 0;

    union(){
        // a
        translate([0, dH/2 - segW/2 - margin, z0])
            segment_bar(len=hLen2, w=segW, t=segT);
        // d
        translate([0, -dH/2 + segW/2 + margin, z0])
            segment_bar(len=hLen2, w=segW, t=segT);
        // g
        translate([0, 0, z0])
            segment_bar(len=hLen2, w=segW, t=segT);

        // f (upper left)
        translate([-dW/2 + segW/2 + margin, dH/4 + segW/4, z0])
            rotate([0,0,90]) segment_bar(len=vLen2, w=segW, t=segT);

        // e (lower left)
        translate([-dW/2 + segW/2 + margin, -dH/4 - segW/4, z0])
            rotate([0,0,90]) segment_bar(len=vLen2, w=segW, t=segT);

        // b (upper right)
        translate([ dW/2 - segW/2 - margin, dH/4 + segW/4, z0])
            rotate([0,0,90]) segment_bar(len=vLen2, w=segW, t=segT);

        // c (lower right)
        translate([ dW/2 - segW/2 - margin, -dH/4 - segW/4, z0])
            rotate([0,0,90]) segment_bar(len=vLen2, w=segW, t=segT);
    }
}

module pin_grid_5x2(pitch_x=2.54, pitch_y=2.54, pin_d=0.6, pin_len=3.5, stand=0.6){
    // 5 columns (x), 2 rows (y). Centered about origin.
    union(){
        for (ix=[0:4])
            for (iy=[0:1]){
                x = (ix-2)*pitch_x;
                y = (iy-0.5)*pitch_y;
                // Pin
                translate([x,y,-pin_len])
                    cylinder(h=pin_len, d=pin_d);
                // Small plastic stand/shoulder at body bottom
                translate([x,y,0])
                    cylinder(h=stand, d=pin_d*1.6);
            }
    }
}

module seven_segment_module(body_x=12.7, body_y=19.0, body_z=8.2,
                            digit_w=7.2, digit_h=12.7, seg_w=1.2,
                            bezel_th=1.0, window_through=2.0){
    // Center body at origin; top face at +body_z/2
    union(){
        // Body with window cutout
        difference(){
            // Main body
            translate([0,0,0])
                cube([body_x, body_y, body_z], center=true);

            // Window recess on the top
            translate([0, 0, body_z/2 - bezel_th/2])
                cube([digit_w+2.0, digit_h+2.0, bezel_th+0.2], center=true);

            // Deeper cavity for digit area (gives depth)
            translate([0, 0, body_z/2 - bezel_th - window_through/2])
                cube([digit_w+1.0, digit_h+1.0, window_through+0.2], center=true);
        }

        // Digit segments (slightly below top surface, inside window)
        translate([0, 0, body_z/2 - bezel_th - 0.7])
            color([0.9,0.9,0.9])
                seven_segment_digit(dW=digit_w, dH=digit_h, segW=seg_w, segT=0.9);

        // Pins on bottom
        translate([0, -body_y/2 + 3.0, -body_z/2])
            pin_grid_5x2(pitch_x=2.54, pitch_y=2.54, pin_d=0.6, pin_len=4.0, stand=0.7);
    }
}

// Top-level call (non-empty solid)
seven_segment_module();