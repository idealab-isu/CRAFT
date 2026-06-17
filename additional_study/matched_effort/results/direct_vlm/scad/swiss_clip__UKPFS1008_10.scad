$fn=96;

// Swiss-style spring clip (single connected solid)
// Units: mm

// ---------- Parameters ----------
clip_len = 70;
clip_w   = 18;
clip_t   = 2.2;

jaw_gap  = 6.0;     // visual gap between jaws
jaw_len  = 18;      // length of jaw region
tip_round= 2.0;

hinge_r    = 6.5;   // outer radius of hinge loop
hinge_wall = 2.2;   // thickness around hinge
hinge_w    = clip_w;

spring_clear = 0.6; // visual slot in hinge

handle_len = clip_len - jaw_len - hinge_r*1.2;

rib_h = 0.8;
rib_w = 1.2;
rib_pitch = 4.0;

// Connectivity / printability
overlap = 0.8;      // intentional overlap to guarantee unions
bridge_len = 22;    // bridge length from hinge toward jaws

// Swiss-clip defining features
pin_r = 1.6;        // hinge pin radius (visual)
pin_head_r = 3.2;   // pin head radius (visual)
pin_head_t = 1.2;   // pin head thickness
lever_t = 2.0;      // small cam/lever thickness
lever_w = 7.0;      // lever width (Y)
lever_len = 10.0;   // lever length (X)
jaw_tooth_h = 0.9;  // serration height
jaw_tooth_pitch = 2.2;
jaw_tooth_w = clip_w*0.62;

// ---------- Helpers ----------
module rounded_box(l,w,h,r){
    r2 = min(r, min(l,w)/2);
    hull(){
        for(x=[-l/2+r2, l/2-r2])
            for(y=[-w/2+r2, w/2-r2])
                translate([x,y,0]) cylinder(r=r2,h=h, center=false);
    }
}

module ribbed_surface(l,w,h,dir=1){
    union(){
        children();
        if(dir==1){
            for(y=[-w/2+1.5 : rib_pitch : w/2-1.5])
                translate([0,y,h-0.01]) cube([l-6,rib_w,rib_h], center=true);
        } else {
            for(x=[-l/2+1.5 : rib_pitch : l/2-1.5])
                translate([x,0,h-0.01]) cube([rib_w,w-6,rib_h], center=true);
        }
    }
}

module handle_half(sign=1){
    zoff = sign*(jaw_gap/2 + clip_t/2);
    x_base = -(clip_len/2 - jaw_len - hinge_r*0.9);

    translate([0,0,zoff])
    ribbed_surface(handle_len, clip_w, clip_t, dir=1)
    hull(){
        translate([x_base + handle_len*0.15,0,0])
            rounded_box(handle_len*0.55, clip_w, clip_t, 2.2);
        translate([x_base + handle_len*0.85,0,0])
            rounded_box(handle_len*0.45, clip_w*0.95, clip_t, 2.2);
    }
}

module jaw_serrations(sign=1){
    // Serrations on inner jaw faces near the tip (classic clip feature)
    zoff = sign*(jaw_gap/2 + clip_t/2);
    x_tip = clip_len/2;
    x0 = x_tip - jaw_len*0.78;
    x1 = x_tip - jaw_len*0.18;
    n = max(3, floor((x1-x0)/jaw_tooth_pitch));

    for(i=[0:n-1]){
        xi = x0 + (i+0.5)*(x1-x0)/n;
        // Place tooth on inner face: toward the gap center
        z_tooth = zoff - sign*(clip_t/2 - jaw_tooth_h/2 - 0.05);
        translate([xi, 0, z_tooth])
            cube([jaw_tooth_pitch*0.75, jaw_tooth_w, jaw_tooth_h], center=true);
    }
}

module jaw_half(sign=1){
    zoff = sign*(jaw_gap/2 + clip_t/2);

    translate([clip_len/2 - jaw_len/2,0,zoff])
    hull(){
        translate([-jaw_len*0.45,0,0]) rounded_box(jaw_len*0.35, clip_w, clip_t, 2.0);
        translate([ jaw_len*0.45,0,0]) rounded_box(jaw_len*0.25, clip_w*0.85, clip_t, tip_round);
    }

    // Inner tooth near tip (small)
    translate([clip_len/2 - 4.5,0,zoff - sign*(clip_t*0.15)])
        cube([3.5, clip_w*0.55, clip_t*0.35], center=true);

