// Aluminium rectangular box section: 50.8mm x 38.1mm x 3.0mm
// Robust hollow extrusion (one connected solid)

// Parameters
L = 1000;   //[50:2000:10]   Length (Z)
W = 50.8;   //[25.4:101.6:0.1] Outside width (X)
H = 38.1;   //[19.05:76.2:0.1] Outside height (Y)
t = 3.0;    //[1.0:10:0.1]   Wall thickness
eps = 0.05; //[0.01:0.2:0.01] Boolean tolerance

$fn = 64;

// Derived inner dimensions (must remain positive)
innerW = max(W - 2*t, eps);
innerH = max(H - 2*t, eps);

module box_section(len=L, w=W, h=H, th=t) {
    difference() {
        // Outer solid
        cube([w, h, len], center=true);

        // Inner void: slightly longer in Z to guarantee clean subtraction
        cube([innerW, innerH, len + 2*eps], center=true);
    }
}

// Final output (centered at origin)
color([0.75, 0.75, 0.78]) box_section();