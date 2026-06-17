$fn = 120;

// Heat-set insert (simplified, renderable model)
// Given: 5.8mm outer diameter, 7.1mm long, for 5.0mm screws (approx. M5 internal thread)
// Model: outer cylinder + internal helical thread cut + small lead-in chamfers

od = 5.8;
len = 7.1;

// Approx internal thread assumptions for "5.0mm screws" (M5 coarse)
thread_major = 5.0;     // nominal screw major diameter
pitch = 0.8;            // M5 coarse pitch
thread_depth = 0.30;    // simplified radial depth of thread cut
clearance = 0.15;       // extra clearance for screw fit

id_major = thread_major + clearance;          // internal major diameter
id_minor = id_major - 2*thread_depth;         // internal minor diameter

// Chamfers
ch = 0.35; // chamfer height

module helical_thread_cut(d_major, d_minor, pitch, length) {
    // Creates a helical "tooth" volume to subtract from a pre-bored hole.
    // Uses a triangular profile swept around the axis.
    turns = length / pitch;
    r_major = d_major/2;
    r_minor = d_minor/2;

    // Triangular profile in XY plane, positioned at radius ~ r_minor..r_major
    // Points: inner at r_minor, outer at r_major, with slight tangential width
    tangential = (pitch * 0.35); // controls tooth thickness
    linear_extrude(height = length + 0.2, twist = -360*turns, slices = max(40, ceil(turns*80)), convexity = 10)
        polygon(points=[
            [r_minor, -tangential/2],
            [r_major, 0],
            [r_minor,  tangential/2]
        ]);
}

module insert() {
    difference() {
        // Outer body with small end chamfers
        union() {
            // main cylinder
            cylinder(d=od, h=len);

            // top chamfer (add then cut by intersection via difference below is harder; instead, just add a small frustum)
            translate([0,0,len-ch])
                cylinder(d1=od, d2=od-2*ch, h=ch);

            // bottom chamfer
            cylinder(d1=od-2*ch, d2=od, h=ch);
        }

        // Bore (minor diameter) through
        translate([0,0,-0.1])
            cylinder(d=id_minor, h=len+0.2);

        // Thread cut (helical ridge removed from bore)
        translate([0,0,-0.05])
            helical_thread_cut(id_major, id_minor, pitch, len+0.1);

        // Lead-in countersinks to ease screw start
        translate([0,0,-0.01])
            cylinder(d1=id_major+0.8, d2=id_minor, h=0.6);
        translate([0,0,len-0.59])
            cylinder(d1=id_minor, d2=id_major+0.8, h=0.6);
    }
}

insert();