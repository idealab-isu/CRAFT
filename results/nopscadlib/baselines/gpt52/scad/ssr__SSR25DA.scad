$fn=64;

module rounded_box(size=[10,10,10], r=2, center=true){
    x=size[0]; y=size[1]; z=size[2];
    rr = min(r, x/2, y/2, z/2);
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
    minkowski(){
        cube([x-2*rr, y-2*rr, z-2*rr], center=true);
        sphere(r=rr);
    }
}

module screw_hole(d=3.6, h=30){
    cylinder(d=d, h=h, center=true);
}

module terminal_block(w=18, d=12, h=12, pitch=5.08, n=2){
    union(){
        translate([0,0,h/2]) cube([w,d,h], center=true);
        for(i=[0:n-1]){
            x = (i-(n-1)/2)*pitch;
            translate([x,0,h*0.65]) cylinder(d=3.2, h=h*0.9, center=true);
        }
    }
}

module ssr_module(){
    L=63.0;
    W=45.0;
    H=23.0;

    base_r=2.0;

    hole_dx=52.0;
    hole_dy=34.0;
    hole_d=4.2;

    union(){
        difference(){
            rounded_box([L,W,H], r=base_r, center=true);

            for(sx=[-1,1], sy=[-1,1]){
                translate([sx*hole_dx/2, sy*hole_dy/2, 0])
                    screw_hole(d=hole_d, h=H+10);
            }

            translate([0,0,H*0.18])
                cube([L*0.78, W*0.62, H*0.55], center=true);

            translate([0,0,H*0.40])
                cube([L*0.55, W*0.40, H*0.35], center=true);
        }

        translate([0, W/2 - 6.5, -H/2 + 6.0])
            terminal_block(w=22, d=13, h=12, pitch=5.08, n=2);

        translate([0, -W/2 + 6.5, -H/2 + 6.0])
            terminal_block(w=22, d=13, h=12, pitch=5.08, n=2);

        translate([0,0,H/2 - 1.2])
            cube([L*0.70, W*0.30, 2.4], center=true);

        for(i=[-2:2]){
            translate([i*10.0, 0, -H/2 + 1.0])
                cube([2.0, W*0.85, 2.0], center=true);
        }
    }
}

ssr_module();