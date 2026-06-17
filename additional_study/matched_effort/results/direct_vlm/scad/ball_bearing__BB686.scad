$fn = 180;

// Ball bearing envelope (must match exactly)
bore_d = 6.0;
od_d   = 13.0;
width  = 5.0;

// Detail parameters (kept within envelope)
race_thickness   = 1.2;   // radial thickness of each ring
clearance_radial = 0.20;  // clearance between balls and races
shield_thickness = 0.25;  // thin shields
shield_inset     = 0.15;  // inset from faces
bridge_overlap   = 0.12;  // overlap to ensure ONE connected solid
eps = 0.02;

module ring(od, id, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w + 2*eps, center=true);
    }
}

module bearing(){
    // Derived diameters for race boundaries
    outer_id = od_d - 2*race_thickness;
    inner_od = bore_d + 2*race_thickness;

    // Ball path and size
    ball_path_d = (outer_id + inner_od)/2;
    radial_gap  = (outer_id - inner_od)/2;

    ball_d_raw = min( 2*(radial_gap - clearance_radial), width - 2*clearance_radial );
    ball_d = max(0.8, ball_d_raw);

    // Ensure balls intersect BOTH races (connectivity) but stay within envelope
    embed = min(bridge_overlap, max(0, radial_gap - ball_d/2));
    ball_r = ball_path_d/2 - embed;

    // Ball count
    nballs_raw = floor( (PI*ball_path_d) / (ball_d*1.25) );
    nballs = max(6, min(12, nballs_raw));

    // Shields (thin rings) placed inside faces and overlapped for connectivity
    shield_od = od_d - 0.4;
    shield_id = bore_d + 0.6;

    zpos = width/2 - shield_thickness/2 - shield_inset;

    // Build as a single connected solid, then cut the bore through everything
    difference(){
        union(){
            // Outer ring
            ring(od_d, outer_id, width);

            // Inner ring
            ring(inner_od, bore_d, width);

            // Balls
            for(i=[0:nballs-1]){
                rotate([0,0,360*i/nballs])
                    translate([ball_r, 0, 0])
                        sphere(d=ball_d);
            }

            // Shields (slightly thicker to overlap into rings)
            for(z=[-zpos, zpos]){
                translate([0,0,z])
                    ring(shield_od, shield_id, shield_thickness + 2*bridge_overlap);
            }
        }

        // Guarantee the 6.0mm bore is visible in ALL views (cuts through balls/shields too)
        cylinder(d=bore_d, h=width + 4*eps, center=true);
    }
}

bearing();