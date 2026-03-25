$fn=96;

bore1_d = 5.0;
bore2_d = 8.0;
od = 12.5;
len = 25.0;

split_z = 0.0;
clamp_gap = 1.2;
slit_w = 0.8;

screw_d = 3.0;
screw_head_d = 5.6;
screw_head_h = 2.2;
nut_flat = 5.5;
nut_thk = 2.6;

edge_margin = 3.0;
screw_z1 = -len/2 + edge_margin;
screw_z2 =  len/2 - edge_margin;

module hex_prism(flat=5.5, h=2.6){
    r = flat / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module clamp_screw_set(zpos){
    translate([0,0,zpos])
    rotate([0,90,0])
    union(){
        cylinder(h=od+6, d=screw_d, center=true);
        translate([-(od/2 + 1.6),0,0]) cylinder(h=screw_head_h, d=screw_head_d, center=false);
        translate([(od/2 - nut_thk),0,0]) hex_prism(flat=nut_flat, h=nut_thk);
    }
}

module coupling_body(){
    difference(){
        cylinder(h=len, d=od, center=true);

        translate([0,0,-len/4]) cylinder(h=len/2 + 0.2, d=bore1_d, center=true);
        translate([0,0, len/4]) cylinder(h=len/2 + 0.2, d=bore2_d, center=true);

        translate([0,0,split_z]) cylinder(h=0.6, d=od+0.4, center=true);

        translate([0,0,0]) cube([od+2, clamp_gap, len+2], center=true);

        translate([0,0,-len/4]) cube([od+2, slit_w, len/2+2], center=true);
        translate([0,0, len/4]) cube([od+2, slit_w, len/2+2], center=true);

        clamp_screw_set(screw_z1);
        clamp_screw_set(screw_z2);
    }
}

coupling_body();