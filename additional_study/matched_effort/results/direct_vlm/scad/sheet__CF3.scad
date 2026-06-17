$fn = 96;

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

module carbon_fiber_texture(l, w, t){
    // Subtle weave-like surface relief (very shallow) to suggest carbon fiber
    // Kept minimal so it remains a "sheet" and renders quickly.
    weave_pitch = 6;
    ridge_w = 0.6;
    ridge_h = 0.08;

    intersection(){
        translate([0,0,t - ridge_h])
        union(){
            // +45° ridges
            rotate([0,0,45])
            for (x = [-l : weave_pitch : l])
                translate([x,0,0])
                    cube([ridge_w, 3*w, ridge_h], center = true);

            // -45° ridges
            rotate([0,0,-45])
            for (x = [-l : weave_pitch : l])
                translate([x,0,0])
                    cube([ridge_w, 3*w, ridge_h], center = true);
        }
        // Clip to sheet footprint
        translate([0,0,0])
            linear_extrude(height = t, center = false)
                square([l, w], center = true);
    }
}

difference(){
    // Base sheet
    rounded_sheet(length, width, thickness, corner_radius);

    // Optional: tiny chamfer-like edge relief via subtracting a very thin offset shell
    // (kept extremely small to avoid changing overall dimensions noticeably)
    translate([0,0,thickness - 0.15])
        linear_extrude(height = 0.2, center = false)
            difference(){
                offset(r = 0.6) square([length, width], center = true);
                offset(r = 0.2) square([length, width], center = true);
            }
}

// Add subtle weave texture on top surface
carbon_fiber_texture(length, width, thickness);