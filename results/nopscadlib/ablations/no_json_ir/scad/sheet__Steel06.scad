// Sheet mild steel (geometry only) - single connected solid

length = 100;   // mm
width  = 50;    // mm
thickness = 2;  // mm

// Ensure the sheet is visible in orthographic views by orienting thickness along Y
module sheet_plate(l, w, t) {
    cube([l, t, w], center=true);
}

sheet_plate(length, width, thickness);