// Thin paddle/fixture plate with rounded-rectangle head, window cutout, two through-holes,
// tapered neck, and long rectangular handle.
// Target bounding box: 73 x 20 x 4 mm

$fn = 96;

// Parameters
L = 73.0;
W = 20.0;
T = 4.0;

head_L = 26.0;
head_W = 20.0;
head_R = 5.0;

neck_L = 8.0;

handle_L = 39.0;
handle_W = 10.0;

window_L = 16.0;
window_W = 10.0;

hole_D = 3.0;
hole_offset_from_window_end = 2.5;
hole_offset_from_centerline = 6.0;

eps = 0.2;

// Helpers
module rounded_rect_2d(l, w, r) {
    // Robust rounded rectangle using hull of 4 circles
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(l/2 - r), sy*(w/2 - r)]) circle(r=r);
    }
}

module head_solid() {
    translate([-L/2 + head_L/2, 0, 0])
        linear_extrude(height=T, center=true)
            rounded_rect_2d(head_L, head_W, head_R);
}

module neck_solid() {
    // Trapezoid transition from head_W to handle_W over neck_L
    x0 = -L/2 + head_L;          // head right edge
    x1 = x0 + neck_L;            // neck right edge (meets handle)
    linear_extrude(height=T, center=true)
        polygon(points=[
            [x0, -head_W/2],
            [x1, -handle_W/2],
            [x1,  handle_W/2],
            [x0,  head_W/2]
        ]);
}

module handle_solid() {
    // Handle starts at x = -L/2 + head_L + neck_L and ends at x = +L/2
    x_start = -L/2 + head_L + neck_L;
    translate([x_start + handle_L/2, 0, 0])
        cube([handle_L, handle_W, T], center=true);
}

module window_cutout() {
    translate([-L/2 + head_L/2, 0, 0])
        cube([window_L, window_W, T + 2*eps], center=true);
}

module through_holes() {
    // Place holes near opposite ends of the window, on opposite sides of centerline
    x_center = -L/2 + head_L/2;
    x_left  = x_center - window_L/2 + hole_offset_from_window_end;
    x_right = x_center + window_L/2 - hole_offset_from_window_end;

    for (p = [[x_left,  hole_offset_from_centerline],
              [x_right, -hole_offset_from_centerline]])
        translate([p[0], p[1], 0])
            cylinder(d=hole_D, h=T + 2*eps, center=true);
}

// Final model (one connected solid)
difference() {
    union() {
        head_solid();
        neck_solid();
        handle_solid();
    }
    window_cutout();
    through_holes();
}