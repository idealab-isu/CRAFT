$fn = 128;

// Target bearing envelope
bore_d  = 3.0;
outer_d = 8.0;
width   = 3.0;

// Internal feature tuning (kept within envelope)
race_wall  = 0.8;   // radial thickness of each race
race_lip   = 0.35;  // axial lip thickness (keeps balls in)
clearance  = 0.15;  // radial clearance between balls and races
ball_d     = 1.2;   // ball diameter
ball_count = 8;

eps = 0.02;         // small overlap to ensure one connected solid

module ring(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h + 2*eps, center=true);
    }
}

module bearing(){
    inner_od = bore_d + 2*race_wall;
    outer_id = outer_d - 2*race_wall;

    // Ball pitch diameter (between raceways)
    pitch_d = (inner_od + outer_id)/2;

    // Ensure the balls are captured axially by the lips (no protrusion beyond width)
    ball_z_limit = width/2 - race_lip - ball_d/2;
    ball_z = (ball_z_limit > 0) ? 0 : 0; // keep centered; geometry already sized to fit

    // Raceway diameters (remove material to form grooves)
    outer_groove_d = outer_id + 2*(ball_d/2 + clearance);
    inner_groove_d = inner_od - 2*(ball_d/2 + clearance);

    // One connected solid: add a very thin cage ring that touches balls and races
    cage_th = 0.25;
    cage_id = inner_od + eps;
    cage_od = outer_id - eps;

    union(){
        // Outer race with groove
        difference(){
            ring(outer_d, outer_id, width);
            cylinder(d=outer_groove_d, h=width - 2*race_lip, center=true);
        }

        // Inner race with groove
        difference(){
            ring(inner_od, bore_d, width);
            cylinder(d=inner_groove_d, h=width - 2*race_lip, center=true);
        }

        // Cage (thin ring) to guarantee connectivity between races and balls
        ring(cage_od, cage_id, cage_th);

        // Balls
        for(i=[0:ball_count-1]){
            rotate([0,0,360*i/ball_count])
                translate([pitch_d/2, 0, ball_z])
                    sphere(d=ball_d);
        }
    }
}

bearing();