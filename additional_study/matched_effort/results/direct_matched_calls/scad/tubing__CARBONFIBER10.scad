$fn = 128;

// Carbon fiber tubing parameters (mm)
outer_d = 25;
inner_d = 21;
length  = 120;

// Visual "carbon fiber" weave approximation
weave_pitch = 6;      // mm along length
weave_depth = 0.25;   // mm emboss depth (kept small for renderability)
weave_angle = 35;     // degrees

module tube(od, id, h){
    difference(){
        cylinder(d=od, h=h, center=false);
        translate([0,0,-0.5]) cylinder(d=id, h=h+1, center=false);
    }
}

module carbon_weave_shell(od, h, pitch, depth, angle){
    // Create a thin shell with a subtle cross-hatched emboss
    // by intersecting a thin outer skin with two sets of helical ridges.
    skin_thickness = max(depth*2, 0.4);

    module skin(){
        difference(){
            cylinder(d=od, h=h);
            translate([0,0,-0.5]) cylinder(d=od-2*skin_thickness, h=h+1);
        }
    }

    module helical_ridges(sign=1){
        // Approximate helix by twisting a set of narrow axial strips
        // Twist amount derived from desired helix angle.
        // twist (deg) over height h: tan(angle) = circumferential / axial
        // circumferential = (twist/360)*pi*od
        // => twist = 360*h*tan(angle)/(pi*od)
        twist_deg = sign * (360 * h * tan(angle) / (PI * od));

        // Number of strips around circumference
        n = max(24, floor(PI*od / (pitch/2)));
        strip_w = pitch/3;
        strip_t = depth*2;

        linear_extrude(height=h, twist=twist_deg, slices=max(60, floor(h*2)), convexity=10)
            union(){
                for(i=[0:n-1]){
                    rotate(i*360/n)
                        translate([od/2 - strip_t, 0, 0])
                            square([strip_t, strip_w], center=true);
                }
            }
    }

    intersection(){
        skin();
        union(){
            helical_ridges( 1);
            helical_ridges(-1);
        }
    }
}

module carbon_fiber_tube(od, id, h){
    base_color = [0.06, 0.06, 0.07];
    weave_color = [0.12, 0.12, 0.13];

    // Base tube
    color(base_color)
        tube(od, id, h);

    // Subtle weave emboss on outer surface
    color(weave_color)
        carbon_weave_shell(od, h, weave_pitch, weave_depth, weave_angle);
}

carbon_fiber_tube(outer_d, inner_d, length);