$fn=64;

module mounting_hole(h=12, d=4.2, cs_d=8.5, cs_h=2.2){
    union(){
        cylinder(h=h, d=d);
        translate([0,0,h-cs_h]) cylinder(h=cs_h, d1=cs_d, d2=d);
    }
}

module rounded_plate(size=[80,50,6], r=6){
    x=size[0]; y=size[1]; z=size[2];
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module standoff(h=10, od=10, id=4.2){
    difference(){
        cylinder(h=h, d=od);
        translate([0,0,-0.2]) cylinder(h=h+0.4, d=id);
    }
}

module component(){
    base_x=80;
    base_y=50;
    base_z=6;
    corner_r=6;

    boss_h=10;
    boss_od=10;
    hole_d=4.2;

    hole_x=30;
    hole_y=17;

    rib_t=4;
    rib_h=12;

    post_spacing=24;
    post_d=8;
    post_h=18;
    post_hole_d=3.2;

    difference(){
        union(){
            rounded_plate([base_x, base_y, base_z], corner_r);

            for (sx=[-1,1], sy=[-1,1]){
                translate([sx*hole_x, sy*hole_y, base_z])
                    standoff(h=boss_h, od=boss_od, id=hole_d);
            }

            translate([0,0,base_z])
                cylinder(h=18, d=26);

            translate([0,0,base_z+18])
                cylinder(h=6, d1=26, d2=18);

            for (a=[0,90]){
                rotate([0,0,a])
                    translate([0,0,base_z])
                        linear_extrude(height=rib_h)
                            polygon(points=[
                                [-rib_t/2, 0],
                                [ rib_t/2, 0],
                                [ rib_t/2, 22],
                                [-rib_t/2, 22]
                            ]);
            }

            for (sx=[-1,1], sy=[-1,1]){
                translate([sx*post_spacing/2, sy*post_spacing/2, base_z])
                    cylinder(h=post_h, d=post_d);
            }
        }

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*hole_x, sy*hole_y, -0.2])
                mounting_hole(h=base_z+boss_h+0.4, d=hole_d, cs_d=8.5, cs_h=2.2);
        }

        translate([0,0,base_z-0.2])
            cylinder(h=30, d=12);

        translate([0,0,base_z+10])
            rotate([90,0,0])
                cylinder(h=base_y+2, d=6, center=true);

        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*post_spacing/2, sy*post_spacing/2, base_z-0.2])
                cylinder(h=post_h+0.4, d=post_hole_d);
        }

        translate([0,0,-0.2])
            linear_extrude(height=base_z+0.4)
                offset(r=1.5)
                    square([base_x-10, base_y-10], center=true);
    }
}

component();