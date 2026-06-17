// Rectangular sheet (single connected solid)

length = 100;   // X
width  = 50;    // Y
thickness = 5;  // Z

module sheet_body(l=length, w=width, t=thickness) {
    // Clamp to a small positive thickness to avoid empty/blank renders
    t2 = (t > 0) ? t : 0.1;
    cube([l, w, t2], center=true);
}

sheet_body();