$fn = 180;

bore_d = 10.0;
od_d   = 30.0;
width  = 9.0;

clearance = 0.25;          // small clearance between rings and balls
race_depth = 1.6;          // groove depth into each ring
ball_d = 4.0;              // ball diameter
ball_count = 8;

module ring_with_race(id, od, w, race_r, race_z, depth){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.6, center=true);

        // toroidal groove (race) carved into the ring
        rotate_extrude(convexity=10)
            translate([race_r, 0, 0])
                circle(r=depth, $fn=96);
    }
}

module bearing(){
    // Basic proportions for a 10x30x9 bearing-like model
    ring_thickness = 3.0; // radial thickness of each ring
    inner_od = bore_d + 2*ring_thickness;
    outer_id = od_d   - 2*ring_thickness;

    // Ball path radius (from axis)
    ball_path_r = (inner_od/2 + outer_id/2)/2;

    // Race groove radius (same as ball path)
    race_r = ball_path_r;

    // Groove depth limited so it doesn't break through ring walls
    max_depth_inner = min(race_depth, (inner_od/2 - bore_d/2) - 0.6);
    max_depth_outer = min(race_depth, (od_d/2 - outer_id/2) - 0.6);
    inner_depth = max(0.8, max_depth_inner);
    outer_depth = max(0.8, max_depth_outer);

    union(){
        // Outer ring
        difference(){
            cylinder(d=od_d, h=width, center=true);
            cylinder(d=outer_id, h=width+0.6, center=true);

            rotate_extrude(convexity=10)
                translate([race_r, 0, 0])
                    circle(r=outer_depth, $fn=96);
        }

        // Inner ring
        difference(){
            cylinder(d=inner_od, h=width, center=true);
            cylinder(d=bore_d, h=width+0.6, center=true);

            rotate_extrude(convexity=10)
                translate([race_r, 0, 0])
                    circle(r=inner_depth, $fn=96);
        }

        // Balls
        for(i = [0:ball_count-1]){
            angle = 360/ball_count * i;
            rotate([0,0,angle])
                translate([ball_path_r, 0, 0])
                    sphere(d=ball_d);
        }

        // Simple cage (optional, thin ring with pockets)
        cage_th = 1.2;
        cage_id = (inner_od/2 + clearance) * 2;
        cage_od = (outer_id/2 - clearance) * 2;
        difference(){
            cylinder(d=cage_od, h=cage_th, center=true);
            cylinder(d=cage_id, h=cage_th+0.6, center=true);

            for(i = [0:ball_count-1]){
                angle = 360/ball_count * i;
                rotate([0,0,angle])
                    translate([ball_path_r, 0, 0])
                        cylinder(d=ball_d+0.8, h=cage_th+1.0, center=true);
            }
        }
    }
}

bearing();