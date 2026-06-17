// Standoff pillar with external M2-style thread
// Spec: 2.0mm thread (major dia), 16.0mm long, 3.17mm diameter body
// One connected solid; all placements are formula-based.

$fn = 128;

// Parameters
length = 16.0;                 // overall length (Z)
outer_diameter = 3.17;         // body diameter
thread_major_diameter = 2.0;   // thread major diameter (external)
thread_pitch = 0.4;            // pitch (approx for M2)
thread_depth = 0.18;           // radial thread height (visual/printable)
thread_length = 16.0;          // threaded length (full length)
chamfer_length = 0.5;          // end chamfer length
epsilon = 0.03;                // small overlap to ensure watertight unions

// Derived
body_r = outer_diameter/2;
thread_r_major = thread_major_diameter/2;
thread_r_minor = thread_r_major - thread_depth;

// Helical external thread as a swept triangular ridge around a core cylinder.
// Uses rotate_extrude of a 2D profile offset from the Z axis, then linear_extrude with twist.
module external_thread(maj_d, pitch, depth, len) {
    r_maj = maj_d/2;
    r_min = r_maj - depth;

    turns = len / pitch;
    twist_deg = 360 * turns;
    slices = max(ceil(turns * 80), 200);

    // 2D profile in XY for rotate_extrude:
    // A small triangle that spans from r_min to r_maj.
    // Its "height" in Y is proportional to pitch to resemble a thread flank.
    tooth_y = pitch * 0.30;

    linear_extrude(height=len, twist=twist_deg, slices=slices, convexity=10)
        rotate_extrude(angle=360, convexity=10)
            polygon(points=[
                [r_min, -tooth_y],
                [r_maj,  0],
                [r_min,  tooth_y]
            ]);
}

// Main model
module standoff() {
    union() {
        // Body cylinder (centered)
        cylinder(h=length, r=body_r, center=true);

        // Thread core cylinder to ensure the helical ridge is connected everywhere
        // (minor diameter cylinder, slightly longer for overlap)
        cylinder(h=thread_length + 2*epsilon, r=thread_r_minor, center=true);

        // External helical ridge (thread), centered and overlapped
        translate([0, 0, -thread_length/2 - epsilon])
            external_thread(thread_major_diameter, thread_pitch, thread_depth, thread_length + 2*epsilon);

        // End chamfers (overlapping, not floating)
        translate([0, 0,  length/2 - chamfer_length/2])
            cylinder(h=chamfer_length + epsilon, r1=body_r, r2=max(body_r - chamfer_length, 0.01), center=true);

        translate([0, 0, -length/2 + chamfer_length/2])
            cylinder(h=chamfer_length + epsilon, r1=max(body_r - chamfer_length, 0.01), r2=body_r, center=true);
    }
}

color("Silver") standoff();