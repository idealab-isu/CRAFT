$fn = 160;

// =====================
// Dome head screw (mm)
// =====================
shaft_d = 4.0;
shaft_r = shaft_d/2;
length  = 10.0;     // under-head length

head_d = 7.6;
head_r = head_d/2;
head_h = 2.2;       // dome height above the under-head plane

// Visual thread approximation (kept subtle so dimensions remain correct)
pitch        = 0.7;
thread_depth = 0.25;                 // radial depth
r_major      = shaft_r;
r_minor      = r_major - thread_depth;

drive_depth = 1.1;                   // recess depth into head
drive_w     = 1.0;                   // slot width
drive_len   = head_d * 0.72;         // slot length across head

eps = 0.02;

// Spherical cap radius for dome head: base radius a=head_r, cap height h=head_h
function cap_sphere_R(a,h) = (a*a + h*h) / (2*h);

module dome_head_cap(a, h) {
    // Cap base plane at z=0, top at z=h
    R = cap_sphere_R(a,h);
    intersection() {
        translate([0,0,R - h]) sphere(r=R);
        cylinder(h=h, r=a);
    }
}

module phillips_recess() {
    // Cut from near top down by drive_depth
    translate([0,0,head_h - drive_depth - eps])
    union() {
        linear_extrude(height = drive_depth + 2*eps, scale = 0.85, convexity=10)
            square([drive_len, drive_w], center=true);
        linear_extrude(height = drive_depth + 2*eps, scale = 0.85, convexity=10)
            square([drive_w, drive_len], center=true);
    }
}

module threaded_shank(len) {
    // Core at minor radius + helical ridge up to major radius
    union() {
        cylinder(h=len, r=r_minor);

        turns = len / pitch;
        linear_extrude(height=len, twist=turns*360, slices=max(20, ceil(turns*60)), convexity=10)
            translate([r_minor, 0, 0])
                polygon(points=[
                    [0, -pitch*0.25],
                    [r_major - r_minor, 0],
                    [0,  pitch*0.25]
                ]);
    }
}

module dome_head_screw() {
    difference() {
        union() {
            // Shank: z=0..length
            threaded_shank(length);

            // Dome head: base at z=length, top at z=length+head_h
            translate([0,0,length - eps])  // overlap ensures one connected solid
                dome_head_cap(head_r, head_h);
        }

        // Drive recess cut into dome head
        translate([0,0,length - eps])
            phillips_recess();
    }
}

dome_head_screw();