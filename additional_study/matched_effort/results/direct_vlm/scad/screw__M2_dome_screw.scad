$fn = 128;

// Dome head screw (mm)
shaft_d = 2.0;
shaft_r = shaft_d/2;

length  = 10.0;   // overall length: tip (z=0) to top of head (z=length)

head_d  = 3.5;
head_r  = head_d/2;

head_h  = 1.3;    // head height above underside plane

// Visual thread approximation (kept subtle so major dia stays ~2.0mm)
pitch        = 0.45;
thread_depth = 0.10;  // radial height of ridge (major radius = shaft_r)

// Connectivity overlap
eps = 0.03;

// Spherical cap radius from base radius a and cap height h
function cap_R(a,h) = (a*a + h*h) / (2*h);

module dome_head(a, h) {
    R = cap_R(a,h);
    // Underside plane at z=0, dome extends to z=h
    intersection() {
        translate([0,0,R - h]) sphere(r=R);
        cylinder(h=h, r=a);
    }
}

module threaded_shank(len, r, pitch, depth) {
    // Core cylinder at nominal shaft radius (2.0mm dia)
    cylinder(h=len, r=r);

    // Helical ridge that stays within r..r+depth (kept small)
    turns = len / pitch;
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*28), 80), convexity=10)
        translate([r, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

thread_len = length - head_h;  // shank length up to underside of head

// Build along +Z so orthographic front/side views show full length
union() {
    // Shank from z=0 to z=thread_len
    threaded_shank(thread_len, shaft_r, pitch, thread_depth);

    // Dome head from z=thread_len to z=length (connected with overlap)
    translate([0,0,thread_len - eps])
        dome_head(head_r, head_h + eps);
}