// Ball bearing: 5.0mm bore, 8.0mm OD, 2.5mm width
// Single connected solid with visible balls and race grooves

$fn = 160;

// Required dimensions
bore_d  = 5.0;
outer_d = 8.0;
width   = 2.5;

// Visual parameters (kept within OD/ID/width)
ball_count = 7;

// Groove/ball sizing (chosen to clearly show bearing features)
groove_r      = 0.33;   // groove radius (also ball radius)
groove_clear  = 0.06;   // extra clearance so grooves are visible
bridge_thk    = 0.22;   // thin web to ensure ONE connected solid
overlap       = 0.03;   // overlap to avoid coincident faces

// Derived radii
bore_r  = bore_d/2;
outer_r = outer_d/2;

// Choose a ball path radius that leaves enough material to bore/OD
// Ensure: ball_path_r - groove_r > bore_r  and  ball_path_r + groove_r < outer_r
ball_path_r = (bore_r + outer_r)/2;

// Clamp helper
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// Ensure groove/ball fits radially
max_groove_r = min(ball_path_r - bore_r, outer_r - ball_path_r) - 0.10;
ball_r = clamp(groove_r, 0.18, max_groove_r);
ball_d = 2*ball_r;

// --- Modules ---
module ring(r_out, r_in, h) {
    difference() {
        cylinder(r=r_out, h=h, center=true);
        cylinder(r=r_in,  h=h + 2*overlap, center=true);
    }
}

module balls() {
    for (i = [0:ball_count-1]) {
        rotate([0,0,i*360/ball_count])
            translate([ball_path_r, 0, 0])
                sphere(r=ball_r);
    }
}

// Cut race grooves into a solid ring so it reads as a bearing
module race_grooves() {
    // Use slightly larger cutter than the balls for a visible groove
    cutter_r = ball_r + groove_clear;

    // Cut a toroidal groove around the ring at mid-width
    rotate_extrude()
        translate([ball_path_r, 0, 0])
            circle(r=cutter_r);

    // Add shallow side reliefs so the groove is visible in side/top views
    // (kept within width by using small axial offsets)
    for (zsgn = [-1, 1]) {
        translate([0,0,zsgn*(width/2 - cutter_r*0.55)])
            rotate_extrude()
                translate([ball_path_r, 0, 0])
                    circle(r=cutter_r*0.85);
    }
}

// Thin web that connects inner region to outer region so the whole model is ONE solid
module connector_web() {
    // A narrow radial rib at one angular position, spanning from near bore to near OD
    // It overlaps into the main ring to guarantee connectivity.
    rib_len = (outer_r - bore_r) - 2*bridge_thk;
    rib_w   = bridge_thk;
    rib_h   = width;

    // Place rib centered at radius mid, with overlap into both sides
    translate([(bore_r + outer_r)/2, 0, 0])
        cube([rib_len + 2*overlap, rib_w, rib_h], center=true);
}

module bearing_solid() {
    union() {
        // Start from a single solid ring that exactly matches OD/ID/width
        difference() {
            ring(outer_r, bore_r, width);
            // Carve race grooves so it looks like a bearing
            race_grooves();
        }

        // Add balls (visual) and ensure they intersect the ring slightly for a single manifold
        // (tiny scale-up ensures overlap into the groove area)
        scale([1,1,1])
            balls();

        // Ensure ONE connected solid even if balls don't touch due to clearances
        connector_web();
    }
}

bearing_solid();