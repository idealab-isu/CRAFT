$fn=64;

len = 70;
r0 = 14;
r1 = 12.5;

boss_len = 10;
boss_r = 9.5;

hex_flat = 6; // across flats
hex_r = hex_flat / sqrt(3); // circumradius for across-flats sizing

facet_n = 14;

module hex_hole(h, r){
    cylinder(h=h, r=r, $fn=6, center=true);
}

module faceted_shell(h, r_start, r_end, nfacets){
    linear_extrude(height=h, center=true, scale=r_end/r_start, convexity=10)
        circle(r=r_start, $fn=nfacets);
}

module grip_body(){
    union(){
        // main faceted tapered body
        faceted_shell(len, r0, r1, facet_n);

        // subtle irregular flats via shallow cuts
        difference(){
            // keep as a no-op wrapper for consistent union/difference structure
            union(){
                // rounded/flush end cap (slightly bulged)
                translate([0,0,len/2 - 2])
                    scale([1,1,0.7])
                        sphere(r=r1+1.2, $fn=64);
            }
            // shallow planar cuts around the body to create irregular flats
            for (i=[0:7]){
                ang = i*360/8 + (i%2)*7;
                zpos = -len/2 + 12 + i*6;
                depth = 1.2 + (i%3)*0.35;
                translate([0,0,zpos])
                    rotate([0,0,ang])
                        translate([r0+2 - depth,0,0])
                            cube([10, 40, 18], center=true);
            }
        }

        // stepped boss on one end
        translate([0,0,-len/2 - boss_len/2 + 0.01])
            cylinder(h=boss_len, r=boss_r, center=true, $fn=facet_n);

        // small fillet-like transition ring
        translate([0,0,-len/2 + 1.5])
            cylinder(h=3, r1=boss_r+1.2, r2=r0-0.8, center=true, $fn=facet_n);
    }
}

difference(){
    grip_body();

    // hex through-bore along axis
    hex_hole(len + boss_len + 20, hex_r);

    // slight counterbore/lead-in on rounded end
    translate([0,0,len/2 - 1])
        cylinder(h=6, r1=hex_r*1.35, r2=hex_r, center=true, $fn=6);

    // slight lead-in on boss end
    translate([0,0,-len/2 - boss_len + 2])
        cylinder(h=6, r1=hex_r*1.35, r2=hex_r, center=true, $fn=6);
}