$fn=64;

strip_len = 300;
strip_w   = 12;
strip_h   = 3;

diffuser_h = 1.2;
diffuser_w = 10;

endcap_len = 6;

mount_hole_d = 3.2;
mount_hole_head_d = 6.5;
mount_hole_head_h = 1.6;

module rounded_box(l, w, h, r){
    r2 = min(r, w/2, h/2);
    translate([-l/2, -w/2, -h/2])
    hull(){
        for (yy=[r2, w-r2])
            for (zz=[r2, h-r2])
                translate([0, yy, zz]) sphere(r=r2);
        for (yy=[r2, w-r2])
            for (zz=[r2, h-r2])
                translate([l, yy, zz]) sphere(r=r2);
    }
}

module mount_hole(){
    union(){
        cylinder(h=strip_h+0.2, d=mount_hole_d, center=true);
        translate([0,0, strip_h/2 - mount_hole_head_h/2])
            cylinder(h=mount_hole_head_h+0.2, d=mount_hole_head_d, center=true);
    }
}

module endcap(){
    difference(){
        rounded_box(endcap_len, strip_w, strip_h, 1.2);
        translate([0,0,0])
            rounded_box(endcap_len-1.2, strip_w-1.2, strip_h-0.6, 0.8);
    }
}

module strip_body(){
    difference(){
        union(){
            rounded_box(strip_len, strip_w, strip_h, 1.2);
            translate([0,0, (strip_h/2 - diffuser_h/2)])
                rounded_box(strip_len-2*endcap_len, diffuser_w, diffuser_h, 0.6);
            translate([-(strip_len/2 - endcap_len/2),0,0]) endcap();
            translate([ (strip_len/2 - endcap_len/2),0,0]) endcap();
        }

        // underside cable channel
        translate([0,0, -(strip_h/2 - 0.9)])
            rounded_box(strip_len-2*endcap_len, 6, 1.8, 0.9);

        // mounting holes (3)
        for (xpos=[-strip_len/3, 0, strip_len/3])
            translate([xpos, 0, 0]) mount_hole();
    }
}

strip_body();