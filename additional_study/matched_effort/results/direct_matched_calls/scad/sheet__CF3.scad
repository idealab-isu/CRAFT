$fn = 64;

length = 200;
width  = 120;
thickness = 2;

corner_radius = 6;

module rounded_sheet(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    linear_extrude(height = t, center = false, convexity = 10)
        offset(r = r2)
            square([l - 2*r2, w - 2*r2], center = true);
}

module carbon_fiber_texture_2d(l, w, cell = 6, line = 0.9, angle = 45){
    intersection(){
        square([l, w], center = true);

        union(){
            rotate(angle)
                for (x = [-l : cell : l])
                    translate([x, 0])
                        square([line, 3*w], center = true);

            rotate(-angle)
                for (x = [-l : cell : l])
                    translate([x, 0])
                        square([line, 3*w], center = true);
        }
    }
}

module carbon_fiber_sheet(l, w, t, r){
    // Base sheet
    color([0.06, 0.06, 0.07])
        rounded_sheet(l, w, t, r);

    // Subtle weave overlay (visual only)
    color([0.12, 0.12, 0.13, 0.55])
        translate([0, 0, t + 0.01])
            linear_extrude(height = 0.15, center = false, convexity = 10)
                carbon_fiber_texture_2d(l - 2*r, w - 2*r, cell = 6, line = 0.9, angle = 45);
}

carbon_fiber_sheet(length, width, thickness, corner_radius);