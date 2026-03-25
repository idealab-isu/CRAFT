$fn=96;

module socket_head_cap_screw(d=8.0, head_d=13.0, head_h=8.0, shank_l=10.0, socket_d=6.0, socket_depth=5.0){
    union(){
        translate([0,0,-shank_l/2])
            cylinder(d=d, h=shank_l, center=true);

        difference(){
            translate([0,0,shank_l/2 + head_h/2])
                cylinder(d=head_d, h=head_h, center=true);

            translate([0,0,shank_l/2 + head_h - socket_depth/2])
                cylinder(d=socket_d, h=socket_depth+0.2, center=true, $fn=6);
        }
    }
}

socket_head_cap_screw(d=8.0, head_d=13.0, head_h=8.0, shank_l=10.0, socket_d=6.0, socket_depth=5.0);