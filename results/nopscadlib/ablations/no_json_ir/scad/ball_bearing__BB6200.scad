$fn = 160;

// Ball bearing target dimensions (envelope)
bore_diameter  = 10.0;   // ID
outer_diameter = 30.0;   // OD
width          = 9.0;    // axial width

// Visual/feature parameters (kept within envelope)
ball_diameter  = 3.0;
num_balls      = 10;

eps = 0.02;

// Connectivity overlap (1–2mm as required)
overlap = 1.2;

// Derived radii
r_id = bore_diameter/2;
r_od = outer_diameter/2;

// Layout
race_clearance = 0.35;                 // visual clearance around balls
r_ball_path = (r_id + r_od)/2;         // ball center radius

// Ring thicknesses (chosen to fit within OD/ID and leave room for balls)
outer_ring_th = max(2.2, (r_od - (r_ball_path + ball_diameter/2 + race_clearance)));
inner_ring_th = max(2.2, ((r_ball_path - ball_diameter/2 - race_clearance) - r_id));

// Radii for rings
r_inner_outerring = r_od - outer_ring_th;   // inner radius of outer ring
r_outer_innerring = r_id + inner_ring_th;   // outer radius of inner ring

// Balls: slightly enlarged to ensure they intersect races/cage
ball_d_union = ball_diameter + 0.6;

// --- FIX: ensure balls physically touch/overlap both rings ---
r_ball_path_connected =
    (r_outer_innerring + r_inner_outerring)/2
    - (overlap/2);

// --- FIX: cage/race elements must be fused to rings ---
cage_h = width; // full width so it intersects rings and balls robustly

// Radial extents: force overlap into both rings by 'overlap'
cage_r_in  = r_outer_innerring - overlap;
cage_r_out = r_inner_outerring + overlap;

// Keep within envelope (and above bore)
cage_r_in  = max(cage_r_in,  r_id + 0.2);
cage_r_out = min(cage_r_out, r_od - 0.2);

// Pocket radius: keep some cage material while allowing balls to remain visible
pocket_r = ball_diameter * 0.52;

// --- FIX: add solid "web" bridges so inner race, outer race, and ball set are ONE connected solid ---
// Two thin radial ribs (at 0° and 180°) that span from inner race OD into outer race ID,
// overlapping both by 'overlap'. This removes the structural separation caused by the ball gap.
web_w = 2.0; // tangential width of each web (kept small to preserve bearing look)
web_r1 = r_outer_innerring - overlap;  // start inside inner race (overlap)
web_r2 = r_inner_outerring + overlap;  // end inside outer race (overlap)
web_len = max(0.1, web_r2 - web_r1);   // radial length of web
web_rmid = (web_r1 + web_r2)/2;        // center radius for translate()

module bearing() {
    difference() {
        union() {
            outer_ring();
            inner_ring();
            cage();
            balls();
            webs();   // <-- structural connector between inner and outer assemblies
        }
        // Through-bore (true hole)
        cylinder(h=width + 2*eps, r=r_id, center=true);
    }
}

module outer_ring() {
    difference() {
        cylinder(h=width, r=r_od, center=true);
        cylinder(h=width + 2*eps, r=r_inner_outerring, center=true);
    }
}

module inner_ring() {
    difference() {
        cylinder(h=width, r=r_outer_innerring, center=true);
        cylinder(h=width + 2*eps, r=r_id, center=true);
    }
}

module cage() {
    // Cage centered in width; pockets cut out
    difference() {
        difference() {
            cylinder(h=cage_h, r=cage_r_out, center=true);
            cylinder(h=cage_h + 2*eps, r=cage_r_in, center=true);
        }
        // Ball pockets (slightly smaller than balls so cage remains visible)
        for (i = [0:num_balls-1]) {
            rotate([0,0,i*360/num_balls])
                translate([r_ball_path_connected, 0, 0])
                    cylinder(h=cage_h + 2*eps, r=pocket_r, center=true);
        }
    }
}

module balls() {
    // Balls centered; enlarged to guarantee intersection with cage and both rings
    for (i = [0:num_balls-1]) {
        rotate([0,0,i*360/num_balls])
            translate([r_ball_path_connected, 0, 0])
                sphere(d=ball_d_union);
    }
}

module webs() {
    // Two opposite ribs to guarantee a single connected manifold.
    // Positioned with formula-based translate so they intersect both races by 'overlap'.
    for (a = [0, 180]) {
        rotate([0,0,a])
            translate([web_rmid, 0, 0])
                cube([web_len, web_w, width], center=true);
    }
}

bearing();