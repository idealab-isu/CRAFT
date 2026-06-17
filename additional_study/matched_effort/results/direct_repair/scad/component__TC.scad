$fn=96;

// Generic parametric component: base plate with rounded corners, central boss, and 4 mounting holes.
module component(
    base_x=80,
    base_y=50,
    base_z=6,
    corner_r=6,

    boss_d=28,
    boss_h=14,
    boss_hole_d=10,

    hole_d=4.2,
    hole_inset_x=10,
    hole_inset_y=10,

    chamfer=0.8
){
    module rounded_rect_2d(x,y,r){
        r2 = min(r, min(x,y)/2);
        hull(){
            translate([ r2, r2]) circle(r=r2);
            translate([ x-r2, r2]) circle(r=r2);
            translate([ r2, y-r2]) circle(r=r2);
            translate([ x-r2, y-r2]) circle(r=r2);
        }
    }

    module chamfered_cylinder(d,h,c){
        // Simple top chamfer via two stacked cylinders
        c2 = min(c, h/2);
        union(){
            cylinder(d=d, h=h-c2);
            translate([0,0,h-c2]) cylinder(d1=d, d2=max(d-2*c2, 0.01), h=c2);
        }
    }

    difference(){
        union(){
            // Base
            linear_extrude(height=base_z)
                translate([-base_x/2, -base_y/2])
                    rounded_rect_2d(base_x, base_y, corner_r);

            // Central boss
            translate([0,0,base_z])
                chamfered_cylinder(d=boss_d, h=boss_h, c=chamfer);
        }

        // Boss through-hole
        translate([0,0,-1])
            cylinder(d=boss_hole_d, h=base_z+boss_h+2);

        // 4 mounting holes
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(base_x/2 - hole_inset_x), sy*(base_y/2 - hole_inset_y), -1])
                cylinder(d=hole_d, h=base_z+2);
        }
    }
}

component();