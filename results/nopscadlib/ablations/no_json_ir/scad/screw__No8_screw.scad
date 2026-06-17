// Pan head screw: 4.2mm major diameter, 8.2mm head diameter, 3.05mm head height, 10mm overall length
// One connected solid. Oriented along +Z so orthographic front/left/right show side profile.

$fn = 128;

// Dimensions (mm)
screw_diameter = 4.2;     // major diameter
screw_length   = 10;      // overall length (tip to top of head)
head_diameter  = 8.2;     // pan head max diameter
head_height    = 3.05;    // pan head height

// Thread approximation parameters
pitch          = 1.4;
thread_depth   = 0.35;
minor_diameter = screw_diameter - 2*thread_depth;

// Tip parameters
tip_len        = 1.2;     // tapered tip length (within shank)
tip_flat       = 0.25;    // flat at very end

// Numerical
eps = 0.05;

// Derived
shank_len = screw_length - head_height;

// Helical thread as a swept triangular ridge around a minor-diameter core
module threaded_shank(len, major_d, minor_d, pitch) {
    turns = len / pitch;
    ridge_r = (major_d - minor_d) / 2;

    union() {
        // Core cylinder (minor diameter)
        cylinder(h=len, d=minor_d, center=false);

        // Helical ridge (triangular-ish profile) around the core
        linear_extrude(height=len, twist=turns*360,
                       slices=max(ceil(turns*60), 120), convexity=10)
            translate([minor_d/2, 0, 0])
                polygon(points=[
                    [0, -pitch*0.22],
                    [ridge_r, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

// Connected tip: taper + flat, built at z=0..tip_len
module screw_tip(major_d, minor_d, tip_len, tip_flat) {
    flat_h = min(tip_flat, tip_len);
    taper_h = max(tip_len - flat_h, 0);

    union() {
        // Flat end
        cylinder(h=flat_h + eps, d=minor_d*0.85, center=false);

        // Taper up to minor diameter
        if (taper_h > 0)
            translate([0,0,flat_h])
                cylinder(h=taper_h + eps, d1=minor_d*0.85, d2=minor_d, center=false);
    }
}

// Pan head: skirt + domed top (spherical cap), total height = h, max diameter = d
module pan_head(d, h) {
    // More pan-like: mostly cylindrical with a modest dome
    dome_h  = h * 0.40;
    skirt_h = h - dome_h;

    a = d/2;
    R = (a*a + dome_h*dome_h) / (2*dome_h);

    union() {
        // Skirt
        cylinder(h=skirt_h + eps, d=d, center=false);

        // Dome (spherical cap)
        translate([0,0,skirt_h])
            intersection() {
                translate([0,0,R - dome_h]) sphere(r=R);
                cylinder(h=dome_h + eps, r=a + 0.02, center=false);
            }
    }
}

module screw() {
    union() {
        // Tip at bottom
        screw_tip(screw_diameter, minor_diameter, min(tip_len, shank_len), tip_flat);

        // Threaded shank above tip
        translate([0,0,min(tip_len, shank_len) - eps])
            threaded_shank(shank_len - min(tip_len, shank_len) + eps,
                           screw_diameter, minor_diameter, pitch);

        // Head on top of shank (connected with overlap)
        translate([0,0,shank_len - eps])
            pan_head(head_diameter, head_height);
    }
}

// Rotate so orthographic front/back/left/right show the side profile (length visible)
rotate([0,90,0]) screw();