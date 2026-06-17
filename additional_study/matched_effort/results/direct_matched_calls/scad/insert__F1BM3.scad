$fn = 128;

// Heat-set insert (simplified): knurled outer cylinder + internal threaded hole (approx).
// Dimensions from prompt:
od = 5.8;          // outer diameter (mm)
len = 4.6;         // length (mm)
screw_d = 3.0;     // for M3 screw

// Assumptions / approximations (common for M3 heat-set inserts):
// - Internal thread modeled as a helical cut with 60° profile, pitch ~0.5mm (M3 coarse).
// - Minor diameter chosen to be printable and reasonable for M3: ~2.5mm.
// - Lead-in chamfers on both ends.
pitch = 0.5;
minor_d = 2.5;
thread_depth = (screw_d - minor_d) / 2; // radial depth
thread_angle = 60; // degrees

// Outer knurl approximation
knurl_count = 24;
knurl_depth = 0.25; // radial
knurl_twist = 25;   // degrees over length

// Chamfers
chamfer = 0.35;

module chamfered_cylinder(d, h, c) {
    // c = chamfer height on each end
    union() {
        // middle
        translate([0,0,c])
            cylinder(d=d, h=max(0, h-2*c));
        // bottom chamfer
        cylinder(d1=d-2*c, d2=d, h=c);
        // top chamfer
        translate([0,0,h-c])
            cylinder(d1=d, d2=d-2*c, h=c);
    }
}

module knurled_shell(d, h, depth, n, twist_deg) {
    // Base cylinder plus twisted flutes cut in
    difference() {
        chamfered_cylinder(d=d, h=h, c=chamfer);

        // Cut flutes
        for (i = [0:n-1]) {
            rotate([0,0, i*360/n])
                translate([d/2 - depth/2, 0, 0])
                    linear_extrude(height=h, twist=twist_deg, slices=80, convexity=10)
                        square([depth, d], center=true);
        }
    }
}

module internal_thread_cut(h, major_d, depth, pitch, angle=60) {
    // Helical triangular profile cut (approx ISO 60°)
    turns = h / pitch;
    // Triangle height for 60°: depth relates to half-angle
    // Use a simple isosceles triangle with radial height = depth
    tri_h = depth;
    tri_w = 2 * tri_h / tan(angle/2); // along Z in profile plane (approx)
    // Place profile at radius = (major_d/2 - depth)
    r = major_d/2 - depth;

    linear_extrude(height=h, twist=turns*360, slices=ceil(turns*80), convexity=10)
        translate([r, 0, 0])
            polygon(points=[
                [0, -tri_w/2],
                [tri_h, 0],
                [0,  tri_w/2]
            ]);
}

module insert() {
    difference() {
        // Outer body with knurl
        knurled_shell(d=od, h=len, depth=knurl_depth, n=knurl_count, twist_deg=knurl_twist);

        // Through hole (minor diameter)
        translate([0,0,-0.2])
            cylinder(d=minor_d, h=len+0.4);

        // Thread cut (major diameter ~ screw_d)
        // Slightly inset from ends to preserve chamfers
        translate([0,0,0.15])
            internal_thread_cut(h=len-0.3, major_d=screw_d, depth=thread_depth, pitch=pitch, angle=thread_angle);
    }
}

insert();