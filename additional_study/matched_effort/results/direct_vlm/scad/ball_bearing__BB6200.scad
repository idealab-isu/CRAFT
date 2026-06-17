$fn=180;

bore_d = 10.0;
od_d   = 30.0;
width  = 9.0;

ring_wall = 3.0;          // radial thickness of each ring
race_depth = 1.6;         // depth of race groove (radial)
race_r = 1.55;            // groove/ball radius
clearance = 0.25;         // small clearance between balls and races

inner_od = bore_d + 2*ring_wall;
outer_id = od_d   - 2*ring_wall;

race_r_eff = race_r + clearance;

// Race center radii (where groove centerline sits)
r_inner_race_c = inner_od/2 - race_depth;
r_outer_race_c = outer_id/2 + race_depth;

// Ball pitch radius (mid between race centers)
r_pitch = (r_inner_race_c + r_outer_race_c)/2;

// Ball size chosen to fit between races
ball_r = min(race_r, (r_outer_race_c - r_inner_race_c)/2 - clearance);

n_balls = 10;

module ring_with_race(r_in, r_out, race_center_r, groove_r){
    difference(){
        // ring body
        difference(){
            cylinder(h=width, r=r_out, center=true);
            cylinder(h=width+0.2, r=r_in, center=true);
        }
        // race groove (torus-like cut)
        rotate_extrude(angle=360)
            translate([race_center_r, 0, 0])
                circle(r=groove_r);
    }
}

module balls(){
    for(i=[0:n_balls-1]){
        ang = 360*i/n_balls;
        rotate([0,0,ang])
            translate([r_pitch, 0, 0])
                sphere(r=ball_r);
    }
}

union(){
    // Outer ring with inner race
    ring_with_race(outer_id/2, od_d/2, r_outer_race_c, race_r_eff);

    // Inner ring with outer race
    ring_with_race(bore_d/2, inner_od/2, r_inner_race_c, race_r_eff);

    // Balls
    balls();
}