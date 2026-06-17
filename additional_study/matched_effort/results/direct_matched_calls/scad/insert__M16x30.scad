$fn=180;

// Threaded heat-set insert (simplified, renderable model)
// Outer diameter: 30.0 mm
// Length: 25.0 mm
// For 16.0 mm screws (internal thread major diameter approximated as 16.0 mm)

outer_d = 30.0;
length  = 25.0;

inner_thread_major_d = 16.0;   // nominal screw size
inner_thread_minor_d = 13.6;   // approximate minor diameter for internal thread
thread_pitch = 2.0;            // coarse-ish pitch for M16-like
thread_depth = (inner_thread_major_d - inner_thread_minor_d)/2;

knurl_count = 48;              // exterior knurl ribs
knurl_height = 0.8;
knurl_width  = 0.9;

lead_in = 1.2;                 // chamfer/lead-in at ends

module internal_thread_like(h, major_d, pitch, depth) {
    // Creates a helical ridge that is SUBTRACTED from the bore to approximate internal threads.
    // Base bore is at minor diameter; subtracting the ridge yields a threaded cavity.
    turns = h / pitch;
    linear_extrude(height=h, twist=turns*360, slices=max(ceil(turns*40), 80), convexity=10)
        translate([major_d/2 - depth, 0, 0])
            circle(r=depth, $fn=48);
}

module knurled_shell(od, h) {
    // Base cylinder
    union() {
        cylinder(d=od, h=h);

        // Straight knurl ribs
        for (i = [0:knurl_count-1]) {
            rotate([0,0, i*360/knurl_count])
                translate([od/2, 0, 0])
                    cube([knurl_height, knurl_width, h], center=false);
        }

        // Slight end collars (helps resemble heat-set insert profile)
        cylinder(d=od*1.02, h=1.0);
        translate([0,0,h-1.0]) cylinder(d=od*1.02, h=1.0);
    }
}

difference() {
    // Outer body with knurling
    knurled_shell(outer_d, length);

    // Through bore at minor diameter
    translate([0,0,-0.5])
        cylinder(d=inner_thread_minor_d, h=length+1.0);

    // Internal thread approximation
    translate([0,0,0])
        internal_thread_like(length, inner_thread_major_d, thread_pitch, thread_depth);

    // Lead-in chamfers (both ends)
    translate([0,0,-0.01])
        cylinder(d1=inner_thread_major_d+2.0, d2=inner_thread_minor_d, h=lead_in+0.02);
    translate([0,0,length-lead_in-0.01])
        cylinder(d1=inner_thread_minor_d, d2=inner_thread_major_d+2.0, h=lead_in+0.02);
}