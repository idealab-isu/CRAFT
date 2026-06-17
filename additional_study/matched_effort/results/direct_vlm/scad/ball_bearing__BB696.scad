$fn = 180;

bore_d = 6.0;
od_d   = 16.0;
width  = 5.0;

// Simple parametric ball bearing approximation:
// - Outer ring and inner ring as cylinders with a raceway groove
// - Balls placed evenly around the pitch circle
// - Optional shields omitted for simplicity

clearance = 0.25;          // general clearance between parts (mm)
race_groove_r = 1.05;       // groove radius (mm)
ball_d = 2.0;               // ball diameter (mm)
ball_r = ball_d/2;

inner_ring_od = 10.0;       // approximate (mm)
outer_ring_id = 12.0;       // approximate (mm)

pitch_d = (inner_ring_od + outer_ring_id)/2; // ball center circle diameter

module ring(od, id, w, groove_center_r, groove_r){
    difference(){
        cylinder(d=od, h=w, center=true);
        cylinder(d=id, h=w+0.6, center=true);

        // Raceway groove (torus-like cut via rotate_extrude of a circle)
        rotate_extrude(convexity=10)
            translate([groove_center_r, 0, 0])
                circle(r=groove_r);
    }
}

module balls(n, pitch_radius, z=0){
    for(i=[0:n-1]){
        rotate([0,0,360*i/n])
            translate([pitch_radius,0,z])
                sphere(d=ball_d);
    }
}

module bearing(){
    // Outer ring groove center radius
    outer_groove_center_r = (outer_ring_id/2) + (race_groove_r + clearance*0.2);
    // Inner ring groove center radius
    inner_groove_center_r = (inner_ring_od/2) - (race_groove_r + clearance*0.2);

    // Outer ring
    ring(od=od_d, id=outer_ring_id, w=width, groove_center_r=outer_groove_center_r, groove_r=race_groove_r);

    // Inner ring
    ring(od=inner_ring_od, id=bore_d, w=width, groove_center_r=inner_groove_center_r, groove_r=race_groove_r);

    // Balls
    balls(n=8, pitch_radius=pitch_d/2, z=0);
}

bearing();