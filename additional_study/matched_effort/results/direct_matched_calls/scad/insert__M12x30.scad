$fn = 180;

// Threaded heat-set insert (simplified, renderable model)
// Specs from prompt:
// - Outer diameter: 30.0 mm
// - Length: 22.0 mm
// - For 12.0 mm screws (modeled as internal clearance hole ~12.0 mm)
//
// Note: Real heat-set inserts have knurls/barbs and internal threads.
// This model approximates the exterior with shallow helical knurling
// and the interior as a straight bore sized for a 12 mm screw.

outer_d = 30.0;
length  = 22.0;

// Internal bore (for 12 mm screw). Adjust if you want tap-drill or thread minor diameter.
inner_d = 12.0;

// Knurling parameters (purely visual/approximate)
knurl_depth = 0.8;     // radial depth of grooves
knurl_pitch = 3.0;     // mm per revolution
knurl_starts = 2;      // number of helical grooves
knurl_width = 1.2;     // groove width (approx)

// Chamfers
chamfer_h = 1.2;
chamfer_inset = 1.0;

// Small clearance to avoid coincident faces
eps = 0.02;

module chamfered_cylinder(d, h, ch_h, ch_inset) {
    // Main body with simple 45-ish chamfers at both ends
    union() {
        // center section
        translate([0,0,ch_h])
            cylinder(d=d, h=h-2*ch_h);

        // bottom chamfer
        cylinder(h=ch_h, d1=d-2*ch_inset, d2=d);

        // top chamfer
        translate([0,0,h-ch_h])
            cylinder(h=ch_h, d1=d, d2=d-2*ch_inset);
    }
}

module helical_groove(r_mid, h, pitch, width, depth, phase_deg=0) {
    // Creates a helical "cutter" by twisting a small rectangular prism around Z.
    // Subtract this from the body to form a groove.
    turns = h / pitch;
    twist = 360 * turns;

    // Place cutter at radius so it intersects the surface by 'depth'
    // The cutter thickness in radial direction is depth*2 to ensure full cut.
    translate([0,0,0])
        rotate([0,0,phase_deg])
            linear_extrude(height=h, twist=twist, slices=max(ceil(h*6), 60), convexity=10)
                translate([r_mid, 0, 0])
                    square([depth*2, width], center=true);
}

module insert() {
    difference() {
        // Outer body
        chamfered_cylinder(outer_d, length, chamfer_h, chamfer_inset);

        // Internal bore
        translate([0,0,-eps])
            cylinder(d=inner_d, h=length+2*eps);

        // Helical knurl grooves (subtract)
        // r_mid chosen so groove cuts into outer surface by ~depth
        r_mid = outer_d/2 - knurl_depth;
        for (i = [0:knurl_starts-1]) {
            helical_groove(r_mid=r_mid, h=length, pitch=knurl_pitch, width=knurl_width, depth=knurl_depth, phase_deg=360*i/knurl_starts);
        }

        // Add a second set with opposite twist by mirroring twist direction:
        // Achieved by flipping the cutter in Y and using same twist.
        // This creates a cross-hatch style knurl.
        for (i = [0:knurl_starts-1]) {
            mirror([0,1,0])
                helical_groove(r_mid=r_mid, h=length, pitch=knurl_pitch, width=knurl_width, depth=knurl_depth, phase_deg=360*i/knurl_starts + 180/knurl_starts);
        }
    }
}

insert();