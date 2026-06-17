$fn = 120;

// Heat-set insert (simplified) for M3 screw
// Outer diameter: 5.8mm
// Length: 4.6mm
// Internal thread: approximated as a straight clearance hole for M3 (3.0mm)

od = 5.8;
len = 4.6;

// Typical M3 clearance ~3.2; but user asked "for 3.0mm screws"
id = 3.0;

// Small lead-in chamfers
ch = 0.35;

module heat_set_insert(od, id, len, ch) {
    difference() {
        union() {
            // Main body
            cylinder(d=od, h=len);

            // Slight knurl-like rings (visual/printable approximation)
            // Keep subtle so OD stays near spec
            for (z = [0.6 : 0.8 : len-0.6]) {
                translate([0,0,z])
                    cylinder(d=od+0.25, h=0.25);
            }
        }

        // Through hole
        translate([0,0,-0.01])
            cylinder(d=id, h=len+0.02);

        // Chamfer both ends of the inner hole
        translate([0,0,-0.01])
            cylinder(d1=id+2*ch, d2=id, h=ch+0.01);

        translate([0,0,len-ch])
            cylinder(d1=id, d2=id+2*ch, h=ch+0.02);
    }
}

heat_set_insert(od=od, id=id, len=len, ch=ch);