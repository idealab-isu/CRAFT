// Solid State Relay (SSR) Module
// Overall size: 58.0mm x 45.0mm x 33.0mm

length = 58;  // X
width  = 45;  // Y
height = 33;  // Z

// Use a small, safe corner radius to avoid degenerate minkowski geometry
corner_radius = 1.5;

$fn = 64;

module rounded_box(size=[10,10,10], r=0, center=true) {
    r2 = max(0, min(r, min(size[0], min(size[1], size[2]))/2));

    if (r2 <= 0) {
        cube(size, center=center);
    } else {
        // Robust rounded box using hull of corner spheres (avoids minkowski blank renders)
        sx = size[0];
        sy = size[1];
        sz = size[2];

        // Corner positions for a centered box
        x0 = -sx/2 + r2;
        x1 =  sx/2 - r2;
        y0 = -sy/2 + r2;
        y1 =  sy/2 - r2;
        z0 = -sz/2 + r2;
        z1 =  sz/2 - r2;

        translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
            hull() {
                for (x = [x0, x1])
                    for (y = [y0, y1])
                        for (z = [z0, z1])
                            translate([x,y,z]) sphere(r=r2);
            }
    }
}

module ssr_module() {
    // One connected solid, visible non-degenerate geometry
    color([0.85, 0.85, 0.8])
        rounded_box([length, width, height], r=corner_radius, center=true);
}

ssr_module();