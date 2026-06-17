$fn = 128;

// Neoprene tubing (generic): hollow cylinder with slight surface texture
// Units: mm

// Parameters
tube_length = 120;
outer_diameter = 18;
wall_thickness = 3.0;

// Texture controls (subtle)
texture_amplitude = 0.25;   // mm radial variation
texture_pitch = 6;          // mm per cycle along length
texture_twist = 25;         // degrees twist over full length

// Derived
outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;
assert(inner_r > 0, "Wall thickness too large for given outer diameter.");

module neoprene_tube(len=tube_length, ro=outer_r, ri=inner_r) {
    difference() {
        // Outer body with subtle helical ribbing to suggest neoprene texture
        linear_extrude(height=len, twist=texture_twist, convexity=10)
            textured_ring(ro, ri=0, amp=texture_amplitude, pitch=texture_pitch);

        // Inner bore (smooth)
        translate([0,0,-0.5])
            cylinder(h=len+1, r=ri, center=false);
    }
}

// 2D textured outer profile (a slightly wavy circle), then extruded
module textured_ring(ro, ri=0, amp=0.2, pitch=6) {
    // Create a wavy outer boundary using a polygon approximation
    // Number of lobes around circumference chosen to be subtle and not too busy
    lobes = 48;
    pts = [
        for (i = [0:lobes-1]) 
            let(a = 360*i/lobes)
            let(w = amp * sin(6*a))  // 6 waves around circumference
            [(ro + w)*cos(a), (ro + w)*sin(a)]
    ];

    difference() {
        polygon(points=pts);
        if (ri > 0) circle(r=ri);
    }
}

// Render
neoprene_tube();