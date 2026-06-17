$fn = 96;

length = 200;
width  = 120;
thickness = 2;

corner_radius = 6;

module rounded_sheet(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    linear_extrude(height = t, center = false)
        offset(r = r2)
            square([l - 2*r2, w - 2*r2], center = true);
}

module carbon_fiber_texture_2d(l, w, cell = 6, line = 0.9){
    intersection(){
        square([l, w], center = true);

        union(){
            for (x = [-l/2 : cell : l/2]){
                translate([x, 0]) square([line, w], center = true);
            }
            for (y = [-w/2 : cell : w/2]){
                translate([0, y]) square([l, line], center = true);
            }
            for (i = [-ceil((l+w)/cell) : 1 : ceil((l+w)/cell)]){
                translate([i*cell, 0]) rotate(45) square([line, max(l,w)*2], center = true);
                translate([i*cell, 0]) rotate(-45) square([line, max(l,w)*2], center = true);
            }
        }
    }
}

module carbon_fiber_sheet(l, w, t, r){
    base_color = [0.06, 0.06, 0.07];
    weave_color = [0.12, 0.12, 0.13];

    // Base sheet
    color(base_color)
        rounded_sheet(l, w, t, r);

    // Subtle weave emboss on top surface
    emboss_h = min(0.25, t*0.15);
    translate([0, 0, t - emboss_h])
        color(weave_color)
            linear_extrude(height = emboss_h)
                carbon_fiber_texture_2d(l - 2, w - 2, cell = 7, line = 0.7);
}

carbon_fiber_sheet(length, width, thickness, corner_radius);