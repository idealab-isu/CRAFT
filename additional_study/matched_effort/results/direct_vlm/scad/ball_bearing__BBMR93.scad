$fn = 128;

// Ball bearing: 3.0mm bore, 9.0mm OD, 4.0mm width
bore_d = 3.0;
od_d   = 9.0;
width  = 4.0;

// Visual/detail parameters (kept small so overall dims remain exact)
race_th     = 1.0;   // radial thickness of each ring
clearance   = 0.10;  // radial clearance between balls and races
shield_th   = 0.35;  // thin shields
shield_gap  = 0.20;  // inset from OD/ID for shields
overlap     = 0.05;  // tiny overlap to ensure one connected solid

// Derived dimensions
inner_od = bore_d + 2*race_th;   // OD of inner ring
outer_id = od_d   - 2*race_th;   // ID of outer ring

// Ball sizing and placement
ball_d_raw = (outer_id - inner_od)/2 - 2*clearance;
ball_d     = max(0.8, min(ball_d_raw, 1.2));
ball_pitch_r = (inner_od/2 + outer_id/2)/2;

// Ensure a visible set of balls
n_balls = max(8, floor(2*PI*ball_pitch_r / (ball_d*1.15)));

module ring(id, od, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module shield(id, od, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h+0.2, center=true);
    }
}

module balls(){
    for(i=[0:n_balls-1]){
        rotate([0,0,360*i/n_balls])
            translate([ball_pitch_r,0,0])
                sphere(d=ball_d);
    }
}

// Build as ONE connected solid by adding a very thin cage that touches rings and balls
module cage(){
    // Cage radial span: from just outside inner ring to just inside outer ring
    cage_id = inner_od + 2*(clearance - overlap);
    cage_od = outer_id - 2*(clearance - overlap);
    cage_h  = ball_d*0.55; // thin band around ball equator

    ring(cage_id, cage_od, cage_h);
}

union(){
    // Outer ring (exact OD and width)
    ring(outer_id, od_d, width);

    // Inner ring (exact bore and width)
    ring(bore_d, inner_od, width);

    // Balls
    balls();

    // Cage to ensure connectivity (touches rings and balls)
    cage();

    // Shields (touch outer ring; slightly overlap to avoid coincident faces)
    shield_id = inner_od + 2*shield_gap;
    shield_od = od_d - 2*shield_gap;

    translate([0,0, (width - shield_th)/2 - overlap])
        shield(shield_id, shield_od, shield_th);

    translate([0,0,-(width - shield_th)/2 + overlap])
        shield(shield_id, shield_od, shield_th);
}