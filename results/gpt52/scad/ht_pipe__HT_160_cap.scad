$fn=96;

module ht160_cap(od=160, wall=4.7, cap_height=55, lip_height=22, dome_height=18, clearance=0.6, chamfer=2.0) {
    id = od - 2*wall + 2*clearance;
    outer_r = od/2;
    inner_r = id/2;

    module outer_shell() {
        union() {
            cylinder(h=cap_height - dome_height, r=outer_r);
            translate([0,0,cap_height - dome_height])
                intersection() {
                    sphere(r=outer_r);
                    translate([0,0,0]) cylinder(h=dome_height, r=outer_r);
                }
        }
    }

    module inner_void() {
        union() {
            translate([0,0,lip_height])
                cylinder(h=cap_height, r=inner_r);
            translate([0,0,lip_height - chamfer])
                cylinder(h=chamfer, r1=inner_r + chamfer, r2=inner_r);
        }
    }

    module stop_ring() {
        ring_th = 2.2;
        ring_h = 2.0;
        ring_r = inner_r + ring_th;
        translate([0,0,lip_height - ring_h])
            difference() {
                cylinder(h=ring_h, r=ring_r);
                cylinder(h=ring_h, r=inner_r);
            }
    }

    difference() {
        outer_shell();
        inner_void();
        stop_ring();
    }
}

ht160_cap();