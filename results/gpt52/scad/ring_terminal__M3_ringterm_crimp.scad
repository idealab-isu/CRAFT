$fn=96;

module ring_terminal(
    ring_od=16,
    ring_id=8,
    ring_th=2.2,
    neck_w=6,
    neck_l=6,
    barrel_od=6.5,
    barrel_id=3.2,
    barrel_l=14,
    barrel_wall=1.2
){
    union(){
        // Ring + neck (flat)
        linear_extrude(height=ring_th, center=true)
        union(){
            difference(){
                circle(d=ring_od);
                circle(d=ring_id);
            }
            translate([ring_od/2 + neck_l/2, 0])
                square([neck_l, neck_w], center=true);
        }

        // Barrel (tube) aligned along +X, centered in Z
        translate([ring_od/2 + neck_l + barrel_l/2, 0, 0])
        rotate([0,90,0])
        difference(){
            cylinder(d=barrel_od, h=barrel_l, center=true);
            cylinder(d=barrel_id, h=barrel_l + 0.6, center=true);
        }

        // Transition collar between neck and barrel
        translate([ring_od/2 + neck_l + 1.2, 0, 0])
        rotate([0,90,0])
        difference(){
            cylinder(d1=barrel_od, d2=barrel_od*0.92, h=2.4, center=true);
            cylinder(d=barrel_id, h=3.2, center=true);
        }
    }
}

ring_terminal();