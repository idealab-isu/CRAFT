$fn = 128;

// Required dimensions
outer_diameter = 15.0;   // OD
bore_diameter  = 8.0;    // ID
length         = 45.0;   // overall length

// Simple long linear bearing sleeve (single connected solid with through-bore)
module linear_bearing(od, id, L) {
    difference() {
        cylinder(d=od, h=L, center=true);
        // Slightly longer cutter to guarantee a clean through-hole
        cylinder(d=id, h=L + 0.2, center=true);
    }
}

linear_bearing(outer_diameter, bore_diameter, length);