// Screw parameters (requested)
shaft_diameter_mm = 5.0;
length_under_head_mm = 10.0;
head_diameter_mm = 9.0;
head_height_mm = 2.4;

// Thread appearance (visual only; major diameter remains shaft_diameter_mm)
thread_pitch_mm = 1.0;
thread_depth_mm = 0.35;     // radial depth (kept small so major dia stays 5.0)
thread_segments = 24;       // smoothness around
$fn = 96;

eps = 0.02;

// Helical thread made by twisting a small triangular ridge around the shaft.
// Major diameter stays at shaft_diameter_mm; minor diameter is reduced by 2*thread_depth_mm.
module threaded_shaft(d_major, len, pitch, depth) {
    r_major = d_major/2;
    r_minor = max(r_major - depth, 0.1);

    union() {
        // Core (minor diameter)
        cylinder(h=len, r=r_minor, center=false);

        // Helical ridge (thread)
        linear_extrude(height=len, twist=360*len/pitch, slices=max(ceil(len*12), 60), convexity=10)
            translate([r_minor, 0, 0])
                polygon(points=[
                    [0, -pitch*0.18],
                    [depth, 0],
                    [0,  pitch*0.18]
                ]);
    }
}

// Simple pan head with slight top chamfer
module screw_head(d, h) {
    r = d/2;
    chamfer = min(0.35, h*0.25);
    union() {
        cylinder(h=h - chamfer, r=r, center=false);
        translate([0,0,h - chamfer])
            cylinder(h=chamfer, r1=r, r2=max(r - chamfer, 0.1), center=false);
    }
}

// Full screw: head + threaded shaft, one connected solid
module screw() {
    union() {
        // Head sits from z=0..head_height_mm
        screw_head(head_diameter_mm, head_height_mm);

        // Shaft starts slightly inside head for guaranteed connectivity
        translate([0, 0, head_height_mm - eps])
            threaded_shaft(shaft_diameter_mm, length_under_head_mm + eps, thread_pitch_mm, thread_depth_mm);
    }
}

screw();