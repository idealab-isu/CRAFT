// Fast-render threaded heat-set insert (approx)
// OD=12mm, L=10mm, internal M5x0.8 visual approximation

$fn = 48;

od    = 12.0;
len   = 10.0;

m_nom = 5.0;
pitch = 0.8;

// Internal thread sizing (approx clearance for printing)
major_clear  = 0.25;   // radial clearance at major
thread_depth = 0.55;   // radial depth of thread groove
minor_clear  = 0.10;   // extra clearance on minor

r_outer        = od/2;
r_thread_major = (m_nom/2) + major_clear;
r_thread_minor = r_thread_major - thread_depth - minor_clear;

// Simplified outer knurl (fast): straight axial ribs instead of crossed helical ribs
rib_h      = 0.35;     // rib radial height
rib_w      = 0.55;     // rib tangential width
rib_count  = 24;       // ribs around circumference

// End chamfers (kept simple)
ch     = 0.6;
ch_rad = 0.6;

eps = 0.02;

module base_cylinder_with_chamfers() {
    union() {
        translate([0,0,ch])
            cylinder(h=max(len-2*ch, 0), r=r_outer, center=false);

        cylinder(h=ch, r1=r_outer - ch_rad, r2=r_outer, center=false);

        translate([0,0,len-ch])
            cylinder(h=ch, r1=r_outer, r2=r_outer - ch_rad, center=false);
    }
}

module outer_ribs_straight() {
    // Add small ribs, then clip with base envelope to keep OD exact
    overlap_in = 0.25;
    rib_len_rad = rib_h + overlap_in;

    for (i = [0 : rib_count-1]) {
        rotate([0,0, i*360/rib_count])
            translate([r_outer - overlap_in, 0, 0])
                linear_extrude(height=len, convexity=4)
                    square([rib_len_rad, rib_w], center=true);
    }
}

module outer_knurled_body() {
    intersection() {
        union() {
            base_cylinder_with_chamfers();
            outer_ribs_straight();
        }
        base_cylinder_with_chamfers();
    }
}

module bore_minor() {
    translate([0,0,-eps])
        cylinder(h=len + 2*eps, r=r_thread_minor, center=false);
}

module internal_thread_cut() {
    // Helical groove cut: triangular wedge profile extruded with twist
    // Reduced slices for speed
    turns = len / pitch;
    twist_deg = 360 * turns;
    slices = max(ceil(turns * 24), 96);

    w = pitch * 0.60; // thread thickness (visual)
    d = (r_thread_major - r_thread_minor);

    translate([0,0,-eps])
        linear_extrude(height=len + 2*eps, twist=twist_deg, slices=slices, convexity=6)
            translate([r_thread_major, 0])
                polygon(points=[
                    [0, -w/2],
                    [-d, 0],
                    [0,  w/2]
                ]);
}

difference() {
    outer_knurled_body();
    bore_minor();
    internal_thread_cut();
}