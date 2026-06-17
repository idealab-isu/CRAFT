// Ball bearing: 3.0mm bore, 8.0mm outer diameter, 3.0mm width
// Single connected solid (rings + balls fused by tiny bridges)

$fn = 128;

// Required dimensions
bore_d  = 3.0;
outer_d = 8.0;
width   = 3.0;

// Visual/feature parameters (kept within available radial space)
ring_radial_thk = 1.0;     // ring thickness (radial)
ball_d          = 1.0;     // ball diameter
ball_count      = 7;

// Small values
eps     = 0.02;            // boolean robustness
bridge  = 0.12;            // tiny connectors to ensure ONE connected solid

// Derived radii
bore_r  = bore_d/2;
outer_r = outer_d/2;

// Ring radii
inner_ring_or = bore_r + ring_radial_thk;     // inner ring outer radius
outer_ring_ir = outer_r - ring_radial_thk;    // outer ring inner radius

// Ball path radius (midway between race faces)
ball_path_r = (inner_ring_or + outer_ring_ir)/2;

// Raceway groove (subtractive) size
groove_r = min(0.55, (outer_ring_ir - inner_ring_or)/2 - 0.05);
groove_r = max(groove_r, 0.25);

// Helper: torus-like groove made by rotate_extrude of a circle
module groove_torus(r_path, r_groove) {
    rotate_extrude(angle=360)
        translate([r_path, 0, 0])
            circle(r=r_groove);
}

// Rings with raceway grooves
module rings() {
    difference() {
        // Base rings (connected only via bridges later)
        union() {
            // Outer ring
            difference() {
                cylinder(r=outer_r, h=width, center=true);
                cylinder(r=outer_ring_ir, h=width + 2*eps, center=true);
            }
            // Inner ring
            difference() {
                cylinder(r=inner_ring_or, h=width, center=true);
                cylinder(r=bore_r, h=width + 2*eps, center=true);
            }
        }

        // Cut grooves into both rings (slightly inset from faces)
        // Outer ring groove
        groove_torus(ball_path_r, groove_r);

        // Inner ring groove (same torus removes from inner ring too)
        // (Using same groove gives a typical deep-groove look)
    }
}

// Balls
module balls() {
    for (i = [0:ball_count-1]) {
        angle = i * 360/ball_count;
        rotate([0,0,angle])
            translate([ball_path_r, 0, 0])
                sphere(r=ball_d/2);
    }
}

// Tiny bridges to guarantee a single connected solid (do not change OD/ID/width)
module connectivity_bridges() {
    // Bridge from each ball to inner ring and outer ring (radial direction)
    // Positioned at mid-plane so width remains exactly 'width'
    for (i = [0:ball_count-1]) {
        angle = i * 360/ball_count;

        // Inner bridge: from ball toward inner ring outer surface
        rotate([0,0,angle])
            translate([(ball_path_r + inner_ring_or)/2, 0, 0])
                cube([ball_path_r - inner_ring_or + bridge, bridge, bridge], center=true);

        // Outer bridge: from ball toward outer ring inner surface
        rotate([0,0,angle])
            translate([(ball_path_r + outer_ring_ir)/2, 0, 0])
                cube([outer_ring_ir - ball_path_r + bridge, bridge, bridge], center=true);
    }
}

// Final bearing (ONE connected solid)
union() {
    rings();
    balls();
    connectivity_bridges();
}