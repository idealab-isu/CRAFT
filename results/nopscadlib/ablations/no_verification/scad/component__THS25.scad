// Parameters
body_length = 50; //[25:100:1]
body_width  = 30; //[15:60:1]
body_height = 10; //[5:20:1]

eps = 0.01;

// Ensure visible, non-degenerate geometry and one connected solid
color([0.85, 0.85, 0.8])
union() {
    // Main body
    cube([body_length, body_width, body_height], center=true);

    // Connected top rib (adds clear 3D detail; overlaps slightly to guarantee connectivity)
    rib_h = max(2, body_height * 0.35);
    rib_w = body_width * 0.35;
    rib_l = body_length * 0.70;

    translate([0, 0, body_height/2 + rib_h/2 - 1])
        cube([rib_l, rib_w, rib_h], center=true);
}