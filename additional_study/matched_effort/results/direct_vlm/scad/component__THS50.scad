$fn=96;

// Generic parametric component: base plate with rounded corners, central boss, and 4 mounting holes.
module component(
    base_x=80,
    base_y=50,
    base_z=6,
    corner_r=6,

    boss_d=26,
    boss_h=14,
    boss_hole_d=10,

    hole_d=4.2,
    hole_inset_x=10,
    hole_inset_y=10,

    chamfer=0.8
){
    module rounded_plate(x,y,z,r){
        linear_extrude(height=z)
            offset(r=r)
                square([x-2*r, y-2*r], center=true);
    }

    module chamfered_cylinder(d,h,c){
        // Simple top chamfer via hull between two cylinders
        hull(){
            cylinder(d=d, h=max(0.01,h-c));
            translate([0,0,max(0.01,h-c)]) cylinder(d=max(0.01,d-2*c), h=max(0.01,c));
        }
    }

    difference(){
        union(){
            // Base
            rounded_plate(base_x, base_y, base_z, corner_r);

            // Boss
            translate([0,0,base_z])
                chamfered_cylinder(boss_d, boss_h, chamfer);
        }

        // Boss through-hole
        translate([0,0,-1])
            cylinder(d=boss_hole_d, h=base_z+boss_h+2);

        // 4 mounting holes
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(base_x/2 - hole_inset_x), sy*(base_y/2 - hole_inset_y), -1])
                cylinder(d=hole_d, h=base_z+2);
        }

        // Light underside relief pocket (optional aesthetic/weight reduction)
        translate([0,0,1.2])
            rounded_plate(base_x-14, base_y-14, base_z, max(0,corner_r-3));
    }
}

component();