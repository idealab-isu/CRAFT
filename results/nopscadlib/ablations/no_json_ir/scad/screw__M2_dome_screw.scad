// Dome head screw: 2.0mm shaft diameter, 3.5mm head diameter, 1.3mm head height, 10mm overall length

$fn = 120;

// Key dimensions (mm)
shaft_d   = 2.0;
head_d    = 3.5;
head_h    = 1.3;
overall_L = 10.0;

// Derived
shaft_L = overall_L - head_h;   // from tip (z=0) to underside of head (z=shaft_L)
shaft_r = shaft_d/2;
head_r  = head_d/2;

// Spherical-cap dome that matches head_d and head_h
// Cap base lies on z=0, cap top at z=h
module dome_cap(d, h) {
    R  = ((d*d)/4 + h*h) / (2*h);  // sphere radius for given base diameter and cap height
    zc = h - R;                    // sphere center z so that top is at z=h
    intersection() {
        translate([0,0,zc]) sphere(r=R);
        cylinder(h=h, r=d/2, center=false);
    }
}

// External thread approximation: core + helical ridge (single connected solid)
module threaded_shaft(d, L, pitch=0.5, depth=0.18) {
    r = d/2;
    turns = L/pitch;

    union() {
        // core
        cylinder(h=L, r=max(r - depth, 0.01), center=false);

        // helical ridge
        linear_extrude(height=L, twist=turns*360, slices=max(ceil(turns*40), 80), convexity=10)
            translate([r - depth/2, 0, 0])
                circle(r=depth/2);
    }
}

module dome_head_screw() {
    // Use 1–2mm overlap to guarantee a solid connection between head and shaft
    overlap = 1.0;

    union() {
        // Shaft from z=0 up to slightly past the head underside (z=shaft_L)
        threaded_shaft(d=shaft_d, L=shaft_L + overlap, pitch=0.5, depth=0.18);

        // Dome head: base starts slightly below shaft_L so it intersects the shaft by 'overlap'
        translate([0,0,shaft_L - overlap])
            dome_cap(d=head_d, h=head_h + overlap);
    }
}

dome_head_screw();