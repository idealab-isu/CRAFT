$fn = 96;

length = 200;
width  = 120;
thickness = 2.0;

corner_radius = 6;

module rounded_sheet(l, w, t, r){
    r2 = min(r, min(l, w)/2);
    linear_extrude(height = t, center = false, convexity = 10)
        offset(r = r2)
            square([l - 2*r2, w - 2*r2], center = true);
}

module carbon_fiber_texture(l, w, t){
    // Subtle woven pattern using alternating diagonal stripes on the top face
    // (purely visual; does not change thickness meaningfully)
    stripe_pitch = 6;
    stripe_width = 2.2;
    emboss = 0.08;

    // Base top skin
    translate([0,0,t - emboss])
        linear_extrude(height = emboss, center = false)
            square([l, w], center = true);

    // Diagonal stripes set 1
    intersection(){
        translate([0,0,t - emboss])
            linear_extrude(height = emboss, center = false)
                square([l, w], center = true);

        translate([0,0,t - emboss])
            linear_extrude(height = emboss, center = false)
                rotate(45)
                    for(i = [-200:1:200]){
                        translate([i*stripe_pitch, 0])
                            square([stripe_width, 400], center = true);
                    }
    }

    // Diagonal stripes set 2 (offset)
    intersection(){
        translate([0,0,t - emboss])
            linear_extrude(height = emboss, center = false)
                square([l, w], center = true);

        translate([0,0,t - emboss])
            linear_extrude(height = emboss, center = false)
                rotate(-45)
                    for(i = [-200:1:200]){
                        translate([i*stripe_pitch + stripe_pitch/2, 0])
                            square([stripe_width, 400], center = true);
                    }
    }
}

module carbon_fiber_sheet(l, w, t, r){
    // Dark carbon fiber base
    color([0.06, 0.06, 0.07])
        rounded_sheet(l, w, t, r);

    // Slightly lighter weave highlights
    color([0.12, 0.12, 0.13, 0.55])
        intersection(){
            // Clip texture to rounded outline
            rounded_sheet(l, w, t, r);
            carbon_fiber_texture(l, w, t);
        }

    // Edge sheen
    color([0.10, 0.10, 0.11, 0.35])
        difference(){
            rounded_sheet(l, w, t, r);
            translate([0,0,0.15])
                rounded_sheet(l-1.2, w-1.2, t, max(0, r-0.8));
        }
}

carbon_fiber_sheet(length, width, thickness, corner_radius);