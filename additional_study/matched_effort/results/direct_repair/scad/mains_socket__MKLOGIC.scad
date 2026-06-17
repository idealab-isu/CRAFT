$fn=96;

// ---------- Parameters ----------
plate_w = 146;
plate_h = 86;
plate_t = 3.2;

corner_r = 6;

backbox_depth = 25;
backbox_margin = 6;

face_bevel = 0.8;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

module rounded_box(w,h,t,r){
    linear_extrude(height=t)
        rounded_rect_2d(w,h,r);
}

module countersunk_hole(thru_d=3.6, sink_d=7.2, sink_h=1.6, t=plate_t){
    // Through + countersink from front (top)
    union(){
        cylinder(h=t+0.4, d=thru_d, center=false);
        translate([0,0,t-sink_h])
            cylinder(h=sink_h+0.4, d1=sink_d, d2=thru_d, center=false);
    }
}

module rocker_switch(w=22, h=30, depth=2.2, bezel=1.2){
    // Simple raised bezel + recessed rocker
    // Bezel
    translate([0,0,plate_t-0.01])
        linear_extrude(height=bezel)
            offset(r=1.2)
                square([w,h], center=true);
    // Rocker recess
    translate([0,0,plate_t-0.01])
        linear_extrude(height=depth)
            offset(r=1.0)
                square([w-4,h-4], center=true);
}

module socket_aperture(){
    // Approx UK socket front apertures (stylized)
    // Earth (top)
    translate([0, 12, -0.2]) linear_extrude(height=plate_t+0.6)
        offset(r=1.2) square([8, 14], center=true);
    // Live/Neutral (bottom left/right)
    translate([-12, -10, -0.2]) linear_extrude(height=plate_t+0.6)
        offset(r=1.2) square([8, 18], center=true);
    translate([ 12, -10, -0.2]) linear_extrude(height=plate_t+0.6)
        offset(r=1.2) square([8, 18], center=true);
}

module socket_bezel(w=52,h=52,raise=1.2){
    translate([0,0,plate_t-0.01])
        linear_extrude(height=raise)
            offset(r=2.0)
                square([w,h], center=true);
}

module neon_indicator(d=5.0, depth=1.2){
    translate([0,0,plate_t-0.01])
        cylinder(h=depth, d=d, center=false);
}

module backbox(){
    // Simple rear box volume (not hollowed), for visual depth
    bw = plate_w - 2*backbox_margin;
    bh = plate_h - 2*backbox_margin;
    translate([0,0,-backbox_depth])
        rounded_box(bw,bh,backbox_depth, max(2,corner_r-2));
}

// ---------- Model ----------
difference(){
    union(){
        // Faceplate with slight front bevel via two-layer hull
        hull(){
            translate([0,0,0])
                rounded_box(plate_w, plate_h, 0.6, corner_r);
            translate([0,0,plate_t])
                rounded_box(plate_w-2*face_bevel, plate_h-2*face_bevel, 0.6, max(0.1,corner_r-face_bevel));
        }

        // Raised bezels for two sockets
        translate([-36,0,0]) socket_bezel();
        translate([ 36,0,0]) socket_bezel();

        // Switch bezel + rocker recess (stylized)
        translate([0, 0, 0]) rocker_switch();

        // Neon indicator (small lens)
        translate([0, 26, 0]) neon_indicator();

        // Rear backbox
        backbox();
    }

    // Screw holes (BS 4662 typical centers ~120mm apart horizontally)
    for(x=[-60,60]){
        translate([x,0,0])
            countersunk_hole(thru_d=3.8, sink_d=7.6, sink_h=1.8, t=plate_t+0.6);
    }

    // Socket apertures
    translate([-36,0,0]) socket_aperture();
    translate([ 36,0,0]) socket_aperture();

    // Switch cutout (through)
    translate([0,0,-0.2])
        linear_extrude(height=plate_t+1.0)
            offset(r=1.2)
                square([18,26], center=true);

    // Neon indicator hole (through shallow)
    translate([0,26,-0.2])
        cylinder(h=plate_t+1.0, d=3.2, center=false);
}