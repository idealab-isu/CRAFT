// Pan head screw (single connected solid)
// Spec: shank Ø3.5mm, head Ø6.7mm, head height 2.2mm, length 10mm (under head)

$fn = 128;

// Dimensions (mm)
shank_d = 3.5;
head_d  = 6.7;
head_h  = 2.2;
len_uhead = 10;

// Overlap to guarantee manifold unions (1–2mm as requested)
ov = 1.0;

// Thread (cosmetic, full 360° around shank)
pitch = 0.7;                 // mm
thread_rad = 0.18;           // radial height of ridge
thread_w = pitch * 0.55;     // axial thickness of ridge
thread_len = len_uhead;      // fully threaded under head
turns = thread_len / pitch;
slices = max(48, ceil(turns * 28));

// Tip
tip_h = min(1.2, len_uhead * 0.18);
tip_r2 = 0.25;

// Drive recess (simple Phillips-like cross)
drive_depth = head_h * 0.55;
drive_w = head_d * 0.18;
drive_len = head_d * 0.78;
drive_cone_r1 = (head_d/2) * 0.42;
drive_cone_r2 = (head_d/2) * 0.30;

// Pan head profile (rounded, not countersunk)
head_skirt_h = head_h * 0.35;                 // short vertical skirt
head_top_flat_r = (head_d/2) * 0.22;          // small flat at top
head_dome_h = head_h - head_skirt_h;

module pan_head_profile_2d() {
    // rotate_extrude profile: x=radius, y=z; z=0 underside, z=head_h top
    polygon(points=[
        [0, 0],
        [head_d/2, 0],
        [head_d/2, head_skirt_h],

        // dome approximation (monotonic radius decrease)
        [head_d/2 * 0.92, head_skirt_h + head_dome_h * 0.35],
        [head_d/2 * 0.70, head_skirt_h + head_dome_h * 0.70],
        [head_top_flat_r, head_h],

        [0, head_h]
    ]);
}

module drive_recess() {
    // Subtract from head; placed near top, does not break through
    // Use small epsilon only for boolean robustness (not for connectivity)
    eps = 0.15;
    translate([0, 0, head_h - drive_depth/2 + eps])
    union() {
        cylinder(h=drive_depth + 2*eps, r1=drive_cone_r1, r2=drive_cone_r2, center=true);
        cube([drive_len, drive_w, drive_depth + 2*eps], center=true);
        cube([drive_w, drive_len, drive_depth + 2*eps], center=true);
    }
}

module thread_ridge_full() {
    // Helical ridge added around the shank (full circumference)
    // Ensure it overlaps the shank and reaches into the tip region slightly.
    major_r = shank_d/2 + thread_rad;
    translate([major_r - thread_rad/2, 0, -(thread_len + ov)])
        linear_extrude(height=thread_len + ov, twist=360*turns, slices=slices, convexity=10)
            square([thread_rad, thread_w], center=true);
}

module screw() {
    union() {
        // Head (rounded pan head) with recess
        difference() {
            rotate_extrude(convexity=10) pan_head_profile_2d();
            drive_recess();
        }

        // Shank core: extend slightly into head and slightly past nominal end for overlap
        // Top of shank at z=+ov, bottom at z=-(len_uhead+ov)
        translate([0, 0, (ov - (len_uhead + ov))/2])
            cylinder(h=len_uhead + 2*ov, r=shank_d/2, center=true);

        // Tip cone: attach to shank end with 1mm overlap (no gap)
        // Cone top at z=-(len_uhead - ov), cone bottom at z=-(len_uhead + tip_h)
        translate([0, 0, -(len_uhead + tip_h/2 - ov/2)])
            cylinder(h=tip_h + ov, r1=shank_d/2, r2=tip_r2, center=true);

        // Cosmetic thread ridge (connected to shank)
        thread_ridge_full();
    }
}

screw();