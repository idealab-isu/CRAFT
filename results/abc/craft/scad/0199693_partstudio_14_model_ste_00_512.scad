// Dimension-calibrated (target: 0.03 x 0.02 x 0.03 mm)
scale([0.949393, 1.203751, 0.707991])
{
// U-shaped bracket/frame with two circular end plates (side cheeks) and a straight crossbar.
// One connected solid, symmetric about mid-plane. Units in meters (as in original params).

$fn = 96;

// Parameters
bbox_L = 0.03; //[0.015:0.06:0.001]
bbox_W = 0.02; //[0.01:0.04:0.001]
bbox_H = 0.03; //[0.015:0.06:0.001]

plate_t = 0.004; //[0.002:0.008:0.0005]
plate_r = 0.01; //[0.005:0.02:0.0005]
plate_hole_r = 0.006; //[0.003:0.012:0.0005]

crossbar_L = 0.03; //[0.015:0.06:0.001]
crossbar_W = 0.008; //[0.004:0.016:0.0005]
crossbar_t = 0.004; //[0.002:0.008:0.0005]

plate_offset_from_ends = 0.0; //[0.0:0.01:0.0005]

window_side_L = 0.008; //[0.004:0.016:0.0005]
window_side_W = 0.003; //[0.0015:0.006:0.0005]
window_center_diamond_diag = 0.006; //[0.003:0.012:0.0005]

small_cutout_r = 0.0015; //[0.00075:0.003:0.00025]
small_cutout_count = 2; //[1:4:1]
small_cutout_radial_offset = 0.007; //[0.0035:0.014:0.0005]

overlap = 0.001; //[0.0005:0.002:0.0001]
fillet_r = 0.0008; //[0.0004:0.0016:0.0001]

// Derived placement (ensure connectivity)
plate_x = (crossbar_L/2 - plate_t/2 - plate_offset_from_ends);
crossbar_x_len = crossbar_L - 2*plate_offset_from_ends;

// Place crossbar so it overlaps into plates by "overlap" (connects as one solid)
crossbar_z = plate_r - crossbar_t/2 + overlap;

// Helpers
module diamond_window(diag, h){
    linear_extrude(height=h, center=true)
        polygon(points=[
            [ diag/2, 0],
            [ 0, diag/2],
            [-diag/2, 0],
            [ 0,-diag/2]
        ]);
}

module end_plate_at(xpos){
    // Plate lies in YZ plane, thickness along X
    translate([xpos, 0, 0])
        rotate([0,90,0])
            cylinder(r=plate_r, h=plate_t, center=true);
}

module end_plate_holes_at(xpos){
    // Central opening
    translate([xpos, 0, 0])
        rotate([0,90,0])
            cylinder(r=plate_hole_r, h=plate_t + 2*overlap, center=true);

    // Smaller cutouts (2 or 4)
    for (i = [0:small_cutout_count-1]) {
        ang = (small_cutout_count==2) ? (i==0 ? 90 : 270) : (i*360/small_cutout_count);
        translate([xpos, 0, 0])
            rotate([0,90,0])
                translate([small_cutout_radial_offset*cos(ang), small_cutout_radial_offset*sin(ang), 0])
                    cylinder(r=small_cutout_r, h=plate_t + 2*overlap, center=true);
    }
}

module crossbar_solid(){
    translate([0, 0, crossbar_z])
        cube([crossbar_x_len, crossbar_W, crossbar_t], center=true);
}

module crossbar_windows(){
    // Two elongated windows (rectangular/hex-like by being long and narrow)
    win_h = crossbar_t + 2*overlap;
    x_off = crossbar_x_len/4;

    translate([-x_off, 0, crossbar_z])
        cube([window_side_L, window_side_W, win_h], center=true);

    translate([ x_off, 0, crossbar_z])
        cube([window_side_L, window_side_W, win_h], center=true);

    // Central diamond window
    translate([0, 0, crossbar_z])
        diamond_window(window_center_diamond_diag, win_h);
}

module u_frame_raw(){
    difference(){
        union(){
            // Connected union: crossbar overlaps into plates
            crossbar_solid();
            end_plate_at(-plate_x);
            end_plate_at( plate_x);
        }
        // Cutouts
        end_plate_holes_at(-plate_x);
        end_plate_holes_at( plate_x);
        crossbar_windows();
    }
}

module u_frame_fillet(){
    // Keep fillet modest; minkowski increases size slightly
    minkowski(){
        u_frame_raw();
        sphere(r=fillet_r);
    }
}

// Final Output (single connected solid)
u_frame_fillet();
}
