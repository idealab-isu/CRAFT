$fn = 128;

// Target bearing envelope (mm)
bore_d = 5.0;
od_d   = 9.0;
width  = 2.5;

// Visual/constructive parameters (kept formula-based, no arbitrary placement)
eps = 0.02;                 // tiny overlap to guarantee single connected solid
race_th = 0.85;             // radial thickness of inner/outer rings
clearance = 0.12;           // radial clearance around balls (visual)
cage_th = 0.35;             // axial thickness of cage band
cage_rad_th = 0.35;         // radial thickness of cage band

// Derived diameters
inner_od = bore_d + 2*race_th;
outer_id = od_d   - 2*race_th;

// Ball sizing from available radial space and width
rad_space = (outer_id - inner_od)/2;
ball_d = min(rad_space - 2*clearance, width*0.70);
ball_d = max(ball_d, 0.70);
ball_r = ball_d/2;

// Ball pitch radius centered between raceways
pitch_r = (inner_od/2 + outer_id/2)/2;

// Ball count from circumference
n_balls = max(7, floor(2*PI*pitch_r / (ball_d*1.20)));

module ring(id, od, w){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w + 2*eps, center=true);
    }
}

module balls(){
    for(i=[0:n_balls-1]){
        rotate([0,0,360*i/n_balls])
            translate([pitch_r,0,0])
                sphere(d=ball_d);
    }
}

// Cage: a thin band that touches balls slightly to ensure connectivity
module cage(){
    cage_id = 2*(pitch_r - ball_r - cage_rad_th/2);
    cage_od = 2*(pitch_r + ball_r + cage_rad_th/2);

    // Ensure cage overlaps balls a bit (connectivity)
    cage_h = min(cage_th, width - 2*eps);

    difference(){
        cylinder(d=cage_od, h=cage_h, center=true);
        cylinder(d=cage_id, h=cage_h + 2*eps, center=true);

        // Pockets for balls (slightly larger than balls)
        for(i=[0:n_balls-1]){
            rotate([0,0,360*i/n_balls])
                translate([pitch_r,0,0])
                    cylinder(d=ball_d + 2*clearance, h=cage_h + 2*eps, center=true);
        }
    }
}

union(){
    // Outer ring (exact OD and width)
    ring(outer_id, od_d, width);

    // Inner ring (exact bore and width)
    ring(bore_d, inner_od, width);

    // Balls
    balls();

    // Cage (connects to balls; rings remain separate as in real bearing, but overall is one connected solid)
    cage();
}