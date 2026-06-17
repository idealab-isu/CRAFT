$fn=96;

outer_d = 19.5;
height = 78.5;

inner_d_main = 14.2;

gap_w = 2.2;

notch_len = 12.0;
notch_depth = 0.6;
notch_count = 4;
notch_pitch = 2.0;
notch_width = 1.2;

module c_sleeve_body(od, id, h, gapw){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.4, center=true);
        translate([0,0,0])
            cube([od+2, gapw, h+0.6], center=true);
    }
}

module internal_notches(id, h, gapw, len, depth, count, pitch, w){
    for(i=[0:count-1]){
        zpos = -h/2 + (i+0.5)*pitch;
        translate([0,0,zpos])
            difference(){
                cylinder(d=id+2*depth, h=w, center=true);
                cylinder(d=id, h=w+0.2, center=true);
                cube([id+2*depth+4, gapw+0.6, w+0.4], center=true);
            }
    }
    translate([0,0,-h/2 + len/2])
        difference(){
            cylinder(d=id+2*depth, h=len, center=true);
            cylinder(d=id, h=len+0.2, center=true);
            cube([id+2*depth+4, gapw+0.6, len+0.4], center=true);
        }
}

difference(){
    c_sleeve_body(outer_d, inner_d_main, height, gap_w);
    internal_notches(inner_d_main, height, gap_w, notch_len, notch_depth, notch_count, notch_pitch, notch_width);
}