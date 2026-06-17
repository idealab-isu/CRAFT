$fn = 128;

// Target dimensions (mm)
thread_diameter = 8.0;      // major diameter
length = 10.0;              // shank length (under head)
head_diameter = 14.0;
head_height = 4.4;

// Thread (visual, helical ridge)
thread_pitch = 1.25;        // typical for M8 coarse
thread_depth = 0.45;        // radial height of ridge
thread_flat  = 0.35;        // flat at crest (controls ridge thickness)

// Drive feature (hex socket)
socket_af = 5.0;            // across flats (approx for M8 button/dome head)
socket_depth = 2.6;         // depth into head

// Small overlap to guarantee watertight unions
eps = 0.05;

module hex2d(af){
    // Regular hex with given across-flats
    r = af / sqrt(3); // circumradius
    polygon([for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module dome_head_profile(r_head, head_h){
    // 2D profile for rotate_extrude: true spherical cap with base radius r_head and height head_h
    // Sphere radius chosen so that cap height = head_h and base radius = r_head:
    // R = (r^2 + h^2) / (2h)
    R = (r_head*r_head + head_h*head_h) / (2*head_h);
    zc = head_h - R; // sphere center z
    intersection(){
        translate([0, zc]) circle(r=R);
        square([r_head, head_h], center=false);
    }
}

module helical_thread_ridge(r_core, len, pitch, depth, flat){
    // A thin helical "band" fused to the core cylinder.
    // Built by twisting a 2D ring segment along Z.
    // r_core is the major diameter/2; ridge extends outward by depth.
    slices = max(60, ceil(len * 40));
    translate([0,0,-len])
        linear_extrude(height=len, twist=360*len/pitch, slices=slices, convexity=10)
            difference(){
                circle(r=r_core + depth);
                circle(r=r_core + depth - flat);
            }
}

module dome_head_screw(){
    r_shank = thread_diameter/2;
    r_head  = head_diameter/2;

    difference(){
        union(){
            // Shank core: underside of head at z=0, shank extends to -length
            translate([0,0,-length/2])
                cylinder(h=length + eps, r=r_shank - thread_depth*0.35, center=true);

            // Helical ridge (thread appearance), overlaps into shank for watertight union
            helical_thread_ridge(r_shank - thread_depth*0.35, length + eps, thread_pitch, thread_depth, thread_flat);

            // Dome head: spherical cap via rotate_extrude, base at z=0, top at z=head_height
            rotate_extrude(convexity=10)
                dome_head_profile(r_head, head_height);

            // Small under-head fillet (blends head to shank)
            // Ensures a clean connected transition at z=0
            hull(){
                translate([0,0,eps/2]) cylinder(h=eps, r=r_shank + 0.25, center=true);
                translate([0,0,eps/2]) cylinder(h=eps, r=r_head, center=true);
            }
        }

        // Hex socket drive feature (subtracted)
        // Positioned from top surface down by socket_depth
        translate([0,0,head_height - socket_depth/2 + eps/2])
            linear_extrude(height=socket_depth + eps, center=true, convexity=10)
                hex2d(socket_af);
    }
}

dome_head_screw();