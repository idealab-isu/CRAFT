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

module screw_hole(d=3.6, h=50){
    cylinder(d=d, h=h, center=true);
}

module terminal_block(w=18, d=12, h=14, pitch=5.08, holes=2){
    difference(){
        translate([0,0,h/2]) cube([w,d,h], center=true);
        for(i=[0:holes-1]){
            x = (i-(holes-1)/2)*pitch;
            translate([x,0,h*0.55]) rotate([90,0,0]) cylinder(d=3.2, h=d+2, center=true);
        }
    }
}

module ssr_module(L=58.0, W=45.0, H=33.0){
    base_th=4.0;
    body_h=H-base_th;

    hole_dx=46.0;
    hole_dy=33.0;
    hole_d=4.2;

    union(){
        difference(){
            union(){
                translate([0,0,-H/2 + base_th/2])
                    rounded_box([L,W,base_th], r=2.0, center=true);

                translate([0,0,-H/2 + base_th + body_h/2])
                    rounded_box([L-2.0, W-2.0, body_h], r=2.5, center=true);

                translate([0,0,H/2 - 1.2])
                    rounded_box([L-6.0, W-6.0, 2.4], r=1.5, center=true);
            }

            for(sx=[-1,1], sy=[-1,1]){
                translate([sx*hole_dx/2, sy*hole_dy/2, -H/2 + base_th/2])
                    screw_hole(d=hole_d, h=H+10);
            }

            translate([0,0,-H/2 + base_th + body_h*0.55])
                rounded_box([L-10.0, W-10.0, body_h*0.55], r=2.0, center=true);
        }

        translate([0, W/2 - 7.0, H/2 - 7.0])
            terminal_block(w=22, d=12, h=14, pitch=5.08, holes=2);

        translate([0, -W/2 + 7.0, H/2 - 7.0])
            terminal_block(w=22, d=12, h=14, pitch=5.08, holes=2);

        for(sx=[-1,1]){
            translate([sx*(L/2 - 6.0), 0, -H/2 + base_th + 6.0])
                rotate([0,90,0]) cylinder(d=6.0, h=3.0, center=true);
        }
    }
}

ssr_module(58.0,45.0,33.0);