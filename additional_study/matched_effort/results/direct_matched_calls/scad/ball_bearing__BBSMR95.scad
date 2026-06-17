$fn = 128;

bore_d = 5.0;
od_d   = 9.0;
width  = 2.5;

// Simple bearing approximation: outer ring + inner ring + ball set + thin shields
clearance = 0.15;          // radial clearance between rings and balls
race_th   = 0.9;           // radial thickness of each ring
shield_th = 0.2;           // thickness of each shield
ball_d    = 0.9;           // ball diameter
ball_count = 8;

module ring(outer_d, inner_d, h){
    difference(){
        cylinder(d=outer_d, h=h, center=true);
        cylinder(d=inner_d, h=h+0.2, center=true);
    }
}

module bearing(){
    // Derived diameters
    inner_ring_od = bore_d + 2*race_th;
    outer_ring_id = od_d   - 2*race_th;

    // Ball path radius (midway between raceways)
    ball_path_d = (inner_ring_od + outer_ring_id)/2;
    ball_path_r = ball_path_d/2;

    union(){
        // Outer ring
        ring(od_d, outer_ring_id, width);

        // Inner ring
        ring(inner_ring_od, bore_d, width);

        // Shields (very thin discs with center hole)
        for(z = [-(width/2 - shield_th/2), (width/2 - shield_th/2)]){
            translate([0,0,z])
                ring(od_d - 0.2, bore_d + 0.2, shield_th);
        }

        // Balls
        for(i = [0:ball_count-1]){
            angle = 360*i/ball_count;
            rotate([0,0,angle])
                translate([ball_path_r, 0, 0])
                    sphere(d=ball_d);
        }
    }
}

bearing();