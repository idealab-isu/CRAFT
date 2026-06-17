$fn = 96;

// Sheet dimensions (mm)
length = 200;
width  = 120;
thickness = 2;

// Corner radius
corner_radius = 3;

// Carbon weave relief (make it read clearly)
weave_amp   = 0.28;   // raised height
weave_pitch = 5.0;    // spacing between strands
weave_w     = 1.8;    // strand width
weave_overlap = 0.06; // overlap into base to guarantee one connected solid

module rounded_sheet(l, w, t, r){
    r2 = min(r, l/2, w/2);
    linear_extrude(height=t, convexity=10)
        offset(r=r2)
            square([l - 2*r2, w - 2*r2], center=true);
}

module rounded_mask_2d(l, w, r){
    r2 = min(r, l/2, w/2);
    offset(r=r2)
        square([l - 2*r2, w - 2*r2], center=true);
}

module weave_relief(l, w, amp, pitch, strand_w, r){
    module mask2d() rounded_mask_2d(l, w, r);

    // Build a true "basket weave" look by combining two stripe families
    // and adding a slight phase offset so it doesn't read as a single diagonal.
    module stripes2d(angle, phase){
        span = max(l, w) * 4;
        n = ceil(span / pitch) + 4;
        union(){
            for (i = [-n:n]){
                translate([i*pitch + phase, 0])
                    rotate(angle)
                        square([strand_w, span], center=true);
            }
        }
    }

    module weave2d(){
        union(){
            stripes2d( 45, 0);
            stripes2d(-45, pitch/2);
            // Add a second, thinner set to suggest alternating tow bundles
            stripes2d( 45, pitch/2);
            stripes2d(-45, 0);
        }
    }

    linear_extrude(height=amp, convexity=10)
        intersection(){
            mask2d();
            weave2d();
        }
}

// One connected solid: base + top relief + bottom relief, all overlapping into base
color([0.07, 0.07, 0.08])
union(){
    // Base sheet centered at Z=0 for consistent views
    translate([0, 0, -thickness/2])
        rounded_sheet(length, width, thickness, corner_radius);

    // Top weave: sits on top surface and overlaps into base
    translate([0, 0, thickness/2 - weave_overlap])
        weave_relief(length, width, weave_amp, weave_pitch, weave_w, corner_radius);

    // Bottom weave: sits on bottom surface and overlaps into base
    translate([0, 0, -thickness/2 - weave_amp + weave_overlap])
        weave_relief(length, width, weave_amp, weave_pitch, weave_w, corner_radius);
}