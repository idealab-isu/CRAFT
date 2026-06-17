$fn = 180;

// Threaded heat-set insert
// OD: 25.0 mm
// Length: 18.5 mm
// For 10.0 mm screws (M10x1.5 internal thread approximation)

od = 25.0;
len = 18.5;

// Thread (approx M10x1.5)
thread_major = 10.0;   // major diameter
pitch = 1.5;

// Lead-in / chamfers
end_chamfer = 0.8;     // external end chamfer height
thread_leadin = 1.2;   // internal lead-in countersink height

// External ribs (heat-set grip approximation)
rib_count = 36;
rib_depth = 0.6;       // radial groove depth
rib_width = 0.9;       // tangential groove width

// Internal thread modeling (more visible)
thread_depth = 0.75;       // radial depth of thread form
thread_clearance = 0.20;   // clearance for screw fit
thread_slices_per_turn = 96;

eps = 0.02;

module internal_thread_cut(L, major_d, pitch, depth, clearance) {
    // Subtractive volume: core + helical "tooth" cutter to create visible internal thread
    minor_d = major_d - 2*depth;
    turns = L / pitch;
    steps = max(48, ceil(turns * thread_slices_per_turn));
    twist_deg = -360 * turns;

    union() {
        // Core hole (minor diameter + clearance)
        translate([0,0,-eps])
            cylinder(h=L + 2*eps, d=minor_d + 2*clearance, center=false);

        // Helical cutter: a small trapezoid that reaches toward major diameter
        // Positioned so its inner edge starts at minor radius and extends outward by (depth+clearance)
        translate([0,0,-eps])
            linear_extrude(height=L + 2*eps, twist=twist_deg, slices=steps, convexity=30)
                translate([minor_d/2 + clearance, 0, 0])
                    polygon(points=[
                        [0,              -pitch*0.28],
                        [depth+clearance, -pitch*0.10],
                        [depth+clearance,  pitch*0.10],
                        [0,               pitch*0.28]
                    ]);
    }
}

module rib_grooves() {
    // Grooves to subtract (creates raised ribs)
    groove_len = len - 2*end_chamfer;
    groove_center_z = end_chamfer + groove_len/2;

    // Place grooves so they cut into the OD by rib_depth
    // Groove cube radial thickness = rib_depth, centered at radius (od/2 - rib_depth/2)
    groove_r = od/2 - rib_depth/2;

    for (i = [0 : rib_count-1]) {
        rotate([0,0, i*360/rib_count])
            translate([groove_r, 0, groove_center_z])
                cube([rib_depth, rib_width, groove_len + 2*eps], center=true);
    }
}

module insert_body() {
    difference() {
        // Outer solid (single connected body)
        cylinder(h=len, d=od, center=false);

        // External end chamfers (subtractive cones) - keep max OD at 25.0
        // Bottom chamfer
        translate([0,0,-eps])
            cylinder(h=end_chamfer + 2*eps, d1=od, d2=od - 2*end_chamfer, center=false);

        // Top chamfer
        translate([0,0,len - end_chamfer - eps])
            cylinder(h=end_chamfer + 2*eps, d1=od - 2*end_chamfer, d2=od, center=false);

        // Internal thread cut (full length)
        internal_thread_cut(len, thread_major, pitch, thread_depth, thread_clearance);

        // Internal lead-in countersinks (both ends)
        // Bottom lead-in
        translate([0,0,-eps])
            cylinder(h=thread_leadin + 2*eps,
                     d1=thread_major + 2.0,
                     d2=thread_major - 0.4,
                     center=false);

        // Top lead-in
        translate([0,0,len - thread_leadin - eps])
            cylinder(h=thread_leadin + 2*eps,
                     d1=thread_major - 0.4,
                     d2=thread_major + 2.0,
                     center=false);

        // External rib grooves
        rib_grooves();
    }
}

insert_body();