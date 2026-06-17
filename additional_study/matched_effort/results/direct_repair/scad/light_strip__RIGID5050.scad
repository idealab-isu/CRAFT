$fn = 96;

// Light strip: rigid (simple rigid bar with rounded ends and a shallow diffuser recess)

length = 300;
width  = 18;
height = 8;

end_radius = width/2;

diffuser_margin = 1.2;
diffuser_depth  = 1.2;

module rounded_bar(L, W, H) {
    r = W/2;
    linear_extrude(height=H)
        hull() {
            translate([r, r]) circle(r=r);
            translate([L - r, r]) circle(r=r);
        }
}

difference() {
    // Main rigid body
    rounded_bar(length, width, height);

    // Shallow top recess for diffuser
    translate([diffuser_margin, diffuser_margin, height - diffuser_depth])
        rounded_bar(length - 2*diffuser_margin, width - 2*diffuser_margin, diffuser_depth + 0.01);
}