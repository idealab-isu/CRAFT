$fn = 128;

bore_d = 5.0;
od_d   = 8.0;
width  = 2.5;

eps = 0.03; // small overlap to guarantee a single connected solid

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w + 2*eps, center=true);
    }
}

module bearing_5x8x2p5(){
    // Exact envelope:
    // OD = od_d, bore = bore_d, width = width

    // Proportions chosen to visibly show races/balls/shields while staying within envelope
    race_th   = 0.55;  // radial thickness of each ring
    shield_th = 0.22;  // thin shields

    inner_od = bore_d + 2*race_th;   // inner ring outer diameter
    outer_id = od_d   - 2*race_th;   // outer ring inner diameter

    // Ball geometry
    avail_rad = (outer_id - inner_od)/2;
    ball_d = min(0.95, max(0.60, 2*avail_rad - 0.12));
    path_r = (inner_od/2 + outer_id/2)/2;

    // Ball count
    nballs = max(7, floor((2*PI*path_r) / (ball_d*1.25)));

    // Cage/web to ensure ONE connected solid (connects inner ring, outer ring, and balls)
    cage_th = min(0.35, max(0.18, avail_rad*0.55)); // radial thickness of cage ring
    cage_id = inner_od + 0.10;                       // keep away from bore
    cage_od = outer_id - 0.10;                       // keep away from OD
    cage_mid_d = (cage_id + cage_od)/2;
    cage_w = max(0.35, width - 2*shield_th - 0.10);  // stays inside shields
    cage_z = 0;

    union(){
        // Outer ring
        ring(od_d, outer_id, width);

        // Inner ring
        ring(inner_od, bore_d, width);

        // Shields (embedded slightly into rings for connectivity)
        for(zs=[-1,1]){
            translate([0,0,zs*(width/2 - shield_th/2 - eps)])
                difference(){
                    cylinder(d=od_d - 0.08, h=shield_th + 2*eps, center=true);
                    cylinder(d=bore_d + 0.25, h=shield_th + 4*eps, center=true);
                }
        }

        // Cage ring (connects inner & outer via overlaps; also intersects balls)
        translate([0,0,cage_z])
            ring(cage_od, cage_id, cage_w);

        // Balls (slightly enlarged so they intersect cage and races)
        for(i=[0:nballs-1]){
            rotate([0,0,360*i/nballs])
                translate([path_r,0,0])
                    sphere(d=ball_d + 2*eps);
        }

        // Small radial spokes to guarantee robust connectivity between cage and rings
        // (kept inside envelope; overlaps into both rings by eps)
        spoke_w = max(0.25, cage_w*0.55);
        spoke_t = 0.22;
        for(i=[0:nballs-1]){
            rotate([0,0,360*i/nballs + 180/nballs])
                translate([path_r,0,0])
                    cube([2*avail_rad + 2*eps, spoke_t, spoke_w], center=true);
        }
    }
}

bearing_5x8x2p5();