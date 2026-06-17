$fn=96;

// Heat-set insert (simplified) for M2 screw
// Outer diameter: 4.0 mm
// Length: 3.6 mm
// Internal thread: approximated as a straight bore sized for M2 (tap/clearance-like)

od = 4.0;
len = 3.6;

// Typical M2 internal thread minor diameter is ~1.6 mm; for a printable/visual model use ~1.7 mm
id = 1.7;

// Small lead-in chamfers
chamfer = 0.25;

// Optional shallow knurl-like rings for heat-set grip (visual approximation)
ring_count = 6;
ring_depth = 0.25;
ring_width = 0.25;

module insert_body() {
    difference() {
        // Outer body
        cylinder(d=od, h=len);

        // Internal bore
        translate([0,0,-0.01])
            cylinder(d=id, h=len+0.02);

        // Lead-in chamfer top (subtract cone)
        translate([0,0,len-chamfer])
            cylinder(d1=id+0.8, d2=id, h=chamfer+0.01);

        // Lead-in chamfer bottom
        translate([0,0,-0.01])
            cylinder(d1=id, d2=id+0.8, h=chamfer+0.01);

        // Shallow external grip rings (subtract grooves)
        for (i = [0:ring_count-1]) {
            z = (i+0.5) * (len/ring_count) - ring_width/2;
            translate([0,0,z])
                cylinder(d=od+0.02, h=ring_width);
            translate([0,0,z])
                cylinder(d=od-2*ring_depth, h=ring_width);
        }
    }
}

insert_body();