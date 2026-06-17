$fn = 64;

// Sheet/plate: thickness ~5/16" = 0.3125 in = 7.9375 mm
inch = 25.4;
thickness = 5/16 * inch;   // 7.9375 mm

length = 100; // mm
width  = 50;  // mm

module sheet_plate(l=length, w=width, t=thickness) {
    // One connected solid, centered at origin
    cube([l, w, t], center=true);
}

sheet_plate();