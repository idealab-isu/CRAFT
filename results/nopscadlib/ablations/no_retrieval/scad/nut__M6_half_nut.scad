// Hex nut for M6 (6.0mm screw), 11.5mm across flats, 3.0mm thick

$fn = 96;

// Target dimensions
across_flats   = 11.5;   // mm
thickness      = 3.0;    // mm

// Hole (choose one): clearance or tap-drill representation
hole_diameter  = 6.2;    // mm (typical M6 clearance)
 //hole_diameter = 5.0;  // mm (typical M6 tap drill representation)

// Edge details
chamfer_size   = 0.3;    // mm lead-in on both faces
overlap        = 0.2;    // mm boolean overlap to avoid coplanar artifacts

// Derived: circumradius of hex from across-flats (AF = 2*apothem, R = apothem / cos(30))
hex_R = (across_flats/2) / cos(30);

module hex_prism(R, h) {
    cylinder(r=R, h=h, center=true, $fn=6);
}

module hex_nut(af, h, d_hole, chamfer) {
    R = (af/2) / cos(30);

    difference() {
        // Body
        hex_prism(R, h);

        // Circular through-hole (high $fn for round appearance)
        cylinder(d=d_hole, h=h + 2*overlap, center=true, $fn=$fn);

        // Lead-in chamfers (top and bottom), computed from thickness
        translate([0, 0,  h/2 - chamfer/2 + overlap])
            cylinder(h=chamfer + 2*overlap, r1=d_hole/2 + chamfer, r2=d_hole/2, center=true, $fn=$fn);

        translate([0, 0, -h/2 + chamfer/2 - overlap])
            cylinder(h=chamfer + 2*overlap, r1=d_hole/2, r2=d_hole/2 + chamfer, center=true, $fn=$fn);
    }
}

// Render
color("DimGray")
hex_nut(across_flats, thickness, hole_diameter, chamfer_size);