$fn = 160;

// Threaded heat-set insert
// Target: 8.0mm OD, 6.0mm length, internal M3 thread (modeled), external knurl/barbs

od = 8.0;
len = 6.0;

// Lead-in chamfers
chamfer = 0.5;

// Internal thread (approx M3x0.5)
// Major ~3.0, minor ~2.4-2.6; use ~2.5 for visible thread depth
thread_pitch = 0.5;
thread_major_d = 3.0;
thread_minor_d = 2.5;

// External knurl/barbs (axial rings + angular teeth)
ring_count = 7;
ring_depth = 0.35;     // radial depth of grooves
ring_width = 0.45;     // axial width of each groove

tooth_count = 24;      // angular barbs around OD
tooth_depth = 0.35;    // radial protrusion beyond OD/2
tooth_w = 0.55;        // tangential width (mm)
tooth_h = 0.55;        // axial height (mm)

eps = 0.02;

// --- Helpers ---

// Simple helical "thread cutter" (triangular profile) to subtract from bore.
// This is a visual/functional approximation, not a standards-accurate thread.
module internal_thread_cutter(h, pitch, major_d, minor_d) {
    turns = h / pitch;
    depth = (major_d - minor_d) / 2;

    // Triangular tooth in (radius, z) plane, then rotate_extrude with twist.
    // Positioned so outer radius reaches major_d/2 and inner reaches minor_d/2.
    rotate_extrude(angle=360, convexity=10, twist=turns*360, slices=max(ceil(turns*40), 80))
        translate([minor_d/2, 0, 0])
            polygon(points=[
                [0,            0],
                [depth,        pitch/2],
                [0,            pitch]
            ]);
}

// External barbs as small wedges that protrude outward and overlap into the body.
module external_teeth() {
    body_r = od/2;
    z0 = chamfer + tooth_h/2;
    z1 = len - chamfer - tooth_h/2;

    for (zi = [0:1]) {
        zc = (zi == 0) ? z0 : z1;
        for (i = [0:tooth_count-1]) {
            rotate([0,0,i*360/tooth_count])
                translate([body_r + tooth_depth/2 - 0.15, 0, zc])  // overlap into body by 0.15
                    cube([tooth_depth, tooth_w, tooth_h], center=true);
        }
    }
}

module insert() {
    difference() {
        // Outer solid: chamfered cylinder + external teeth (connected via overlap)
        union() {
            // Chamfered main body (single connected solid)
            union() {
                // Main cylinder section
                translate([0,0,chamfer])
                    cylinder(d=od, h=len-2*chamfer);

                // Bottom chamfer
                cylinder(d1=od-2*chamfer, d2=od, h=chamfer);

                // Top chamfer
                translate([0,0,len-chamfer])
                    cylinder(d1=od, d2=od-2*chamfer, h=chamfer);
            }

            // External barbs/teeth
            external_teeth();
        }

        // Internal bore + thread
        // Start with a minor-diameter pilot hole through the full length
        translate([0,0,-eps])
            cylinder(d=thread_minor_d, h=len+2*eps);

        // Subtract helical thread cutter to create visible internal threading
        // Keep it inside the insert length with slight margins.
        translate([0,0,0])
            internal_thread_cutter(len, thread_pitch, thread_major_d, thread_minor_d);

        // External ring grooves (knurl-like)
        for (i = [0:ring_count-1]) {
            z0 = chamfer + (len-2*chamfer) * (i + 0.5) / ring_count - ring_width/2;
            translate([0,0,z0])
                cylinder(d=od - 2*ring_depth, h=ring_width);
        }

        // Small lead-in at both ends for easier screw start (countersink-ish)
        lead_h = 0.6;
        translate([0,0,-eps])
            cylinder(d1=thread_major_d+0.6, d2=thread_minor_d, h=lead_h+eps);
        translate([0,0,len-lead_h])
            cylinder(d1=thread_minor_d, d2=thread_major_d+0.6, h=lead_h+eps);
    }
}

insert();