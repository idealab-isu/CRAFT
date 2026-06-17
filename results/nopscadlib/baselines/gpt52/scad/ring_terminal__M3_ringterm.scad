$fn=96;

module ring_terminal(
    ring_od=18,
    ring_id=8,
    ring_th=2.2,
    neck_len=8,
    neck_w=7,
    barrel_len=18,
    barrel_od=7.5,
    barrel_id=4.2,
    seam_gap=1.2
){
    union(){
        // Ring + neck (flat)
        linear_extrude(height=ring_th, center=true)
        union(){
            difference(){
                circle(d=ring_od);
                circle(d=ring_id);
            }
            translate([ring_od/2 + neck_len/2, 0])
                square([neck_len, neck_w], center=true);
        }

        // Barrel (crimp tube) with seam gap, centered on ring thickness
        translate([ring_od/2 + neck_len + barrel_len/2, 0, 0])
        difference(){
            // Outer tube
            rotate([0,90,0])
                cylinder(h=barrel_len, d=barrel_od, center=true);
            // Inner bore
            rotate([0,90,0])
                cylinder(h=barrel_len+0.4, d=barrel_id, center=true);
            // Seam gap cut (slot along length)
            translate([0, barrel_od/2, 0])
                cube([barrel_len+0.6, seam_gap, barrel_od*2], center=true);
        }

        // Transition fillet-ish block between neck and barrel
        translate([ring_od/2 + neck_len + 1.2, 0, 0])
            hull(){
                translate([-1.2, 0, 0])
                    cube([2.4, neck_w, ring_th], center=true);
                translate([2.2, 0, 0])
                    rotate([0,90,0])
                        cylinder(h=2.4, d=barrel_od, center=true);
            }
    }
}

ring_terminal();