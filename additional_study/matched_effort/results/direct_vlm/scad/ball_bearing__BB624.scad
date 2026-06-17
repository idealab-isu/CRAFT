$fn = 180;

// Ball bearing envelope (mm)
bore_d = 4.0;
od_d   = 13.0;
width  = 5.0;

// Visual/structural parameters (kept inside the envelope)
eps = 0.03;                 // tiny overlap to ensure one connected solid
race_depth = 1.0;           // radial thickness of race region in each ring
ring_clearance = 0.25;      // radial clearance between rings and balls (visual)
shield_thk = 0.35;          // thin shields (kept inside width)
shield_gap = 0.15;          // inset from faces

// Derived diameters
inner_od = bore_d + 2*(race_depth + ring_clearance);     // inner ring outer diameter
outer_id = od_d   - 2*(race_depth + ring_clearance);     // outer ring inner diameter

// Ball sizing and path
ball_d = min((outer_id - inner_od) * 0.85, width * 0.70);
ball_d = max(ball_d, 1.2);

ball_path_r = (inner_od/2 + outer_id/2)/2;
n_balls = max(8, floor(2*PI*ball_path_r / (ball_d*1.15)));

// Shields: ensure bore is visible in orthographic side views
shield_hole_d = max(bore_d + 0.8, inner_od + 0.4);

// Modules
module ring(outer_d, inner_d, w){
    difference(){
        cylinder(d=outer_d, h=w, center=true);
        cylinder(d=inner_d, h=w + 2*eps, center=true);
    }
}

module balls(){
    for (i = [0:n_balls-1]){
        a = 360*i/n_balls;
        rotate([0,0,a])
            translate([ball_path_r, 0, 0])
                sphere(d=ball_d);
    }
}

module shields(){
    // Two thin discs inset slightly, with a center opening guaranteed > bore_d
    zpos = width/2 - shield_gap - shield_thk/2;
    for (z = [-zpos, zpos]){
        translate([0,0,z])
        difference(){
            cylinder(d=od_d - 0.2, h=shield_thk, center=true);
            cylinder(d=shield_hole_d, h=shield_thk + 2*eps, center=true);
        }
    }
}

// Build as ONE connected solid:
// - Outer ring + inner ring + shields are unioned
// - Balls are unioned and then "bridged" to the inner ring with tiny radial ribs
union(){
    // Outer ring
    ring(od_d, outer_id, width);

    // Inner ring (bore is a true through-hole)
    ring(inner_od, bore_d, width);

    // Shields (kept inside width; do not block bore)
    shields();

    // Balls
    balls();

    // Connectivity bridge: tiny ribs from inner ring OD to ball path (hidden inside race)
    rib_w = max(0.35, ball_d*0.18);
    rib_h = width - 2*(shield_gap + shield_thk) - 2*eps;
    rib_h = max(rib_h, width*0.35);

    // Place ribs so they overlap the inner ring and reach the ball path (no arbitrary translates)
    rib_len = (ball_path_r - inner_od/2) + 2*eps;
    rib_x   = inner_od/2 + rib_len/2 - eps;

    for (i = [0:n_balls-1]){
        a = 360*i/n_balls;
        rotate([0,0,a])
            translate([rib_x, 0, 0])
                cube([rib_len, rib_w, rib_h], center=true);
    }
}