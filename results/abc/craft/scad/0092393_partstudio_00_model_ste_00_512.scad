// Dimension-calibrated (target: 0.09 x 0.09 x 0.01 mm)
scale([0.923909, 0.913643, 0.800134])
{
// Thin octagonal annular ring with circular inner opening,
// 8 square through-holes (one per facet), and segmented/beveled outer faces.

// ---------- Parameters (mm) ----------
bbox_X = 0.09;                 // target overall X (approx)
bbox_Y = 0.09;                 // target overall Y (approx)
T = 0.01;                      // thickness (plate-like)

outer_flat_to_flat = 0.09;     // octagon flat-to-flat
inner_d = 0.045;               // circular inner diameter

hole_count = 8;                // fixed at 8
hole_size = 0.008;             // square hole size
hole_radial_center = 0.037;    // radius to hole centers (near perimeter)

bevel_depth = 0.002;           // radial inset for bevel
bevel_z = 0.003;               // height of bevel region from each face (<= T/2 recommended)

eps = 0.0005;
$fn = 96;

// ---------- Derived ----------
outer_apothem = outer_flat_to_flat/2;                 // distance center->flat
outer_R = outer_apothem / cos(180/8);                 // distance center->vertex
inner_R = inner_d/2;

// keep bevel sane for very thin parts
bevel_z_eff = min(bevel_z, T/2 - eps);
bevel_depth_eff = min(bevel_depth, outer_R - inner_R - 2*eps);

// ---------- Helpers ----------
module octagon2d(R) {
    polygon(points=[
        for (i=[0:7]) [ R*cos(45*i), R*sin(45*i) ]
    ]);
}

module ring_core() {
    // clean octagonal outer, circular inner
    difference() {
        linear_extrude(height=T, center=true)
            octagon2d(outer_R);
        cylinder(r=inner_R, h=T+2*eps, center=true);
    }
}

module holes() {
    // 8 evenly spaced square through-holes, aligned with facets (0,45,...)
    for (i=[0:hole_count-1]) {
        rotate([0,0,i*360/hole_count])
            translate([hole_radial_center, 0, 0])
                cube([hole_size, hole_size, T+2*eps], center=true);
    }
}

module segmented_outer_bevels() {
    // Create a segmented/beveled appearance by subtracting 8 wedge-like cuts
    // near the outer perimeter on both faces.
    // Each cut is a trapezoidal prism (in XY) extruded only near the top/bottom.
    w_ang = 360/hole_count;                 // 45 deg
    half_ang = w_ang/2;
    ang_margin = 6;                        // leaves small "seams" between segments
    a1 = -half_ang + ang_margin;
    a2 =  half_ang - ang_margin;

    r_outer = outer_R + 2*eps;
    r_inner = outer_R - bevel_depth_eff;

    // 2D trapezoid in polar sector (a1..a2) between r_inner..r_outer
    module bevel_sector_2d() {
        polygon(points=[
            [ r_outer*cos(a1), r_outer*sin(a1) ],
            [ r_outer*cos(a2), r_outer*sin(a2) ],
            [ r_inner*cos(a2), r_inner*sin(a2) ],
            [ r_inner*cos(a1), r_inner*sin(a1) ]
        ]);
    }

    // top and bottom bevel cuts
    for (i=[0:hole_count-1]) {
        rotate([0,0,i*w_ang]) {
            // top cut
            translate([0,0, T/2 - bevel_z_eff/2])
                linear_extrude(height=bevel_z_eff+2*eps, center=true)
                    bevel_sector_2d();

            // bottom cut
            translate([0,0,-T/2 + bevel_z_eff/2])
                linear_extrude(height=bevel_z_eff+2*eps, center=true)
                    bevel_sector_2d();
        }
    }
}

// ---------- Final ----------
difference() {
    ring_core();
    holes();
    segmented_outer_bevels();
}
}
