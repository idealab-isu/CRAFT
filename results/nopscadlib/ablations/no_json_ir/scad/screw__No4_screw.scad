$fn = 96;

// Target dimensions (mm)
shaft_diameter = 3.0;
overall_length  = 10.0;   // under-head to tip
head_diameter   = 5.5;
head_height     = 2.0;

// Visual thread (kept subtle; does not subtract material)
thread_pitch = 0.5;
thread_depth = 0.18;      // radial height of thread ridge (visual)
thread_width = 0.22;      // axial thickness of each ridge (visual)
thread_start = 0.6;       // leave a small unthreaded section under head

eps = 0.02;

// Rounded pan head (cylindrical with domed top)
module pan_head(d, h) {
    r = d/2;
    dome_h = min(h*0.65, r*0.55);          // dome height
    base_h = h - dome_h;

    union() {
        // cylindrical base
        cylinder(d=d, h=base_h, center=false);

        // domed top via rotate_extrude of a quarter-circle arc
        translate([0, 0, base_h])
            rotate_extrude(convexity=10)
                translate([r - dome_h, 0, 0])
                    circle(r=dome_h);
    }
}

// Simple external thread ridges (unioned so the model stays one solid)
module thread_ridges(major_d, length, pitch, depth, width, start_z=0) {
    major_r = major_d/2;
    minor_r = max(major_r - depth, 0.01);

    for (z = [start_z : pitch : length - width + eps]) {
        translate([0, 0, z])
            linear_extrude(height=width, twist=360*width/pitch, slices=12, convexity=10)
                difference() {
                    circle(r=major_r);
                    circle(r=minor_r);
                }
    }
}

module screw() {
    union() {
        // Shaft + visual thread
        union() {
            cylinder(d=shaft_diameter, h=overall_length, center=false);
            thread_ridges(
                major_d = shaft_diameter,
                length  = overall_length,
                pitch   = thread_pitch,
                depth   = thread_depth,
                width   = thread_width,
                start_z = thread_start
            );
        }

        // Head connected to shaft (slight overlap)
        translate([0, 0, overall_length - eps])
            pan_head(head_diameter, head_height);
    }
}

screw();