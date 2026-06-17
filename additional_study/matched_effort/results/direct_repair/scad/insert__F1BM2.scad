$fn=96;

// Heat-set insert (simplified) for M2 screw
// Outer diameter: 4.0mm
// Length: 3.6mm
// Internal thread: approximated as a straight bore sized for M2 clearance/tap

od = 4.0;
len = 3.6;

// Typical M2 heat-set insert internal minor diameter is ~1.6-1.8mm depending on insert.
// Use 1.7mm as a reasonable approximation for an M2 insert.
id = 1.7;

// Small lead-in chamfers
ch = 0.35;

// Optional shallow knurl-like rings (purely cosmetic / grip approximation)
ring_count = 6;
ring_depth = 0.18;
ring_width = 0.35;

module insert_body() {
    difference() {
        // Outer body with chamfers
        union() {
            // Main cylinder
            translate([0,0,ch])
                cylinder(h=len-2*ch, d=od);

            // Bottom chamfer
            cylinder(h=ch, d1=od-2*ch, d2=od);

            // Top chamfer
            translate([0,0,len-ch])
                cylinder(h=ch, d1=od, d2=od-2*ch);

            // Grip rings (shallow)
            for (i = [0:ring_count-1]) {
                z0 = ch + (len-2*ch) * (i+0.5)/ring_count - ring_width/2;
                translate([0,0,z0])
                    difference() {
                        cylinder(h=ring_width, d=od + 2*ring_depth);
                        cylinder(h=ring_width, d=od);
                    }
            }
        }

        // Internal bore (straight, no modeled threads)
        translate([0,0,-0.2])
            cylinder(h=len+0.4, d=id);

        // Slight countersink at both ends for easier screw start
        translate([0,0,-0.01])
            cylinder(h=0.5, d1=id+0.8, d2=id);

        translate([0,0,len-0.49])
            cylinder(h=0.5, d1=id, d2=id+0.8);
    }
}

insert_body();