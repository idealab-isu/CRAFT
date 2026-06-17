$fn = 96;

// Generic parametric component: base plate with rounded corners,
// central boss, through holes, and a side cable slot.

module rounded_plate(size=[80,50,6], r=6){
    x=size[0]; y=size[1]; z=size[2];
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module component(){
    base = [90, 60, 6];
    corner_r = 8;

    boss_d = 28;
    boss_h = 14;
    bore_d = 10;

    hole_d = 5.2;
    hole_inset = [32, 20]; // from center in x/y

    slot = [22, 10, 8]; // x,y,z
    slot_offset = [base[0]/2 - 10, 0, base[2]/2]; // near right edge

    difference(){
        union(){
            // Base
            rounded_plate(base, corner_r);

            // Central boss
            translate([0,0,base[2]])
                cylinder(d=boss_d, h=boss_h);

            // Small reinforcing ribs
            for(a=[0,90,180,270]){
                rotate([0,0,a])
                    translate([0, boss_d/2 - 2, base[2]])
                        cube([18,4,8], center=true);
            }
        }

        // Central bore through boss and base
        translate([0,0,-1])
            cylinder(d=bore_d, h=base[2]+boss_h+2);

        // Four mounting holes
        for(sx=[-1,1], sy=[-1,1]){
            translate([sx*hole_inset[0], sy*hole_inset[1], -1])
                cylinder(d=hole_d, h=base[2]+2);
        }

        // Side slot (cable/zip-tie pass-through)
        translate([slot_offset[0], slot_offset[1], slot_offset[2]])
            cube(slot, center=true);

        // Light chamfer-ish underside relief (simple)
        translate([0,0,-0.01])
            linear_extrude(height=2)
                offset(r=corner_r-2)
                    square([base[0]-2*(corner_r-2), base[1]-2*(corner_r-2)], center=true);
    }
}

component();