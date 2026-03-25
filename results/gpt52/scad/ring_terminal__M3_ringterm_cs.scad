$fn=96;

module ring_terminal(
    ring_od=18,
    ring_id=8,
    ring_th=2.2,
    neck_len=10,
    neck_w=8,
    barrel_len=18,
    barrel_od=7.5,
    barrel_id=4.2,
    slit_w=1.2
){
    union(){
        // Ring + neck (flat)
        linear_extrude(height=ring_th, center=true)
        union(){
            difference(){
                circle(d=ring_od);
                circle(d=ring_id);
            }
            translate([ (ring_od/2 + neck_len/2) - 0.2, 0 ])
                square([neck_len, neck_w], center=true);
        }

        // Barrel (hollow cylinder) attached to neck
        translate([ ring_od/2 + neck_len + barrel_len/2 - 0.4, 0, 0 ])
        difference(){
            rotate([0,90,0]) cylinder(d=barrel_od, h=barrel_len, center=true);
            rotate([0,90,0]) cylinder(d=barrel_id, h=barrel_len+0.6, center=true);
            // Crimp slit
            translate([0,0,0])
                cube([barrel_len+1, slit_w, barrel_od+2], center=true);
        }
    }
}

ring_terminal();