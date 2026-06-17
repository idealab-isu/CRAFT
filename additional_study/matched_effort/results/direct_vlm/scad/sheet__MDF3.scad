$fn = 64;

// Sheet MDF
sheet_x = 600;
sheet_y = 400;
sheet_thickness = 6;

// Detail parameters (kept as ONE connected solid)
bevel = 0.6;                 // small edge chamfer
grain_amp = 0.18;            // subtle surface variation
grain_step = 18;             // spacing of grain ridges
grain_w = 1.2;               // ridge width
grain_h = grain_amp;         // ridge height
overlap = 0.05;              // ensures union connectivity

module mdf_sheet(x, y, t) {
    // Robustness clamps to avoid invalid/empty geometry
    b = min(bevel, x/4, y/4, t/4);
    eh = min(grain_h, t/3);
    eb = min(0.35, x/10, y/10);

    union() {
        // Base sheet with slight bevel (single solid)
        color([0.78, 0.67, 0.50])
        hull() {
            cube([x, y, t], center=false);
            translate([b, b, b])
                cube([max(0.01, x - 2*b), max(0.01, y - 2*b), max(0.01, t - 2*b)], center=false);
        }

        // Subtle "fiber/grain" ridges on top face (connected via overlap)
        color([0.80, 0.70, 0.54])
        for (yy = [grain_step/2 : grain_step : y - grain_step/2]) {
            translate([0, yy - grain_w/2, t - overlap])
                cube([x, grain_w, eh + overlap], center=false);
        }

        // Subtle "fiber/grain" ridges on bottom face (connected via overlap)
        color([0.76, 0.65, 0.48])
        for (yy = [grain_step : grain_step : y - grain_step]) {
            translate([0, yy - grain_w/2, -eh + overlap])
                cube([x, grain_w, eh + overlap], center=false);
        }

        // Slight edge band hint (connected via overlap)
        color([0.74, 0.62, 0.45])
        translate([-eb, -eb, 0])
            cube([x + 2*eb, y + 2*eb, t], center=false);
    }
}

mdf_sheet(sheet_x, sheet_y, sheet_thickness);