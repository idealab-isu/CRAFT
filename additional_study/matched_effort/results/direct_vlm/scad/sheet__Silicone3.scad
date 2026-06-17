$fn = 96;

length = 200;
width  = 150;
thickness = 2;

corner_radius = 8;

module rounded_sheet(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    linear_extrude(height = t)
        offset(r = r2)
            square([l - 2*r2, w - 2*r2], center = true);
}

color([0.85, 0.85, 0.90, 0.55])
    rounded_sheet(length, width, thickness, corner_radius);