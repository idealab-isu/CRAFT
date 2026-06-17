$fn=180;

// Threaded heat-set insert (simplified, renderable)
// Outer diameter: 25.0 mm
// Length: 18.5 mm
// For 10.0 mm screws (approx. M10 internal thread)

outer_d = 25.0;
length  = 18.5;

inner_thread_major_d = 10.0;   // nominal screw size
thread_pitch = 1.5;            // typical M10 coarse pitch
thread_depth = 0.65;           // approximate thread depth (radial)
thread_clearance = 0.25;       // extra clearance for printable internal thread

lead_in = 1.2;                 // chamfer/lead-in length
knurl_depth = 0.6;             // radial knurl depth
knurl_count = 36;              // number of knurl flutes around circumference

module internal_thread(d_major, pitch, depth, len, clearance=0.0) {
    // Creates an internal thread by subtracting a helical "tooth" from a cylinder.
    // This is a simplified triangular thread form.
    turns = len / pitch;

    d_root = d_major - 2*depth;
    // Base hole cylinder (root diameter) to ensure through-hole
    union() {
        cylinder(h=len, d=d_root + 2*clearance, center=false);

        // Helical tooth to be subtracted from the hole to form internal thread
        // We build a helical ridge at approximately the major diameter.
        // Cross-section is a small triangle.
        translate([0,0,0])
        linear_extrude(height=len, twist=-360*turns, slices=max(ceil(turns*40), 80), center=false, convexity=10)
            translate([ (d_root/2 + clearance), 0, 0 ])
                polygon(points=[
                    [0, -pitch*0.28],
                    [depth, 0],
                    [0,  pitch*0.28]
                ]);
    }
}

module heat_set_insert() {
    difference() {
        // Outer body with knurl-like flutes
        union() {
            // Main cylinder
            cylinder(h=length, d=outer_d);

            // Add shallow ribs (negative knurl will be cut later)
        }

        // Knurl flutes (cut into outer surface)
        for (i = [0:knurl_count-1]) {
            rotate([0,0, i*360/knurl_count])
                translate([outer_d/2 - knurl_depth/2, 0, length/2])
                    cube([knurl_depth, outer_d*0.12, length+0.2], center=true);
        }

        // Internal threaded hole (subtract)
        // Make a slightly longer cutter to ensure clean ends
        translate([0,0,-0.2])
            internal_thread(
                d_major=inner_thread_major_d + 2*thread_clearance,
                pitch=thread_pitch,
                depth=thread_depth,
                len=length+0.4,
                clearance=0.0
            );

        // Lead-in chamfers on both ends for the internal hole
        // Top chamfer
        translate([0,0,length-lead_in])
            cylinder(h=lead_in+0.01, d1=inner_thread_major_d+2.0, d2=inner_thread_major_d+2*thread_clearance, center=false);
        // Bottom chamfer
        translate([0,0,-0.01])
            cylinder(h=lead_in+0.02, d1=inner_thread_major_d+2*thread_clearance, d2=inner_thread_major_d+2.0, center=false);
    }
}

heat_set_insert();