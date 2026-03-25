// M2.5 Pan Head Screw (single connected solid)
// Target: 2.5mm shank diameter, 4.7mm head diameter, 1.7mm head height, 10mm overall length

shaft_diameter_mm = 2.5;
length_mm         = 10;
head_diameter_mm  = 4.7;
head_height_mm    = 1.7;

// Visual detail controls (kept modest for robustness)
thread_pitch_mm   = 0.45;   // visual approximation
thread_depth_mm   = 0.16;   // radial depth
thread_fn         = 96;
head_fn           = 128;
overlap_mm        = 0.06;

module helical_thread(major_d, pitch, depth, len) {
    turns  = len / pitch;
    slices = max(ceil(turns * 36), 120);

    // External thread approximation: helical ridge added to a core cylinder
    union() {
        // Core (minor diameter)
        cylinder(d=max(major_d - 2*depth, 0.01), h=len, $fn=thread_fn);

        // Helical ridge (added)
        linear_extrude(height=len, twist=360*turns, slices=slices, convexity=10)
            translate([major_d/2 - depth, 0, 0])
                circle(r=depth, $fn=24);
    }
}

module pan_head(d, h) {
    // Pan head: cylindrical skirt + domed top (spherical cap)
    skirt_h = h * 0.55;
    dome_h  = h - skirt_h;

    union() {
        // Skirt
        cylinder(d=d, h=skirt_h, $fn=head_fn);

        // Dome: intersection of sphere and cylinder to keep diameter
        translate([0, 0, skirt_h - overlap_mm])
            intersection() {
                translate([0, 0, dome_h])
                    sphere(r=d*0.60, $fn=head_fn);
                cylinder(d=d, h=dome_h + 2*overlap_mm, $fn=head_fn);
            }
    }
}

module screw_m25_pan(L, shank_d, head_d, head_h) {
    shank_len = max(L - head_h, 0.01);

    union() {
        // Threaded shank from z=0 to z=shank_len
        helical_thread(major_d=shank_d, pitch=thread_pitch_mm, depth=thread_depth_mm, len=shank_len);

        // Pan head on top, connected with calculated overlap
        translate([0, 0, shank_len - overlap_mm])
            pan_head(d=head_d, h=head_h);
    }
}

screw_m25_pan(length_mm, shaft_diameter_mm, head_diameter_mm, head_height_mm);