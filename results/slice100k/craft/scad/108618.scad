// Thin rectangular faceplate/frame with rounded corners and cutouts
// Bounding box: 65 x 20 x 4 mm

$fn = 64;

// Parameters
plate_L = 65.0;                 // overall length (X)
plate_W = 20.0;                 // overall width  (Y)
plate_T = 4.0;                  // thickness      (Z)
corner_R = 2.5;                 // outer corner radius

win_W = 22.0;                   // window width (X)
win_H = 12.0;                   // window height (Y)
win_gap = 5.0;                  // gap between windows (X)
win_y_offset = 0.0;             // window center offset (Y)

center_hole_d = 2.0;            // two small holes between windows
center_hole_pitch_y = 6.0;      // spacing in Y between the two center holes

mount_hole_d = 3.0;             // mounting holes near ends
mount_hole_x_inset = 5.0;       // inset from each end in X
mount_hole_y_offset = 0.0;      // mounting hole offset in Y

cut_through_extra = 1.0;        // extra cut depth to ensure through-cuts

// Helpers
module rounded_rect_2d(L, W, R) {
    // Robust rounded rectangle in 2D
    R2 = min(R, min(L, W)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R2), sy*(W/2 - R2)])
                circle(r=R2);
    }
}

module plate_solid() {
    linear_extrude(height=plate_T, center=true)
        rounded_rect_2d(plate_L, plate_W, corner_R);
}

module window_cutout(xc) {
    translate([xc, win_y_offset, 0])
        cube([win_W, win_H, plate_T + 2*cut_through_extra], center=true);
}

module hole_cutout(x, y, d) {
    translate([x, y, 0])
        cylinder(d=d, h=plate_T + 2*cut_through_extra, center=true);
}

// Derived positions
win_center_offset_x = (win_gap/2 + win_W/2);
mount_x = plate_L/2 - mount_hole_x_inset;

// Final model
difference() {
    plate_solid();

    // Two rectangular windows
    window_cutout(-win_center_offset_x);
    window_cutout( win_center_offset_x);

    // Two small circular holes centered between windows (stacked in Y)
    hole_cutout(0,  center_hole_pitch_y/2, center_hole_d);
    hole_cutout(0, -center_hole_pitch_y/2, center_hole_d);

    // Mounting holes near each end
    hole_cutout(-mount_x, mount_hole_y_offset, mount_hole_d);
    hole_cutout( mount_x, mount_hole_y_offset, mount_hole_d);
}