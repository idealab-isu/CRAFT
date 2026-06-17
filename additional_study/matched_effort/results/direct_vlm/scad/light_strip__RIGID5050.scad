$fn=96;

// Rigid light strip (diffuser bar + backing + end caps + mounting holes)

strip_len = 300;
strip_w   = 18;
strip_h   = 8;

back_th   = 2.2;
diff_th   = strip_h - back_th;

cap_len   = 6;

hole_d    = 3.4;
hole_head_d = 6.8;
hole_head_h = 1.6;

hole_margin = 18;
hole_spacing = 90;

led_channel_w = 10;
led_channel_d = 1.2;

module rounded_box(l, w, h, r){
    r2 = min(r, w/2, h/2);
    translate([0,0,0])
    linear_extrude(height=l)
        offset(r=r2)
            square([w-2*r2, h-2*r2], center=true);
}

module body(){
    // Main bar with rounded edges
    // Build as extrusion along X: cross-section in YZ plane
    translate([0,0,0])
    rotate([0,90,0])
        rounded_box(strip_len, strip_w, strip_h, r=2.2);
}

module diffuser(){
    // Slightly domed diffuser on top
    // Use hull between two rounded rectangles to create gentle dome
    translate([0,0,back_th])
    rotate([0,90,0])
    hull(){
        translate([0,0,0])
            rounded_box(strip_len, strip_w, diff_th*0.75, r=2.0);
        translate([0,0,diff_th*0.55])
            rounded_box(strip_len, strip_w*0.86, diff_th*0.35, r=1.6);
    }
}

module backing(){
    // Flat backing plate
    translate([0,0,0])
    rotate([0,90,0])
        rounded_box(strip_len, strip_w, back_th, r=2.2);
}

module end_caps(){
    // Slightly thicker end caps
    for (sx=[-1,1]){
        translate([sx*(strip_len/2 - cap_len/2),0,0])
        rotate([0,90,0])
            rounded_box(cap_len, strip_w, strip_h, r=2.2);
    }
}

module mounting_holes(){
    // Through holes + shallow countersink/counterbore on back side
    // Place along length
    n = floor((strip_len - 2*hole_margin)/hole_spacing) + 1;
    for (i=[0:n-1]){
        x = -strip_len/2 + hole_margin + i*hole_spacing;
        // Through hole
        translate([x,0,0])
            rotate([90,0,0])
                cylinder(d=hole_d, h=strip_w+2, center=true);
        // Counterbore on back (z=0 side)
        translate([x,0,back_th/2])
            rotate([90,0,0])
                cylinder(d=hole_head_d, h=hole_head_h, center=true);
    }
}

module led_channel(){
    // Shallow channel on backing for LED tape
    translate([0,0,back_th - led_channel_d])
    rotate([0,90,0])
        rounded_box(strip_len-2*cap_len, led_channel_w, led_channel_d, r=1.0);
}

difference(){
    union(){
        // Base body
        body();
        // Diffuser (slightly translucent look via color)
        color([1,1,1,0.35]) diffuser();
        // Backing (opaque)
        color([0.9,0.9,0.9,1]) backing();
        // End caps
        color([0.85,0.85,0.85,1]) end_caps();
    }
    // Cut LED channel
    led_channel();
    // Cut mounting holes
    mounting_holes();
}