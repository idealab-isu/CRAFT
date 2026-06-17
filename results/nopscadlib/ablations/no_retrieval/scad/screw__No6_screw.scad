$fn = 96;

// Pan head screw (simplified) per request:
// shank diameter 3.5mm, head diameter 6.7mm, head height 2.2mm, 10mm long (under-head)

shank_d = 3.5;
shank_L = 10;          // under-head length (z from 0 down to -shank_L)

head_d  = 6.7;
head_h  = 2.2;

// Pan head shaping
head_crown_h = 0.7;                 // rounded top height (within head_h)
head_side_h  = head_h - head_crown_h;
head_top_r   = head_d/2 - 0.6;      // slightly smaller top radius for pan profile

// Drive recess (simple Phillips-like cross)
recess_depth = 1.2;
recess_w     = 0.8;
recess_L     = head_d * 0.75;

// Threads (visual, simplified helical ridge)
thread_L = 8.5;                     // threaded length from tip upward
pitch    = 0.7;                     // approx for M3.5
thread_h = 0.25;                    // radial height of ridge
thread_w = 0.35;                    // ridge thickness

// Tip
tip_h = 0.6;

// Connectivity overlap (1–2mm requested)
overlap = 1.0;

// Helpers
function clamp(x,a,b) = x<a ? a : (x>b ? b : x);

// Coordinate convention:
// z=0 at underside of head (bearing surface)
// head spans z=[0, head_h]
// shank spans z=[-shank_L, 0]
// tip extends below shank to z=-(shank_L+tip_h)

module pan_head_solid() {
    union() {
        // cylindrical side portion: z=[0, head_side_h]
        cylinder(h=head_side_h, r=head_d/2, center=false);

        // rounded crown (frustum-like hull): z=[head_side_h, head_h]
        translate([0,0, head_side_h])
            hull() {
                cylinder(h=0.01, r=head_d/2, center=false);
                translate([0,0, head_crown_h])
                    cylinder(h=0.01, r=head_top_r, center=false);
            }

        // smooth dome cap (kept within head height)
        translate([0,0, head_h - head_crown_h*0.35])
            scale([1,1,0.55])
                sphere(r=head_top_r);
    }
}

module drive_recess() {
    // Cut into the top of the head
    translate([0,0, head_h - recess_depth])
        union() {
            cube([recess_L, recess_w, recess_depth + overlap*2], center=false);
            translate([-recess_w/2, -recess_L/2, 0])
                cube([recess_w, recess_L, recess_depth + overlap*2], center=false);
        }
}

module shank_core() {
    // Connected to head underside at z=0, extends down to z=-shank_L with overlap into head
    translate([0,0, -shank_L])
        cylinder(h=shank_L + overlap, r=shank_d/2, center=false); // z=[-shank_L, +overlap]
}

module tip_cone() {
    // Connected to shank end at z=-shank_L, extends to z=-(shank_L+tip_h)
    translate([0,0, -shank_L - tip_h])
        cylinder(
            h=tip_h + overlap, // overlap upward into shank
            r1=clamp(shank_d/2 - 0.8, 0.2, shank_d/2),
            r2=shank_d/2,
            center=false
        );
}

module thread_ridge() {
    // Helical ridge around shank, spanning z=[-thread_L, 0] with overlap into head and downwards
    turns = thread_L / pitch;
    translate([0,0, -thread_L - overlap])
        linear_extrude(
            height=thread_L + overlap*2,
            twist=turns*360,
            slices=max(ceil(turns*40), 80),
            convexity=10
        )
            translate([shank_d/2 + thread_h/2 - 0.05, 0, 0])
                square([thread_h + 0.1, thread_w], center=true);
}

module screw_solid() {
    union() {
        // Head with recess
        difference() {
            pan_head_solid();
            drive_recess();
        }

        // Shank + tip + threads (all connected)
        shank_core();
        tip_cone();
        thread_ridge();
    }
}

color("DimGray") screw_solid();