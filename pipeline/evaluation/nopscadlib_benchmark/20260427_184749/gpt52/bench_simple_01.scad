$fn=64;

od = 22;
id = 8;
th = 7;

outer_r = od/2;
inner_r = id/2;

shield_recess_depth = 0.4;
shield_recess_r = outer_r - 1.0;

module ring(ro, ri, h){
    difference(){
        cylinder(r=ro, h=h, center=true);
        cylinder(r=ri, h=h+0.2, center=true);
    }
}

module bearing_608(){
    union(){
        // Outer ring (race)
        ring(outer_r, 9.5/2, th);

        // Inner ring (race)
        ring(7.0, inner_r, th);

        // Ball set (approximate)
        for(i=[0:7]){
            rotate([0,0,i*45])
                translate([8.0,0,0])
                    sphere(r=1.6);
        }
    }
}

difference(){
    bearing_608();

    // Shield recess on both sides (approximate)
    translate([0,0, th/2 - shield_recess_depth/2])
        cylinder(r=shield_recess_r, h=shield_recess_depth, center=true);

    translate([0,0,-th/2 + shield_recess_depth/2])
        cylinder(r=shield_recess_r, h=shield_recess_depth, center=true);
}