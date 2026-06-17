$fn = 220;

// Threaded heat-set insert
// Outer diameter: 30.0 mm
// Length: 25.0 mm
// For 16.0 mm screws (internal thread major diameter ~16 mm)

outer_d = 30.0;
length  = 25.0;

screw_d = 16.0;

// Thread (approx. M16 coarse-ish)
pitch = 2.0;
thread_depth = 0.65 * pitch;                 // radial depth
minor_d = screw_d - 2*thread_depth;          // minor diameter

// Chamfers
outer_chamfer = 1.2;
inner_chamfer = 1.0;

// External heat-set grip (diamond knurl)
knurl_count = 60;        // around circumference
knurl_depth = 0.8;       // radial protrusion
knurl_w     = 1.2;       // tangential width of each ridge
knurl_band_margin = 1.5; // smooth margins at ends
knurl_twist = 22;        // degrees of helix over band height (each direction)

// Small overlap to ensure watertight unions/differences
eps = 0.05;

module insert_outer() {
    // Outer cylinder with end chamfers (made by subtracting cones)
    difference() {
        cylinder(d=outer_d, h=length);

        // Bottom chamfer cut
        translate([0,0,-eps])
            cylinder(d1=outer_d-2*outer_chamfer, d2=outer_d, h=outer_chamfer+2*eps);

        // Top chamfer cut
        translate([0,0,length-outer_chamfer-eps])
            cylinder(d1=outer_d, d2=outer_d-2*outer_chamfer, h=outer_chamfer+2*eps);
    }
}

module knurl_ridges(helix_sign=1) {
    // Helical ridges that protrude outward and overlap into the body for connectivity
    band_h = length - 2*knurl_band_margin;
    ridge_h = band_h + 2*eps;

    // Place ridges so they overlap INTO the body by ~half their depth
    r_center = outer_d/2 - knurl_depth/2;

    for (i=[0:knurl_count-1]) {
        a = 360*i/knurl_count;
        rotate([0,0,a])
            translate([r_center, 0, knurl_band_margin + band_h/2])
                linear_extrude(height=ridge_h, center=true, twist=helix_sign*knurl_twist, slices=80, convexity=10)
                    square([knurl_depth + 2*eps, knurl_w], center=true);
    }
}

module internal_thread_cut(major_d, minor_d, pitch, h) {
    // Subtractive helical wedge that creates visible internal threading
    turns = h / pitch;
    r_major = major_d/2;
    r_minor = minor_d/2;
    depth   = r_major - r_minor;

    // Wider profile for clearer thread visibility
    w = pitch * 0.75;

    linear_extrude(height=h + 2*eps,
                   twist=-360*turns,
                   slices=max(ceil(turns*180), 180),
                   convexity=10)
        polygon(points=[
            [r_major + eps, -w],
            [r_major - depth - eps, 0],
            [r_major + eps,  w]
        ]);
}

module heat_set_insert() {
    difference() {
        // ONE connected solid: outer body + diamond knurl (two opposing helices)
        union() {
            insert_outer();
            knurl_ridges(helix_sign= 1);
            knurl_ridges(helix_sign=-1);
        }

        // Base bore at minor diameter (ensures through-hole)
        translate([0,0,-eps])
            cylinder(d=minor_d, h=length + 2*eps);

        // Thread cut (subtract) — extend slightly for clean ends
        translate([0,0,-eps])
            internal_thread_cut(major_d=screw_d, minor_d=minor_d, pitch=pitch, h=length);

        // Inner lead-in chamfers (both ends)
        translate([0,0,-eps])
            cylinder(d1=screw_d + 2*inner_chamfer, d2=minor_d, h=inner_chamfer + 2*eps);

        translate([0,0,length - inner_chamfer - eps])
            cylinder(d1=minor_d, d2=screw_d + 2*inner_chamfer, h=inner_chamfer + 2*eps);
    }
}

heat_set_insert();