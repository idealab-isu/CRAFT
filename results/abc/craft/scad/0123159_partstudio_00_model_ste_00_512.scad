// Dimension-calibrated (target: 0.04 x 0.04 x 0.01 mm)
scale([0.900000, 0.900000, 0.500000])
{
// Flat circular disk with thick outer rim, recessed inner face,
// five octagonal through-holes on a bolt circle, and a central square through-hole.

// ---------------- Parameters (meters) ----------------
D = 0.04;                 //[0.02:0.08:0.001] overall diameter
T = 0.01;                 //[0.005:0.02:0.001] overall thickness
rim_radial_w = 0.006;     //[0.003:0.012:0.001] rim radial width
pocket_depth = 0.003;     //[0.001:0.006:0.001] recess depth from top face
bolt_circle_d = 0.022;    //[0.011:0.044:0.001] bolt circle diameter
oct_hole_flat_d = 0.006;  //[0.003:0.012:0.001] octagon across flats
center_square_w = 0.004;  //[0.002:0.008:0.001] center square width
oct_hole_count = 5;       //[3:12:1]
oct_hole_rotation_deg = 0;//[-180:180:1]
eps_overlap = 0.001;      //[0.0005:0.002:0.0005]

// ---------------- Derived ----------------
R = D/2;
inner_R = max(0.001, R - rim_radial_w);
pocket_depth_clamped = min(pocket_depth, T - 2*eps_overlap);

// ---------------- Helpers ----------------
module octagon_2d(across_flats) {
    // Regular octagon with given across-flats dimension.
    // For a regular n-gon, apothem a = across_flats/2, circumradius r = a / cos(180/n).
    n = 8;
    a = across_flats/2;
    r = a / cos(180/n);
    polygon(points=[ for (i=[0:n-1]) [ r*cos(i*360/n), r*sin(i*360/n) ] ]);
}

module oct_hole_at(x, y, rot=0) {
    translate([x, y, 0])
        rotate([0, 0, rot])
            linear_extrude(height=T + 2*eps_overlap, center=true)
                octagon_2d(oct_hole_flat_d);
}

module all_through_holes() {
    union() {
        // Central square through-hole
        cube([center_square_w, center_square_w, T + 2*eps_overlap], center=true);

        // Octagonal holes on bolt circle
        for (i = [0:oct_hole_count-1]) {
            ang = i * 360 / oct_hole_count + oct_hole_rotation_deg;
            x = (bolt_circle_d/2) * cos(ang);
            y = (bolt_circle_d/2) * sin(ang);
            oct_hole_at(x, y, ang);
        }
    }
}

// ---------------- Model ----------------
module disk_with_recess_and_holes() {
    difference() {
        // Base disk (axially symmetric)
        cylinder(h=T, r=R, center=true, $fn=180);

        // Recessed inner pocket from the TOP face only (leaves thick outer rim)
        // Pocket occupies z in [T/2 - pocket_depth, T/2]
        translate([0, 0, T/2 - pocket_depth_clamped/2 + eps_overlap/2])
            cylinder(h=pocket_depth_clamped + eps_overlap, r=inner_R, center=true, $fn=180);

        // Through-holes
        all_through_holes();
    }
}

// Final output: one connected solid
disk_with_recess_and_holes();
}
