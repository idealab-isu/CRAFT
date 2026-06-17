$fn=128;

// Heat-set insert (approximation)
// Outer diameter: 8.2mm
// Length: 6.3mm
// For 4.0mm screws (internal thread approximated as a straight bore)

od = 8.2;
len = 6.3;

// Typical M4 clearance/minor-ish bore for insert; adjust as needed
id = 4.2;

// Knurling approximation
knurl_depth = 0.35;     // radial depth of knurl cuts
knurl_pitch = 1.0;      // axial spacing between knurl bands
knurl_twist = 22;       // degrees of twist per band (visual approximation)
knurl_band_h = 0.55;    // height of each knurl band
knurl_gap = 0.45;       // gap between bands

// Lead-in chamfers
chamfer_h = 0.6;
chamfer_delta = 0.6;    // radial reduction at ends

module insert_body() {
    // Base cylinder with slight end chamfers
    union() {
        // Main section
        translate([0,0,chamfer_h])
            cylinder(h=len-2*chamfer_h, d=od);

        // Bottom chamfer
        cylinder(h=chamfer_h, d1=od-2*chamfer_delta, d2=od);

        // Top chamfer
        translate([0,0,len-chamfer_h])
            cylinder(h=chamfer_h, d1=od, d2=od-2*chamfer_delta);
    }
}

module knurl_cuts() {
    // Create a series of twisted "bands" that will be subtracted to mimic knurling
    // Each band is a thin ring with a twisted square profile.
    n = floor((len - 2*chamfer_h) / knurl_pitch);
    for (i = [0:n-1]) {
        z0 = chamfer_h + i*knurl_pitch + (knurl_pitch - knurl_band_h)/2;
        translate([0,0,z0])
            linear_extrude(height=knurl_band_h, twist=knurl_twist, slices=24)
                difference() {
                    circle(d=od + 0.01);
                    circle(d=od - 2*knurl_depth);
                }
    }
}

difference() {
    // Outer with knurling removed
    difference() {
        insert_body();
        knurl_cuts();
    }

    // Internal bore (thread not modeled; straight hole)
    translate([0,0,-0.2])
        cylinder(h=len+0.4, d=id);

    // Slight countersink/lead-in on both ends for screw start
    translate([0,0,-0.01])
        cylinder(h=0.8, d1=id+1.2, d2=id);

    translate([0,0,len-0.79])
        cylinder(h=0.8, d1=id, d2=id+1.2);
}