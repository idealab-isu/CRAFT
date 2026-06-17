$fn=64;

module mounting_hole(h=12, d=4.2, cb_d=8.5, cb_h=2.5){
    union(){
        cylinder(h=h, d=d, center=true);
        translate([0,0,(h/2)-(cb_h/2)]) cylinder(h=cb_h, d=cb_d, center=true);
    }
}

module rounded_plate(size=[80,50,6], r=6){
    x=size[0]; y=size[1]; z=size[2];
    linear_extrude(height=z, center=true)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module rib(len=60, thick=4, height=18){
    translate([0,0,0])
        linear_extrude(height=thick, center=true)
            polygon(points=[
                [-len/2, 0],
                [ len/2, 0],
                [ len/2-8, height],
                [-len/2+8, height]
            ]);
}

module component(){
    base_x=80;
    base_y=50;
    base_z=6;
    corner_r=6;

    boss_d=18;
    boss_h=10;

    hole_d=4.2;
    cb_d=8.5;
    cb_h=2.5;

    hole_x=30;
    hole_y=17;

    union(){
        difference(){
            union(){
                rounded_plate([base_x, base_y, base_z], corner_r);

                for (sx=[-1,1], sy=[-1,1]){
                    translate([sx*hole_x, sy*hole_y, (base_z/2)+(boss_h/2)])
                        cylinder(h=boss_h, d=boss_d, center=true);
                }

                translate([0,0,(base_z/2)+2])
                    rotate([90,0,0])
                        rib(len=60, thick=4, height=18);
            }

            for (sx=[-1,1], sy=[-1,1]){
                translate([sx*hole_x, sy*hole_y, 0])
                    mounting_hole(h=base_z+boss_h+2, d=hole_d, cb_d=cb_d, cb_h=cb_h);
            }

            translate([0,0,0])
                cube([40,20,base_z+2], center=true);
        }

        translate([0,0,(base_z/2)+1.5])
            cylinder(h=3, d=22, center=true);
    }
}

component();