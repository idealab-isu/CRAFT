$fn = 120;

// Heat-set insert (simplified, renderable model)
// Outer diameter: 5.8mm
// Length: 4.6mm
// For M3 screw: internal clearance hole ~3.2mm (simplified)

od = 5.8;
len = 4.6;

// Typical M3 clearance (simplified internal bore)
id = 3.2;

// Small lead-in chamfers
ch = 0.35;

// Optional shallow exterior knurl-like rings (purely visual)
ring_count = 6;
ring_depth = 0.25;
ring_width = 0.35;

module insert_body() {
    difference() {
        // Outer body with chamfers
        union() {
            // Main cylinder
            translate([0,0,ch])
                cylinder(h = len - 2*ch, d = od);

            // Bottom chamfer
            cylinder(h = ch, d1 = od - 2*ch, d2 = od);

            // Top chamfer
            translate([0,0,len - ch])
                cylinder(h = ch, d1 = od, d2 = od - 2*ch);
        }

        // Internal bore (slight lead-in)
        union() {
            // Through bore
            translate([0,0,-0.2])
                cylinder(h = len + 0.4, d = id);

            // Top lead-in
            translate([0,0,len - 0.8])
                cylinder(h = 0.8, d1 = id + 0.8, d2 = id);

            // Bottom lead-in
            cylinder(h = 0.8, d1 = id, d2 = id + 0.8);
        }

        // Shallow exterior rings (subtract to create grooves)
        for (i = [0:ring_count-1]) {
            z0 = ch + (len - 2*ch) * (i + 0.5) / ring_count - ring_width/2;
            translate([0,0,z0])
                cylinder(h = ring_width, d = od + 0.01);
            translate([0,0,z0])
                cylinder(h = ring_width, d = od - 2*ring_depth);
        }
    }
}

insert_body();