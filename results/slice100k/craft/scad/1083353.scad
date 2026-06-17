// Simple hollow right circular cylinder (tube/bushing)

// Parameters (mm)
L  = 82.5;     // length (Z)
OD = 15.0;     // outer diameter (X/Y)
ID = 10.0;     // inner diameter (through-bore)

$fn = 128;

module tube(len, od, id) {
    difference() {
        cylinder(h=len, d=od, center=true);
        // Slightly longer bore to guarantee a clean through-cut
        cylinder(h=len + 0.2, d=id, center=true);
    }
}

tube(L, OD, ID);