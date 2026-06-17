$fn = 180;

bore_d = 12.0;
od_d   = 32.0;
width  = 10.0;

// Simple parametric ball bearing representation:
// - Outer ring
// - Inner ring
// - Ball set (approximate)
// - Optional thin shields (very thin)

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.2, center=true);
    }
}

module bearing_6012_like(bore_d, od_d, width){
    // Proportions chosen to look plausible for a deep-groove bearing
    radial_thickness = (od_d - bore_d)/2;
    ring_wall = max(1.2, radial_thickness*0.33);     // ring radial thickness
    gap = max(0.6, radial_thickness*0.10);           // clearance between rings for balls
    
    inner_od = bore_d + 2*ring_wall;
    outer_id = od_d   - 2*ring_wall;

    // Ball sizing and placement
    race_mid_r = (inner_od/2 + outer_id/2)/2;
    ball_d = min( (outer_id - inner_od) - 2*gap, radial_thickness*0.55 );
    ball_d = max(ball_d, 2.0);
    nballs = 10; // visually plausible; not specified

    // Rings
    color([0.75,0.75,0.78]) ring(od_d, outer_id, width);
    color([0.75,0.75,0.78]) ring(inner_od, bore_d, width);

    // Balls
    color([0.85,0.85,0.88])
    for(i=[0:nballs-1]){
        angle = 360*i/nballs;
        rotate([0,0,angle])
            translate([race_mid_r,0,0])
                sphere(d=ball_d);
    }

    // Thin shields (optional aesthetic)
    shield_t = 0.4;
    shield_clear = 0.3;
    shield_id = inner_od + 2*shield_clear;
    shield_od = outer_id - 2*shield_clear;

    color([0.65,0.65,0.68])
    for(z=[-(width/2 - shield_t/2), (width/2 - shield_t/2)]){
        translate([0,0,z])
        difference(){
            cylinder(d=shield_od, h=shield_t, center=true);
            cylinder(d=shield_id, h=shield_t+0.2, center=true);
        }
    }
}

bearing_6012_like(bore_d, od_d, width);