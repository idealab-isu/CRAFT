$fn=96;

plate_w = 0.1;
plate_t = 0.0;

boss_d = 0.06;
boss_h = 0.0;

hex_af = 0.02;
hex_h = 0.0;

hole_d = 0.01;

concave_r = 0.06;
concave_offset = 0.03;

module concave_plate_2d(w, r, off){
    difference(){
        square([w,w], center=true);
        for(a=[0,90,180,270]){
            rotate(a)
                translate([w/2 + off, 0])
                    circle(r=r);
        }
    }
}

module corner_holes_2d(w, d, inset){
    for(sx=[-1,1], sy=[-1,1]){
        translate([sx*(w/2 - inset), sy*(w/2 - inset)])
            circle(d=d);
    }
}

module hex_prism(af, h){
    r = af / sqrt(3);
    cylinder(h=h, r=r, $fn=6);
}

module mounting_plate(){
    difference(){
        linear_extrude(height=plate_t, center=true)
            concave_plate_2d(plate_w, concave_r, concave_offset);
        linear_extrude(height=plate_t + 0.02, center=true)
            corner_holes_2d(plate_w, hole_d, inset=0.015);
    }
}

module boss(){
    cylinder(h=boss_h, d=boss_d, center=true);
}

module drive_hex(){
    translate([0,0,(boss_h/2) + (hex_h/2)])
        hex_prism(hex_af, hex_h);
}

union(){
    mounting_plate();
    boss();
    drive_hex();
}