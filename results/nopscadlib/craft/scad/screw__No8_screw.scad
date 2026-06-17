// Pan head screw (single connected solid)
// Target: shank Ø4.2, length under head 10, head Ø8.2, head height 3.05

$fn = 128;

// Parameters
shank_diameter     = 4.2;   //[2.1:8.4:0.1]
length_under_head  = 10;    //[5:20:0.5]
head_diameter      = 8.2;   //[4.1:16.4:0.1]
head_height        = 3.05;  //[1.5:6.1:0.05]

// Thread approximation (visual)
thread_pitch       = 1.4;   //[0.8:2.5:0.05]
thread_depth       = 0.35;  //[0.1:0.6:0.01]
tip_taper_h        = 1.2;   //[0.5:3:0.1]

// Drive recess (Phillips-like cross, shallow)
drive_depth        = 0.9;   //[0.3:1.5:0.05]
drive_arm_w        = 1.2;   //[0.6:2.0:0.05]
drive_arm_len      = 5.2;   //[3.0:7.0:0.1]
drive_taper        = 0.35;  //[0.0:0.8:0.05]

// Small overlap to guarantee watertight unions/differences
eps = 0.05;

module cross_recess(depth, arm_w, arm_len, taper=0.3) {
    // A simple tapered cross recess made from two perpendicular tapered slots
    // depth is along -Z (we'll position it at the head top and cut downward)
    linear_extrude(height=depth + eps, scale=max(0.01, 1 - taper), center=false)
        union() {
            square([arm_len, arm_w], center=true);
            square([arm_w, arm_len], center=true);
        }
}

module pan_head_screw(d=shank_diameter, L=length_under_head, hd=head_diameter, hh=head_height) {
    r_shank = d/2;
    r_head  = hd/2;

    // Pan head profile: cylindrical skirt + domed top (spherical cap)
    skirt_h = hh * 0.55;
    dome_h  = hh - skirt_h;

    // Sphere radius chosen so cap height = dome_h and base radius = r_head
    // R = (a^2 + h^2) / (2h)
    dome_R = (r_head*r_head + dome_h*dome_h) / (2*dome_h);

    // Thread core radius (minor)
    r_core = max(r_shank - thread_depth, 0.01);

    // Ensure tip taper doesn't exceed length
    tip_h = min(tip_taper_h, max(L - 0.2, 0.2));

    difference() {
        // ONE connected solid: head at z=[0..hh], shank at z=[-L..0]
        union() {
            // Shank (threaded approximation)
            translate([0,0,-L])
            union() {
                // Core cylinder
                cylinder(h=L + eps, r=r_core, center=false);

                // Helical ridge (major diameter)
                // Start slightly above the very tip to avoid degenerate geometry
                translate([0,0,tip_h*0.15])
                    linear_extrude(
                        height=(L - tip_h*0.15),
                        twist=360*(L - tip_h*0.15)/thread_pitch,
                        slices=max(ceil(L*16), 80),
                        center=false
                    )
                        translate([r_shank - thread_depth/2, 0, 0])
                            circle(r=thread_depth/2);

                // Tip taper (conical)
                cylinder(h=tip_h, r1=r_shank, r2=max(r_core*0.6, 0.01), center=false);
            }

            // Head: skirt + dome, connected at z=0 (underside of head)
            union() {
                // Skirt
                cylinder(h=skirt_h + eps, r=r_head, center=false);

                // Dome (spherical cap), clipped to height dome_h
                translate([0,0,skirt_h])
                intersection() {
                    translate([0,0,dome_R - dome_h])
                        sphere(r=dome_R);
                    cylinder(h=dome_h + eps, r=r_head + eps, center=false);
                }
            }
        }

        // Drive recess cut into the top of the head (downward from z=hh)
        // Positioned so it is visible in orthographic side views as well.
        translate([0,0,hh - drive_depth])
            cross_recess(
                depth=drive_depth,
                arm_w=drive_arm_w,
                arm_len=min(drive_arm_len, hd - 1.0),
                taper=drive_taper
            );
    }
}

pan_head_screw();