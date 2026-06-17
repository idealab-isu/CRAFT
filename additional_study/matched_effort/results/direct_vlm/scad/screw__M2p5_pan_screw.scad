$fn = 128;

// Dimensions (mm)
shaft_d   = 2.5;
shaft_r   = shaft_d/2;
shaft_len = 10;          // under-head length

head_d = 4.7;
head_r = head_d/2;
head_h = 1.7;

// Pan head profile controls (kept within head_h)
skirt_h = head_h * 0.35;          // short straight skirt
dome_h  = head_h - skirt_h;       // domed portion height

// Drive feature (Phillips-like cross recess)
drive_depth = min(0.55*head_h, 0.95);   // recess depth
drive_w     = head_d * 0.22;            // slot width
drive_len   = head_d * 0.78;            // slot length

// Small overlap to guarantee a single connected solid / robust booleans
eps = 0.02;

module pan_head_solid(d=head_d, h=head_h, skirt=skirt_h) {
    r = d/2;
    dome = h - skirt;

    // Spherical cap: base radius a=r, cap height hh=dome
    a  = r;
    hh = dome;
    R  = (a*a + hh*hh) / (2*hh);

    union() {
        // Cylindrical skirt
        cylinder(h=skirt + eps, r=r);

        // Domed top (spherical cap)
        translate([0,0,skirt - eps])
            intersection() {
                translate([0,0, R - hh]) sphere(r=R);
                cylinder(h=hh + eps, r=a);
            }
    }
}

module cross_recess(depth=drive_depth, w=drive_w, len=drive_len) {
    // Two perpendicular rounded-ish slots (rectangular prisms)
    union() {
        translate([0,0,-depth])
            cube([len, w, depth + eps], center=true);
        translate([0,0,-depth])
            cube([w, len, depth + eps], center=true);
    }
}

module pan_head_screw() {
    difference() {
        union() {
            // Shank
            cylinder(h=shaft_len + eps, r=shaft_r);

            // Head on top of shank (connected with overlap)
            translate([0,0,shaft_len - eps])
                pan_head_solid(d=head_d, h=head_h, skirt=skirt_h);
        }

        // Drive recess cut into the top of the head
        translate([0,0,shaft_len + head_h + eps])
            cross_recess(depth=drive_depth, w=drive_w, len=drive_len);
    }
}

pan_head_screw();