$fn = 120;

// Heat-set insert (simplified, renderable model)
// Outer: 5.8mm OD, 7.1mm length
// Inner: sized for M5 screw clearance (approx), not a true thread model

od = 5.8;
len = 7.1;

// Typical M5 clearance ~5.2mm; adjust if you want tighter/looser
id = 5.2;

// Small lead-in chamfers
ch = 0.35;

module heat_set_insert(od=5.8, id=5.2, len=7.1, ch=0.35) {
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
        }

        // Through-hole
        translate([0,0,-0.2])
            cylinder(h=len+0.4, d=id);
    }
}

heat_set_insert(od=od, id=id, len=len, ch=ch);