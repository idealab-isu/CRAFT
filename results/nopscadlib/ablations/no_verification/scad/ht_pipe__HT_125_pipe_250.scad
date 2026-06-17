// Parameters
pipe_standard = 1; //[1:1:1]
nominal_size = 125; //[63:250:1]
length_mm = 250; //[125:500:1]
pipe_od = 125; //[63:250:1]
pipe_wall = 3.2; //[1.6:6.4:0.1]
interface_length = 20; //[10:40:1]
interface_radial_add = 2; //[1:6:0.5]
connect_overlap = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
    od = pipe_od;
    wall = pipe_wall;
    id = od - 2*wall;

    sleeve_od = od + 2*interface_radial_add;

    // Robustness / non-degenerate geometry
    eps = 0.05;
    wall_safe = max(wall, eps);
    id_safe = max(od - 2*wall_safe, eps);
    overlap = max(connect_overlap, eps);

    // Sleeve placed at +Z end, overlapping into main pipe by "overlap"
    sleeve_center_z = (length_mm/2 - interface_length/2) + overlap/2;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER: main OD + sleeve OD (connected by overlap)
        union() {
            cylinder(h=length_mm, r=od/2, center=true);

            translate([0, 0, sleeve_center_z])
                cylinder(h=interface_length, r=sleeve_od/2, center=true);
        }

        // INNER VOID: continuous bore through entire part (prevents blank/degenerate CSG)
        // Extend beyond both ends to guarantee a clean subtraction.
        cylinder(h=length_mm + interface_length + 4*overlap, r=id_safe/2, center=true);
    }
}

ht_pipe();