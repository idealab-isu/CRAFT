// M5 Grub (Set) Screw with internal hex socket and helical external thread
// One connected solid, no floating parts, no arbitrary translations.

// ---------- Parameters ----------
nom_d = 5.0;                 //[2.5:10.0:0.1]  // nominal thread diameter (M5 -> 5)
pitch = 0.8;                 //[0.4:1.6:0.05]  // M5 coarse = 0.8
length = 10.0;               //[5.0:20.0:0.5]  // overall length
thread_length = 10.0;        //[5.0:20.0:0.5]  // threaded length (typically full for grub)
major_d = 5.0;               //[2.5:10.0:0.1]
minor_d = 4.1;               //[2.0:8.2:0.1]   // approx for M5 external minor
socket_af = 2.5;             //[1.5:5.0:0.1]   // hex across flats (typical M5 set screw ~2.5)
socket_depth = 2.5;          //[1.0:6.0:0.1]
chamfer = 0.3;               //[0.1:1.0:0.05]
overlap = 0.2;               //[0.05:1.0:0.05]

// Tip style (cup point default)
cup_point_depth = 0.5;       //[0.1:1.0:0.05]
cup_point_d = 3.0;           //[1.5:4.8:0.1]

// Thread profile controls (simple triangular thread)
thread_depth = 0.35;         //[0.1:0.6:0.05]  // radial height of thread above minor radius
thread_profile_w = 0.45;     //[0.2:1.0:0.05]  // profile width (approx)
thread_slices_per_turn = 28; //[12:80:1]       // smoothness of helix

// Rendering quality
$fn = 80;

// ---------- Helpers ----------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

major_r = major_d/2;
minor_r = minor_d/2;
thread_r = minor_r + thread_depth;

L = length;
Lt = clamp(thread_length, 0, L);

// Place thread centered on body, spanning Lt
thread_z0 = -L/2;
thread_z1 = thread_z0 + Lt;

// Hex socket radius from across-flats
hex_r = socket_af/(2*cos(30)); // circumradius for 6-gon

// ---------- Geometry Modules ----------
module hex_prism(h, r) {
    cylinder(h=h, r=r, center=true, $fn=6);
}

// Simple external helical thread using linear_extrude(twist=...)
module external_thread(z0, z1) {
    h = z1 - z0;
    turns = h / pitch;
    slices = max(12, ceil(abs(turns) * thread_slices_per_turn));

    // 2D triangular-ish profile located at radius ~minor_r
    // It extrudes along Z with twist to form a helix.
    translate([0,0,(z0+z1)/2])
        linear_extrude(height=h, center=true, twist=turns*360, slices=slices, convexity=10)
            polygon(points=[
                [minor_r - 0.02, -thread_profile_w/2],
                [thread_r,        0],
                [minor_r - 0.02,  thread_profile_w/2]
            ]);
}

// Main body cylinder (minor diameter) + thread union gives major diameter
module screw_body_with_thread() {
    union() {
        // Core at minor diameter for full length (grub screws are fully threaded)
        cylinder(h=L, r=minor_r, center=true);

        // External thread along Lt starting at bottom
        if (Lt > 0.01)
            external_thread(thread_z0, thread_z1);

        // Slight end chamfers (add material removal later via difference)
        // Keep as part of body; chamfers will be cut by subtractive cones.
    }
}

// Subtractive features: hex socket, end chamfers, cup point
module subtractive_features() {
    union() {
        // Internal hex socket from top end
        translate([0,0, L/2 - socket_depth/2])
            hex_prism(h=socket_depth + overlap, r=hex_r);

        // Top chamfer (remove a small cone frustum)
        translate([0,0, L/2 - chamfer/2])
            cylinder(h=chamfer + overlap, r1=major_r + 0.01, r2=max(0.01, major_r - chamfer), center=true);

        // Bottom chamfer (remove a small cone frustum)
        translate([0,0, -L/2 + chamfer/2])
            cylinder(h=chamfer + overlap, r1=max(0.01, major_r - chamfer), r2=major_r + 0.01, center=true);

        // Cup point: concave-ish dimple made by subtracting a cone
        // Positioned at bottom end, cutting inward.
        translate([0,0, -L/2 + cup_point_depth/2])
            cylinder(h=cup_point_depth + overlap, r1=cup_point_d/2, r2=0.01, center=true);
    }
}

// ---------- Assemble ----------
module complete_model() {
    difference() {
        screw_body_with_thread();
        subtractive_features();
    }
}

complete_model();