    jaw_serrations(sign);
}

module hinge_loop(){
    // Positioned near the back (negative X)
    x0 = -(clip_len/2 - hinge_r*1.05);

    difference(){
        translate([x0,0,0])
            rotate([0,90,0])
                cylinder(r=hinge_r, h=hinge_w, center=true);

        translate([x0,0,0])
            rotate([0,90,0])
                cylinder(r=hinge_r-hinge_wall, h=hinge_w+0.6, center=true);

        // Slot to suggest two leaves (visual only)
        translate([x0,0,0])
            cube([hinge_w+1, clip_w+2, spring_clear], center=true);
    }
}

module hinge_pin_and_heads(){
    // Adds recognizable "Swiss clip" hinge pin with heads, connected to hinge loop
    x0 = -(clip_len/2 - hinge_r*1.05);

    union(){
        // Pin through hinge (along X)
        translate([x0,0,0])
            rotate([0,90,0])
                cylinder(r=pin_r, h=hinge_w + 2*pin_head_t - 0.2, center=true);

        // Heads on both sides (overlap into hinge by overlap)
        for(s=[-1,1]){
            y_head = s*(hinge_w/2 + pin_head_t/2 - overlap);
            translate([x0, y_head, 0])
                rotate([90,0,0])
                    cylinder(r=pin_head_r, h=pin_head_t, center=true);
        }
    }
}

module cam_lever(){
    // Small cam/lever near hinge (typical attachment/actuation detail)
    x_hinge = -(clip_len/2 - hinge_r*1.05);

    // Place lever on one side of hinge, overlapping into hinge body
    y0 = (clip_w/2 - lever_w/2) - overlap;
    x0 = x_hinge + hinge_r*0.35; // slightly forward of hinge center
    z0 = 0;

    // Lever body + rounded end
    union(){
        translate([x0 + lever_len/2 - overlap, y0, z0])
            rounded_box(lever_len, lever_w, lever_t, 1.2);

        // Rounded knob at end
        translate([x0 + lever_len - overlap, y0, z0])
            cylinder(r=lever_w*0.35, h=lever_t, center=true);
    }
}

module neck_to_hinge(sign=1){
    zoff = sign*(jaw_gap/2 + clip_t/2);
    x_hinge = -(clip_len/2 - hinge_r*1.05);
    x_neck0 = x_hinge + hinge_r*0.55;
    x_neck1 = x_neck0 + 10;

    translate([0,0,zoff])
    hull(){
        translate([x_neck1,0,0]) rounded_box(10, clip_w*0.95, clip_t, 2.0);
        translate([x_neck0,0,0]) rounded_box(6,  clip_w*0.85, clip_t, 2.0);
    }
}

module internal_bridge(){
    // Makes the clip ONE connected solid while preserving the "clip" look.
    // Bridge sits inside the jaw gap and overlaps both halves.
    x_hinge = -(clip_len/2 - hinge_r*1.05);
    x0 = x_hinge + hinge_r*0.35;                 // start near hinge
    x1 = x0 + bridge_len;                        // extend toward jaws
    x_mid = (x0 + x1)/2;

    // Thickness in Z: slightly larger than jaw_gap to overlap into both halves
    z_th = jaw_gap + clip_t + 2*overlap;

    // Width in Y: narrower than clip_w so it reads as internal spring/bridge
    y_w = clip_w*0.45;

    hull(){
        translate([x0,0,0]) rounded_box(6, y_w, z_th, 1.6);
        translate([x_mid,0,0]) rounded_box(10, y_w, z_th, 1.6);
        translate([x1,0,0]) rounded_box(6, y_w, z_th, 1.6);
    }
}

module clip(){
    union(){
        // Upper and lower arms (jaws + handles)
        for(s=[-1,1]){
            handle_half(s);
            neck_to_hinge(s);
            jaw_half(s);
        }

        // Hinge loop + pin + lever (recognizable swiss-clip features)
        hinge_loop();
        hinge_pin_and_heads();
        cam_lever();

        // Internal bridge to ensure ONE connected solid (no floating parts)
        internal_bridge();

        // Small external bridge near hinge for robustness (overlaps by design)
        x0 = -(clip_len/2 - hinge_r*0.35);
        translate([x0,0,0])
            rounded_box(6, clip_w*0.75, clip_t*0.9 + 2*overlap, 1.6);
    }
}

// ---------- Render ----------
clip();