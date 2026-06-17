$fn = 120;

// Heat-set insert (approximation)
// Outer diameter: 5.8 mm
// Length: 4.6 mm
// For M2.5 screw: internal thread approximated as a straight bore near tap size

od = 5.8;
len = 4.6;

// Typical M2.5 tap drill ~2.05 mm; use slightly larger for printable clearance
id = 2.1;

// Small lead-in chamfers
chamfer = 0.35;

// Optional shallow knurl-like rings (common on heat-set inserts)
ring_count = 7;
ring_depth = 0.25;
ring_width = 0.35;

module insert_body() {
    // Base cylinder
    cylinder(d=od, h=len);

    // Add shallow rings by unioning slightly larger bands, then subtracting to create grooves
    // (Grooves are subtracted in final difference)
}

module ring_grooves() {
    // Create circumferential grooves by subtracting thin torus-like bands (approximated with cylinders)
    for (i = [0:ring_count-1]) {
        z = (i + 0.5) * (len / ring_count);
        translate([0,0,z - ring_width/2])
            cylinder(d=od + 0.02, h=ring_width);
    }
}

module chamfers_and_bore() {
    // Through bore
    translate([0,0,-0.01]) cylinder(d=id, h=len+0.02);

    // Chamfer at bottom
    translate([0,0,-0.01])
        cylinder(d1=id + 2*chamfer, d2=id, h=chamfer+0.01);

    // Chamfer at top
    translate([0,0,len - chamfer])
        cylinder(d1=id, d2=id + 2*chamfer, h=chamfer+0.01);
}

difference() {
    // Outer body
    cylinder(d=od, h=len);

    // Internal bore + chamfers
    chamfers_and_bore();

    // Subtract grooves to mimic knurling
    // Make grooves by subtracting slightly smaller diameter cylinders, leaving ridges
    for (i = [0:ring_count-1]) {
        z = (i + 0.5) * (len / ring_count);
        translate([0,0,z - ring_width/2])
            cylinder(d=od - 2*ring_depth, h=ring_width);
    }
}