$fn=160;

// Heat-set insert (simplified) for M6 screw
// Outer diameter: 15.0 mm
// Length: 12.0 mm
// Internal thread: approximated as M6x1.0 (cosmetic helical cut)

outer_d = 15.0;
length  = 12.0;

m_nom_d = 6.0;      // nominal screw diameter
pitch   = 1.0;      // assumed M6 coarse pitch
clearance = 0.25;   // extra clearance for screw fit (mm)

bore_d = m_nom_d + clearance; // minor/bore diameter approximation

// Cosmetic thread parameters (subtractive helical groove)
thread_depth = 0.45;     // radial depth of groove (mm)
thread_width = 0.55;     // groove thickness (mm)
starts = 1;

module helical_groove(d_root, depth, pitch, h, width, starts=1) {
    // Creates a helical "cutter" around a cylinder of diameter d_root,
    // with groove depth extending outward by 'depth'.
    // Subtract this from the insert body to suggest internal threads.
    for (s = [0:starts-1]) {
        rotate([0,0,360*s/starts])
            linear_extrude(height=h, twist=360*h/pitch, slices=max(60, ceil(h*20)))
                translate([d_root/2, 0, 0])
                    square([depth, width], center=true);
    }
}

module insert() {
    difference() {
        // Outer body
        cylinder(d=outer_d, h=length);

        // Through bore
        translate([0,0,-0.2])
            cylinder(d=bore_d, h=length+0.4);

        // Cosmetic internal thread groove (cut into bore wall)
        // Root diameter is the bore diameter; groove extends outward into the body.
        translate([0,0,0])
            helical_groove(d_root=bore_d, depth=thread_depth, pitch=pitch, h=length, width=thread_width, starts=starts);

        // Small lead-in chamfers (both ends)
        translate([0,0,-0.01])
            cylinder(d1=bore_d+1.2, d2=bore_d, h=0.8);
        translate([0,0,length-0.79])
            cylinder(d1=bore_d, d2=bore_d+1.2, h=0.8);
    }
}

insert();