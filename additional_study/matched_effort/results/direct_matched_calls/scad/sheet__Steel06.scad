$fn = 64;

length = 200;   // mm
width  = 120;   // mm
thickness = 2;  // mm

module sheet_mild_steel(l=length, w=width, t=thickness) {
    color([0.55, 0.55, 0.58])  // mild steel-like gray
        translate([-l/2, -w/2, 0])
            cube([l, w, t], center=false);
}

sheet_mild_steel();