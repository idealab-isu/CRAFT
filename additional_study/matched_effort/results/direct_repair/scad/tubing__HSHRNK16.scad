$fn=128;

// Heatshrink sleeving (tubing) parameters
inner_d = 6;          // inner diameter (mm)
wall = 0.6;           // wall thickness (mm)
length = 40;          // length (mm)
taper_len = 6;        // tapered lead-in length at each end (mm)
end_thin_factor = 0.65; // wall thickness factor at ends (0..1), thinner ends look more realistic

outer_d_mid = inner_d + 2*wall;
outer_d_end = inner_d + 2*(wall*end_thin_factor);

module heatshrink_sleeve(id=inner_d, wall=wall, L=length, taper=taper_len, end_factor=end_thin_factor) {
    od_mid = id + 2*wall;
    od_end = id + 2*(wall*end_factor);

    difference() {
        // Outer surface with slight taper at both ends
        union() {
            // Middle straight section
            translate([0,0,taper])
                cylinder(h=max(0, L-2*taper), d=od_mid);

            // Bottom taper
            cylinder(h=taper, d1=od_end, d2=od_mid);

            // Top taper
            translate([0,0,L-taper])
                cylinder(h=taper, d1=od_mid, d2=od_end);
        }

        // Inner bore (straight)
        translate([0,0,-0.5])
            cylinder(h=L+1, d=id);
    }
}

heatshrink_sleeve();