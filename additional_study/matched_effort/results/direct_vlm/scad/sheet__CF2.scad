$fn = 64;

length = 200;
width  = 120;
thickness = 2;

corner_radius = 6;

module rounded_sheet(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    linear_extrude(height = t)
        offset(r = r2)
            square([l - 2*r2, w - 2*r2], center = true);
}

color([0.08, 0.08, 0.09])
    rounded_sheet(length, width, thickness, corner_radius);