$fn=64;

module d_profile(r=10, depth=8){
    intersection(){
        cylinder(h=depth, r=r, center=true);
        translate([0, -r/2, 0]) cube([2*r, r, depth+0.2], center=true);
    }
}

module d_connector(body_r=10, body_depth=8, flange_th=2, flange_r=12, hole_r=1.6, hole_offset=8){
    difference(){
        union(){
            d_profile(r=body_r, depth=body_depth);
            translate([0,0,(body_depth+flange_th)/2])
                cylinder(h=flange_th, r=flange_r, center=true);
        }
        for(a=[0,180]){
            rotate([0,0,a])
                translate([hole_offset,0,(body_depth+flange_th)/2])
                    cylinder(h=flange_th+0.4, r=hole_r, center=true);
        }
    }
}

d_connector();