// Flat teardrop/triangular mounting plate with two rounded lobes and 4 through-holes
// Target bounding box: 18.3 x 21.6 x 2.5 mm (X x Y x Z)

$fn = 96;

// --- Parameters (mm) ---
bbox_X = 18.3;
bbox_Y = 21.6;
T      = 2.5;

lobe_r = 5.0;          // outer lobe radius (bottom corners)
tip_r  = 2.0;          // rounded tip radius (top)

hole_big_d   = 4.8;
hole_small_d = 2.2;

big_hole_offset_x = 6.8;
big_hole_offset_y = 5.8;

small_hole_spacing_x = 6.0;
small_hole_offset_y  = 0.0;

overlap = 0.2;

// --- Derived geometry to enforce bounding box ---
y_bottom = -bbox_Y/2 + lobe_r;   // lobe centers sit so outer edge hits -bbox_Y/2
y_top    =  bbox_Y/2 - tip_r;    // tip circle center so outer edge hits +bbox_Y/2

// Place lobe centers so outermost X hits +/- bbox_X/2
x_lobe = bbox_X/2 - lobe_r;

// --- 2D outline (teardrop/triangular with two lobes) ---
module outline2d() {
    hull() {
        translate([-x_lobe, y_bottom]) circle(r=lobe_r);
        translate([ x_lobe, y_bottom]) circle(r=lobe_r);
        translate([0,       y_top   ]) circle(r=tip_r);
    }
}

// --- Holes (2 big in lobes, 2 small near center) ---
module holes3d() {
    // Big holes in lobes
    translate([-big_hole_offset_x, -big_hole_offset_y, 0])
        cylinder(d=hole_big_d, h=T + 2*overlap, center=true);
    translate([ big_hole_offset_x, -big_hole_offset_y, 0])
        cylinder(d=hole_big_d, h=T + 2*overlap, center=true);

    // Small holes near center
    translate([-small_hole_spacing_x/2, small_hole_offset_y, 0])
        cylinder(d=hole_small_d, h=T + 2*overlap, center=true);
    translate([ small_hole_spacing_x/2, small_hole_offset_y, 0])
        cylinder(d=hole_small_d, h=T + 2*overlap, center=true);
}

// --- Final solid ---
difference() {
    linear_extrude(height=T, center=true, convexity=10)
        outline2d();
    holes3d();
}