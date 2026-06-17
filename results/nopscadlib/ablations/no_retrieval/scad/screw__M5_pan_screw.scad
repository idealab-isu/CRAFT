$fn = 128;

// Requested dimensions (mm)
shank_d = 5.0;
length  = 10.0;     // under-head length
head_d  = 10.0;
head_h  = 3.95;

// Thread parameters (visual, not a standards-perfect thread)
pitch        = 1.0;     // mm per turn (M5 coarse is ~0.8; 1.0 is more visible)
thread_depth = 0.45;    // radial depth of thread (kept modest for robustness)
thread_len   = length;  // threaded along full shank

// Detailing
tip_chamfer = 0.6;
drive_recess_d = 4.0;
drive_recess_h = 2.0;
overlap = 0.08;

// Derived
shank_r = shank_d/2;
head_r  = head_d/2;

// Place underside of head at z=0, head above, shank below (z negative)
module pan_head_solid() {
    // Pan head: cylindrical skirt + rounded dome (spherical cap)
    skirt_h = head_h * 0.55;
    dome_h  = head_h - skirt_h;

    // Sphere radius for cap height dome_h with base radius head_r:
    // R = (a^2 + h^2) / (2h)
    R = (head_r*head_r + dome_h*dome_h) / (2*dome_h);

    union() {
        // cylindrical skirt (0..skirt_h)
        translate([0,0,skirt_h/2])
            cylinder(h=skirt_h, r=head_r, center=true);

        // spherical cap dome (skirt_h..head_h)
        translate([0,0,skirt_h])
            intersection() {
                translate([0,0,R - dome_h]) sphere(r=R);
                translate([0,0,dome_h/2]) cylinder(h=dome_h, r=head_r, center=true);
            }

        // tiny under-head overlap to guarantee watertight union with shank
        translate([0,0,-overlap/2])
            cylinder(h=overlap, r=head_r, center=true);
    }
}

module drive_recess() {
    // Simple Phillips-like cross recess made from two slots
    slot_w = drive_recess_d * 0.35;
    slot_l = drive_recess_d * 0.95;

    translate([0,0,head_h - drive_recess_h/2])
        union() {
            cube([slot_l, slot_w, drive_recess_h], center=true);
            cube([slot_w, slot_l, drive_recess_h], center=true);
        }
}

module tip_chamfered_end() {
    // Chamfer at very bottom of screw (near z=-length)
    tip_flat_r = max(0.2, shank_r*0.15);

    union() {
        // conical chamfer occupying last tip_chamfer of length
        translate([0,0,-length + tip_chamfer/2])
            cylinder(h=tip_chamfer, r1=shank_r, r2=tip_flat_r, center=true);

        // tiny flat end face
        translate([0,0,-length + overlap/2])
            cylinder(h=overlap, r=tip_flat_r, center=true);
    }
}

// Helical thread as a triangular ridge wrapped around a core cylinder.
// Uses linear_extrude with twist; axis is Z.
module external_thread(thread_r, depth, pitch, len) {
    turns = len / pitch;

    // 2D profile in XY: a small triangle located at radius thread_r (outer radius).
    // It spans radially inward by 'depth' and has tangential thickness ~0.55*pitch.
    tang = pitch * 0.55;

    // Place profile so its outermost point is at radius = thread_r
    // and it extends inward to (thread_r - depth).
    linear_extrude(height=len, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
        translate([thread_r - depth, 0])
            polygon(points=[
                [0, -tang/2],
                [depth, 0],
                [0,  tang/2]
            ]);
}

module threaded_shank() {
    // Core cylinder slightly under nominal so thread ridge brings it back near shank_r
    core_r = shank_r - thread_depth;

    union() {
        // Core (z from -length..0)
        translate([0,0,-length/2])
            cylinder(h=length, r=core_r, center=true);

        // Thread ridge (z from -length..0), with tiny overlap into head at z=0
        translate([0,0,-length])
            external_thread(thread_r=shank_r, depth=thread_depth, pitch=pitch, len=thread_len + overlap);
    }
}

module screw_complete() {
    difference() {
        union() {
            // Head (z from 0..head_h)
            pan_head_solid();

            // Threaded shank (z from -length..0), overlapped into head
            translate([0,0,overlap/2]) threaded_shank();

            // Tip chamfer at bottom end
            tip_chamfered_end();
        }

        // Recess cut into head
        drive_recess();
    }
}

color("Silver") screw_complete();