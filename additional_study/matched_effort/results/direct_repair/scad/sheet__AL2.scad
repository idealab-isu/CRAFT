$fn = 64;

length = 200;
width  = 150;
thickness = 6;

corner_radius = 3;

module rounded_plate(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    linear_extrude(height = t)
        offset(r = r2)
            square([l - 2*r2, w - 2*r2], center = true);
}

color([0.75, 0.78, 0.80])
    rounded_plate(length, width, thickness, corner_radius);