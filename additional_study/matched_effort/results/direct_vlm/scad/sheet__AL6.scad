$fn = 96;

length = 200;
width  = 150;
thickness = 6;

corner_radius = 2;

module rounded_plate(l, w, t, r){
    r2 = min(r, l/2, w/2);

    // Robust rounded rectangle via hull of corner circles, then extrude.
    linear_extrude(height = t, center = true, convexity = 10)
        hull()
            for (sx = [-1, 1], sy = [-1, 1])
                translate([sx*(l/2 - r2), sy*(w/2 - r2), 0])
                    circle(r = r2);
}

color([0.75, 0.78, 0.82])
    rounded_plate(length, width, thickness, corner_radius);