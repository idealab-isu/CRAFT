$fn = 140;

// Target dimensions (mm)
shaft_d = 4.0;
shaft_l = 10.0;   // from tip to underside of head

head_d  = 7.8;
head_h  = 3.3;

// Derived
shaft_r = shaft_d/2;
head_r  = head_d/2;

// Pan head shaping (keeps max diameter and height exact)
under_fillet_h = 0.35;   // small underhead fillet height
top_flat_h     = 0.45;   // small flat at very top
side_bulge_r   = 0.95;   // controls "dome" fullness (radius of side arc)

// Threads (simple helical ridge approximation)
pitch        = 0.7;      // mm
thread_h     = 0.35;     // radial height of thread above major radius
thread_start = 0.6;      // unthreaded tip length
thread_end   = 0.4;      // unthreaded near head
thread_len   = max(0, shaft_l - thread_start - thread_end);

// Drive recess (simple Phillips-like cross)
recess_depth = 1.6;
slot_w       = 0.9;
slot_l       = head_d * 0.78;

// Small overlaps to ensure one connected solid / robust booleans
eps = 0.05;

// 2D profile for pan head (rotate_extrude around Z)
// z: 0..head_h, x: radius
module pan_head() {
    // Build a domed pan head using a circular arc for the side wall.
    // Arc endpoints:
    //  A at (xA, zA) = (shaft_r, under_fillet_h)
    //  B at (xB, zB) = (head_r, head_h - top_flat_h)
    // Choose circle radius = side_bulge_r and solve for center (xC, zC) with xC < xA.
    xA = shaft_r;
    zA = under_fillet_h;
    xB = head_r;
    zB = head_h - top_flat_h;
    R  = max(side_bulge_r, 0.6);

    dx = xB - xA;
    dz = zB - zA;
    d  = sqrt(dx*dx + dz*dz);

    // Ensure feasible arc
    Ruse = max(R, d/2 + 0.001);

    mx = (xA + xB)/2;
    mz = (zA + zB)/2;

    // Perpendicular unit vector to chord
    ux = -dz / d;
    uz =  dx / d;

    h = sqrt(max(0, Ruse*Ruse - (d/2)*(d/2)));

    // Two possible centers; pick the one with smaller x (bulges outward)
    xC1 = mx + ux*h;  zC1 = mz + uz*h;
    xC2 = mx - ux*h;  zC2 = mz - uz*h;

    xC = (xC1 < xC2) ? xC1 : xC2;
    zC = (xC1 < xC2) ? zC1 : zC2;

    // Angles for arc sampling
    a1 = atan2(zA - zC, xA - xC);
    a2 = atan2(zB - zC, xB - xC);

    // Ensure we traverse the shorter arc in the correct direction
    // We'll step from a1 to a2 with sign chosen to keep points between zA..zB.
    steps = 40;
    da_raw = a2 - a1;
    da = (da_raw > 180) ? (da_raw - 360) :
         (da_raw < -180) ? (da_raw + 360) : da_raw;

    rotate_extrude(convexity=10)
        polygon(points=concat(
            // Axis to underside
            [[0,0],
             [shaft_r, 0],
             [shaft_r, under_fillet_h]],

            // Side arc points from A to B
            [for (i=[0:steps])
                let(a = a1 + da*i/steps)
                [xC + Ruse*cos(a), zC + Ruse*sin(a)]
            ],

            // Top flat to axis
            [[head_r, head_h],
             [0, head_h]]
        ));
}

// Simple pointed tip (optional but keeps length verifiable and looks like a screw)
module tip() {
    tip_h = 0.8;
    cylinder(h=tip_h, r1=0.2, r2=shaft_r, center=false);
}

// Helical thread ridge using linear_extrude with twist of a thin triangular rib
module threads() {
    if (thread_len > 0) {
        turns = thread_len / pitch;
        // Rib thickness along circumference
        rib_t = 0.35;

        translate([0,0,thread_start])
            linear_extrude(height=thread_len, twist=turns*360, slices=ceil(turns*40), convexity=10)
                // Place a small triangular rib at major radius
                translate([shaft_r - thread_h, 0, 0])
                    polygon(points=[
                        [0, -rib_t/2],
                        [thread_h, 0],
                        [0,  rib_t/2]
                    ]);
    }
}

module shank_with_threads() {
    union() {
        // Core shank (minor diameter approximated as shaft_d - 2*thread_h)
        core_d = max(0.2, shaft_d - 2*thread_h);
        cylinder(d=core_d, h=shaft_l, center=false);

        // Add helical ridge threads
        threads();

        // Tip connected at bottom (no arbitrary translate)
        tip();
    }
}

module screw_solid() {
    union() {
        // Shank from z=0..shaft_l
        shank_with_threads();

        // Head connected at z=shaft_l with slight overlap
        translate([0,0,shaft_l - eps])
            pan_head();
    }
}

module drive_recess() {
    // Subtractive cross recess from top of head
    translate([0, 0, shaft_l + head_h - recess_depth])
        union() {
            for (a = [0, 90]) {
                rotate([0, 0, a])
                    translate([-slot_l/2, -slot_w/2, -eps])
                        cube([slot_l, slot_w, recess_depth + 2*eps], center=false);
            }
        }
}

difference() {
    screw_solid();
    drive_recess();
}