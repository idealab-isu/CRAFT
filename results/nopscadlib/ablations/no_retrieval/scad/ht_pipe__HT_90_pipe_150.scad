// HT 90° elbow pipe (DN150) - single connected solid
// Units: mm

$fn = 128;

// Parameters (DN150 typical)
nominal_diameter      = 150;   // informational
outer_diameter        = 160;   // OD of pipe barrel
wall_thickness        = 4;     // wall
centerline_radius     = 150;   // CLR of elbow
bend_angle            = 90;    // degrees
straight_end_length   = 60;    // straight barrel length beyond tangent (each end)

socket_outer_diameter = 170;   // OD of socket (muff)
socket_length         = 70;    // socket length
socket_stop_thickness = 3;     // internal stop ring thickness (axial)
socket_stop_height    = 2;     // radial height of stop ring (reduces ID locally)

chamfer_depth         = 2;     // lead-in chamfer depth
overlap               = 0.8;   // small overlap to guarantee watertight unions/differences

// Derived
pipe_ro = outer_diameter/2;
pipe_ri = pipe_ro - wall_thickness;

sock_ro = socket_outer_diameter/2;
sock_ri = pipe_ri; // socket ID matches pipe ID (simplified)

// Helper: torus segment (outer/inner) around Z axis, centered at origin
module torus_segment(R, r, ang) {
    rotate_extrude(angle=ang, convexity=10)
        translate([R, 0, 0])
            circle(r=r);
}

// Helper: straight tube along +X axis, starting at x=0
module tube_x(len, ro, ri) {
    difference() {
        translate([len/2, 0, 0]) cylinder(h=len, r=ro, center=true);
        translate([len/2, 0, 0]) cylinder(h=len + 2*overlap, r=ri, center=true);
    }
}

// Helper: straight tube along +Y axis, starting at y=0
module tube_y(len, ro, ri) {
    difference() {
        translate([0, len/2, 0]) cylinder(h=len, r=ro, center=true);
        translate([0, len/2, 0]) cylinder(h=len + 2*overlap, r=ri, center=true);
    }
}

// Socket (outer sleeve) along +X axis, starting at x=0
module socket_x(len, ro, ri) {
    difference() {
        translate([len/2, 0, 0]) cylinder(h=len, r=ro, center=true);
        translate([len/2, 0, 0]) cylinder(h=len + 2*overlap, r=ri, center=true);
    }
}

// Socket (outer sleeve) along +Y axis, starting at y=0
module socket_y(len, ro, ri) {
    difference() {
        translate([0, len/2, 0]) cylinder(h=len, r=ro, center=true);
        translate([0, len/2, 0]) cylinder(h=len + 2*overlap, r=ri, center=true);
    }
}

// Internal stop ring (reduces ID locally) along +X axis, located at distance "at" from socket mouth
module stop_ring_x(at, thick, ri, height) {
    // ring occupies x in [at-thick, at]
    difference() {
        translate([at - thick/2, 0, 0]) cylinder(h=thick, r=ri, center=true);
        translate([at - thick/2, 0, 0]) cylinder(h=thick + 2*overlap, r=ri - height, center=true);
    }
}

// Internal stop ring along +Y axis
module stop_ring_y(at, thick, ri, height) {
    difference() {
        translate([0, at - thick/2, 0]) cylinder(h=thick, r=ri, center=true);
        translate([0, at - thick/2, 0]) cylinder(h=thick + 2*overlap, r=ri - height, center=true);
    }
}

// Simple internal chamfer cut at socket mouth along +X axis
module chamfer_cut_x(depth, ro) {
    // cone removes material at mouth (x=0)
    translate([depth/2 - overlap, 0, 0])
        rotate([0, 90, 0])
            cylinder(h=depth + 2*overlap, r1=ro + overlap, r2=0, center=true);
}

// Simple internal chamfer cut at socket mouth along +Y axis
module chamfer_cut_y(depth, ro) {
    translate([0, depth/2 - overlap, 0])
        rotate([-90, 0, 0])
            cylinder(h=depth + 2*overlap, r1=ro + overlap, r2=0, center=true);
}

// Main elbow: centerline starts at (R,0,0) heading +Y, ends at (0,R,0) heading -X
module elbow_shell() {
    difference() {
        // Outer
        union() {
            // 90° bend
            torus_segment(centerline_radius, pipe_ro, bend_angle);

            // Straight barrels beyond tangents (connected)
            // Start tangent at angle 0: point (R,0,0), direction +Y
            translate([centerline_radius, 0, 0])
                tube_y(straight_end_length, pipe_ro, pipe_ri);

            // End tangent at angle 90: point (0,R,0), direction -X
            // Build along +X then mirror to -X by rotating 180° about Z
            translate([0, centerline_radius, 0])
                rotate([0, 0, 180])
                    tube_x(straight_end_length, pipe_ro, pipe_ri);

            // Sockets at both ends (connected, coaxial with barrels)
            // Socket at start end (extends further +Y from start tangent)
            translate([centerline_radius, straight_end_length - overlap, 0])
                socket_y(socket_length, sock_ro, sock_ri);

            // Socket at end (extends further -X from end tangent)
            translate([-straight_end_length + overlap, centerline_radius, 0])
                rotate([0, 0, 180])
                    socket_x(socket_length, sock_ro, sock_ri);
        }

        // Bore through bend and barrels (continuous)
        union() {
            // Bend bore
            torus_segment(centerline_radius, pipe_ri, bend_angle);

            // Straight bores beyond tangents
            translate([centerline_radius, 0, 0])
                translate([0, straight_end_length/2, 0])
                    cylinder(h=straight_end_length + 2*overlap, r=pipe_ri, center=true);

            translate([0, centerline_radius, 0])
                rotate([0, 0, 180])
                    translate([straight_end_length/2, 0, 0])
                        cylinder(h=straight_end_length + 2*overlap, r=pipe_ri, center=true);

            // Socket bores (same as sock_ri)
            translate([centerline_radius, straight_end_length - overlap, 0])
                translate([0, socket_length/2, 0])
                    cylinder(h=socket_length + 2*overlap, r=sock_ri, center=true);

            translate([-straight_end_length + overlap, centerline_radius, 0])
                rotate([0, 0, 180])
                    translate([socket_length/2, 0, 0])
                        cylinder(h=socket_length + 2*overlap, r=sock_ri, center=true);

            // Chamfer cuts at socket mouths
            translate([centerline_radius, straight_end_length - overlap, 0])
                chamfer_cut_y(chamfer_depth, sock_ro);

            translate([-straight_end_length + overlap, centerline_radius, 0])
                rotate([0, 0, 180])
                    chamfer_cut_x(chamfer_depth, sock_ro);
        }
    }
}

// Add internal stop rings (as solid features) so they remain after bore subtraction
module elbow_with_stops() {
    union() {
        elbow_shell();

        // Stop ring positions measured from socket mouth inward
        // Place near inner end of socket
        stop_at = socket_length - socket_stop_thickness;

        // Start socket stop (along +Y)
        translate([centerline_radius, straight_end_length - overlap, 0])
            stop_ring_y(stop_at, socket_stop_thickness, sock_ri, socket_stop_height);

        // End socket stop (along -X)
        translate([-straight_end_length + overlap, centerline_radius, 0])
            rotate([0, 0, 180])
                stop_ring_x(stop_at, socket_stop_thickness, sock_ri, socket_stop_height);
    }
}

// Final output: one connected solid
elbow_with_stops();