$fn = 180;

bore_d = 10.0;
outer_d = 30.0;
width = 9.0;

// Simple deep-groove ball bearing approximation
// Typical for 10x30x9 (e.g., 6200): ball count ~ 8, ball dia ~ 4.76mm
ball_count = 8;
ball_d = 4.76;

// Ring geometry (approximate)
inner_ring_od = 18.0;   // approximate
outer_ring_id = 22.0;   // approximate
race_depth = 1.2;       // groove depth approximation
edge_chamfer = 0.6;     // small chamfer approximation

module chamfered_cylinder(d, h, c) {
    // Creates a cylinder with small 45° chamfers on both ends (approx)
    // by hulling three cylinders.
    hull() {
        translate([0,0,0]) cylinder(d=d-2*c, h=0.01);
        translate([0,0,c]) cylinder(d=d, h=h-2*c);
        translate([0,0,h-0.01]) cylinder(d=d-2*c, h=0.01);
    }
}

module ring(od, id, h, chamfer=0.6) {
    difference() {
        chamfered_cylinder(od, h, min(chamfer, h/3));
        translate([0,0,-0.5]) cylinder(d=id, h=h+1);
    }
}

module race_groove(r_center, groove_r, h, depth) {
    // Subtract a torus-like groove by rotating a circle around Z
    // Use rotate_extrude of a circle positioned at r_center.
    // depth controls how much of the circle is subtracted (approx via scaling).
    rotate_extrude(convexity=10)
        translate([r_center, h/2, 0])
            scale([1, depth/groove_r])
                circle(r=groove_r, $fn=96);
}

module bearing() {
    // Derived radii
    r_bore = bore_d/2;
    r_outer = outer_d/2;

    r_inner_ring_od = inner_ring_od/2;
    r_outer_ring_id = outer_ring_id/2;

    // Ball path radius (midway between ring raceways)
    ball_path_r = (r_inner_ring_od + r_outer_ring_id)/2;

    // Groove radius roughly matches ball radius
    groove_r = ball_d/2;

    // Rings with grooves
    union() {
        // Outer ring
        difference() {
            ring(outer_d, outer_ring_id, width, edge_chamfer);
            // Groove on inner surface of outer ring
            // Place groove centered at ball_path_r, subtract from outer ring volume
            race_groove(ball_path_r, groove_r, width, groove_r - race_depth);
        }

        // Inner ring
        difference() {
            ring(inner_ring_od, bore_d, width, edge_chamfer);
            // Groove on outer surface of inner ring
            race_groove(ball_path_r, groove_r, width, groove_r - race_depth);
        }

        // Balls
        for (i = [0:ball_count-1]) {
            angle = 360/ball_count * i;
            rotate([0,0,angle])
                translate([ball_path_r, 0, width/2])
                    sphere(d=ball_d, $fn=96);
        }

        // Simple cage (thin ring with pockets)
        cage_th = 1.0;
        cage_id = inner_ring_od + 0.8;
        cage_od = outer_ring_id - 0.8;
        difference() {
            translate([0,0,(width - cage_th)/2])
                difference() {
                    cylinder(d=cage_od, h=cage_th);
                    translate([0,0,-0.5]) cylinder(d=cage_id, h=cage_th+1);
                }
            // Ball pockets
            for (i = [0:ball_count-1]) {
                angle = 360/ball_count * i;
                rotate([0,0,angle])
                    translate([ball_path_r, 0, width/2])
                        rotate([90,0,0])
                            cylinder(d=ball_d*1.15, h=cage_od, center=true, $fn=64);
            }
        }
    }
}

bearing();