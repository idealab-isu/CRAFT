$fn=180;

// Threaded heat-set insert (simplified, renderable model)
// Outer diameter: 30.0mm
// Length: 22.0mm
// For 12.0mm screws (modeled as internal thread major diameter ~12mm)

outer_d = 30.0;
length  = 22.0;

// Internal thread parameters (approximate for M12)
thread_major_d = 12.0;     // nominal screw diameter
pitch          = 1.75;     // typical M12 coarse pitch
thread_depth   = 0.75;     // radial depth of thread profile (approx)
clearance      = 0.25;     // extra clearance on minor diameter

// Heat-set insert features (approximate)
knurl_depth    = 0.8;      // radial depth of knurl grooves
knurl_count    = 36;       // number of knurl grooves around circumference
knurl_twist    = 18;       // degrees of twist over length for helical knurl
chamfer_h      = 1.2;      // end chamfer height

module helical_internal_thread(h, major_d, pitch, depth, clearance=0.2) {
    // Creates an internal thread by subtracting a helical "tooth" from a base bore.
    // Bore minor diameter:
    minor_d = major_d - 2*depth + 2*clearance;

    // Base bore
    cylinder(h=h, d=minor_d);

    // Helical tooth (triangular-ish wedge) swept around the axis
    turns = h / pitch;
    steps = max(24, ceil(turns * 40));

    // Tooth positioned near the bore wall
    // Cross-section in XY plane, then linear_extrude with twist to form helix.
    translate([0,0,0])
    linear_extrude(height=h, twist=turns*360, slices=steps, convexity=10)
        translate([minor_d/2, 0, 0])
            polygon(points=[
                [0, -pitch*0.28],
                [depth, 0],
                [0,  pitch*0.28]
            ]);
}

module helical_knurl_grooves(h, outer_d, depth, count, twist_deg) {
    // Subtractive helical grooves around the outside
    // Each groove is a thin rectangular cutter swept with twist.
    groove_w = (PI*outer_d)/count * 0.45;
    groove_d = depth;
    slices = 120;

    for (i=[0:count-1]) {
        rotate([0,0, i*360/count])
            linear_extrude(height=h, twist=twist_deg, slices=slices, convexity=10)
                translate([outer_d/2 - groove_d, -groove_w/2, 0])
                    square([groove_d*1.6, groove_w], center=false);
    }
}

module insert_body() {
    // Outer body with slight end chamfers
    union() {
        // Main cylinder
        cylinder(h=length, d=outer_d);

        // End chamfers (modeled as truncated cones added then later cut by difference)
        // We'll instead cut chamfers by subtracting cones in final difference.
    }
}

module heat_set_insert() {
    difference() {
        // Outer body
        insert_body();

        // External knurl grooves (two opposing helices for diamond-ish knurl)
        helical_knurl_grooves(length, outer_d, knurl_depth, knurl_count,  knurl_twist);
        helical_knurl_grooves(length, outer_d, knurl_depth, knurl_count, -knurl_twist);

        // Internal threaded hole
        // Subtract base bore + helical tooth (thread)
        union() {
            // Slight lead-in at both ends
            translate([0,0,-0.01]) cylinder(h=chamfer_h+0.02, d1=thread_major_d+1.2, d2=thread_major_d-0.6);
            translate([0,0,length-chamfer_h-0.01]) cylinder(h=chamfer_h+0.02, d1=thread_major_d-0.6, d2=thread_major_d+1.2);

            // Threaded section
            translate([0,0,0])
                helical_internal_thread(length, thread_major_d, pitch, thread_depth, clearance);
        }

        // Outer end chamfers (subtractive)
        translate([0,0,-0.01])
            cylinder(h=chamfer_h+0.02, d1=outer_d+2.0, d2=outer_d-2.0);
        translate([0,0,length-chamfer_h-0.01])
            cylinder(h=chamfer_h+0.02, d1=outer_d-2.0, d2=outer_d+2.0);
    }
}

heat_set_insert();