$fn=64;

module mounting_hole(h=12, d=4.2, cb_d=8.5, cb_h=2.5){
    union(){
        cylinder(h=h, d=d, center=true);
        translate([0,0,h/2 - cb_h/2]) cylinder(h=cb_h, d=cb_d, center=true);
    }
}

module standoff(h=10, od=10, id=4.2){
    difference(){
        cylinder(h=h, d=od, center=true);
        cylinder(h=h+0.2, d=id, center=true);
    }
}

module base_plate(x=80, y=50, z=6, r=6){
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(h=z, r=r, center=true);
    }
}

module rib(len=60, thick=4, height=18){
    translate([0,0,height/2])
        linear_extrude(height=height, center=true)
            polygon(points=[
                [-len/2, 0],
                [ len/2, 0],
                [ len/2-8, thick],
                [-len/2+8, thick]
            ]);
}

module component(){
    plate_x=80;
    plate_y=50;
    plate_z=6;
    corner_r=6;

    hole_dx=30;
    hole_dy=18;

    boss_h=10;
    boss_od=12;
    hole_d=4.2;

    rib_len=62;
    rib_thick=4;
    rib_h=18;

    difference(){
        union(){
            base_plate(plate_x, plate_y, plate_z, corner_r);

            for (sx=[-1,1], sy=[-1,1])
                translate([sx*hole_dx, sy*hole_dy, (plate_z/2 + boss_h/2)])
                    standoff(h=boss_h, od=boss_od, id=hole_d);

            translate([0,0,plate_z/2])
                rib(len=rib_len, thick=rib_thick, height=rib_h);

            rotate([0,0,90])
                translate([0,0,plate_z/2])
                    rib(len=rib_len, thick=rib_thick, height=rib_h);
        }

        for (sx=[-1,1], sy=[-1,1])
            translate([sx*hole_dx, sy*hole_dy, 0])
                mounting_hole(h=plate_z + boss_h + 2, d=hole_d, cb_d=8.5, cb_h=2.5);

        translate([0,0,0])
            cylinder(h=plate_z+0.2, d=18, center=true);
    }
}

component();