$fn=96;

// Generic parametric component: mounting base + vertical post + through-hole + fillets (approximated)
module component(
    base_len=60,
    base_wid=30,
    base_thk=6,
    post_d=18,
    post_h=28,
    hole_d=6,
    hole_z=18,
    corner_r=4,
    gusset_thk=6,
    gusset_len=18
){
    difference() {
        union() {
            // Base with rounded corners (2D offset then linear_extrude)
            linear_extrude(height=base_thk)
                offset(r=corner_r)
                    square([base_len-2*corner_r, base_wid-2*corner_r], center=true);

            // Vertical post centered
            translate([0,0,base_thk])
                cylinder(d=post_d, h=post_h);

            // Two gussets (triangular ribs) along length direction
            for (sx=[-1,1]) {
                translate([sx*(post_d/2), 0, base_thk])
                    rotate([0,90,0])
                        linear_extrude(height=gusset_thk, center=false)
                            polygon(points=[
                                [0,0],
                                [gusset_len,0],
                                [0,post_h*0.75]
                            ]);
            }
        }

        // Through-hole in post (horizontal)
        translate([0,0,base_thk+hole_z])
            rotate([0,90,0])
                cylinder(d=hole_d, h=base_len*2, center=true);

        // Four mounting holes in base
        mount_dx = base_len*0.35;
        mount_dy = base_wid*0.30;
        for (x=[-mount_dx, mount_dx], y=[-mount_dy, mount_dy]) {
            translate([x,y,-1])
                cylinder(d=5, h=base_thk+2);
        }

        // Light underside pocket to reduce material
        translate([0,0,1.2])
            linear_extrude(height=base_thk-2.4)
                offset(r=max(0,corner_r-1.5))
                    square([base_len-10, base_wid-10], center=true);
    }
}

component();