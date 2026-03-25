$fn=96;

L = 140;
W = 48;
T = 8;

ear_r = 10;
ear_ch = 6;

tab_len = 18;
tab_w = 14;
tab_t = 4;

boss_h = 14;
boss_r = 12;
boss_facets = 12;

hole_d = 4.2;
small_d = 3.2;

diamond_size = 10;
diamond_th = T + 2;

module rounded_plate(l, w, t, r){
    linear_extrude(height=t, center=true)
        offset(r=r)
            square([l-2*r, w-2*r], center=true);
}

module chamfer_ear_2d(r, ch){
    difference(){
        circle(r=r);
        translate([r-ch, r-ch]) square([2*r, 2*r], center=false);
    }
}

module ear_pair_2d(w, r, ch){
    union(){
        translate([0,  w/2 - r]) chamfer_ear_2d(r, ch);
        translate([0, -w/2 + r]) mirror([0,1,0]) chamfer_ear_2d(r, ch);
    }
}

module base_body(){
    union(){
        rounded_plate(L, W, T, 4);

        linear_extrude(height=T, center=true)
            union(){
                translate([ L/2 - ear_r, 0]) ear_pair_2d(W, ear_r, ear_ch);
                translate([-L/2 + ear_r, 0]) mirror([1,0,0]) ear_pair_2d(W, ear_r, ear_ch);
            }

        translate([ L/2 + tab_len/2, 0, 0])
            cube([tab_len, tab_w, tab_t], center=true);

        translate([-L/2 - tab_len/2, 0, 0])
            cube([tab_len, tab_w, tab_t], center=true);
    }
}

module diamond_hole(size, h){
    rotate([0,0,45])
        linear_extrude(height=h, center=true)
            square([size, size], center=true);
}

module teardrop_hole(d, h){
    union(){
        cylinder(h=h, d=d, center=true);
        translate([0, d*0.55, 0])
            cylinder(h=h, d=d*0.55, center=true);
    }
}

module hole_pattern(){
    union(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(L*0.33), sy*(W*0.28), 0])
                cylinder(h=T+4, d=hole_d, center=true);

        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(L*0.18), sy*(W*0.18), 0])
                cylinder(h=T+4, d=small_d, center=true);

        for (sx=[-1,1])
            translate([sx*(L*0.22), 0, 0])
                diamond_hole(diamond_size, diamond_th);

        for (sy=[-1,1])
            translate([0, sy*(W*0.22), 0])
                diamond_hole(diamond_size*0.9, diamond_th);

        for (sx=[-1,1])
            translate([sx*(L/2 + tab_len*0.35), 0, 0])
                teardrop_hole(3.6, T+4);

        translate([0,0,0])
            cylinder(h=T+4, d=6.5, center=true);
    }
}

module faceted_boss(){
    translate([0,0, T/2 + boss_h/2])
        cylinder(h=boss_h, r=boss_r, center=true, $fn=boss_facets);
}

difference(){
    union(){
        base_body();
        faceted_boss();
    }
    hole_pattern();
    translate([0,0, T/2 + boss_h/2])
        cylinder(h=boss_h+2, d=6.2, center=true, $fn=64);
}