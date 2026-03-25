$fn=64;

L = 9.0;   // overall length (elongated axis, X)
W = 5.4;   // overall width (Y)
H = 1.4;   // overall height (Z)

base_t = 0.55;
base_r = 0.9;

spine_w = 1.35;
spine_h = 0.55;
spine_r = 0.45;

cradle_outer_r = 1.05;
cradle_inner_r = 0.65;
cradle_w = 2.6;
cradle_x = 2.2;
cradle_z = base_t + 0.35;

nub_r = 0.45;
nub_len = 0.55;

module rounded_plate(l, w, t, r){
    linear_extrude(height=t)
        offset(r=r)
            square([l-2*r, w-2*r], center=true);
}

module rounded_spine(l, w, h, r){
    translate([0,0,base_t])
        linear_extrude(height=h)
            offset(r=r)
                square([l-2*r, w-2*r], center=true);
}

module u_cradle(){
    translate([cradle_x, 0, cradle_z])
    rotate([0,90,0])
    difference(){
        rotate_extrude(angle=180, convexity=10)
            translate([cradle_outer_r,0,0])
                square([0.001, cradle_w], center=true);
        rotate_extrude(angle=180, convexity=10)
            translate([cradle_inner_r,0,0])
                square([0.001, cradle_w+0.2], center=true);
    }
}

module end_nubs(){
    translate([cradle_x, 0, cradle_z])
    rotate([0,90,0]){
        translate([0,  cradle_w/2, 0])
            cylinder(h=nub_len, r=nub_r, center=false);
        translate([0, -cradle_w/2, 0])
            cylinder(h=nub_len, r=nub_r, center=false);
    }
}

module clip(){
    union(){
        rounded_plate(L, W, base_t, base_r);
        rounded_spine(L*0.78, spine_w, spine_h, spine_r);
        u_cradle();
        end_nubs();
    }
}

clip();