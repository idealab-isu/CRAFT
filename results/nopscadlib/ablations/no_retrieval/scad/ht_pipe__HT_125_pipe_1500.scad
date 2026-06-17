// HT pipe: HT 125, length 1500 mm
// Axis: pipe runs along X so FRONT/BACK/LEFT/RIGHT orthographic views show the length.

$fn = 192;

// Parameters
pipe_length = 1500;                 // mm
outer_diameter = 125;               // mm (HT 125)
wall_thickness = 3.2;               // mm
socket_length = 70;                 // mm
socket_wall_extra = 2.0;            // mm (extra radius at socket OD)
gasket_groove_width = 8;            // mm (axial)
gasket_groove_depth = 1.5;          // mm (radial into bore)
gasket_groove_offset_from_end = 18; // mm from socket end
chamfer_length = 6;                 // mm (axial)
chamfer_radial = 2;                 // mm (radial)
overlap = 1;                        // mm (boolean robustness)

// Derived
R  = outer_diameter/2;
Ri = R - wall_thickness;
Rs = R + socket_wall_extra;

// Helpers (pipe axis is X)
module cylx(h, r, center=true) rotate([0,90,0]) cylinder(h=h, r=r, center=center);
module cylx_taper(h, r1, r2, center=true) rotate([0,90,0]) cylinder(h=h, r1=r1, r2=r2, center=center);

// Main model
module ht_pipe() {
    // Key X positions (pipe centered at origin)
    x_plus_end =  pipe_length/2;
    x_minus_end = -pipe_length/2;

    // Socket occupies [x_plus_end - socket_length, x_plus_end]
    x_socket_center = x_plus_end - socket_length/2;

    // Chamfers at ends
    x_chamfer_plus_center  = x_plus_end  - chamfer_length/2;
    x_chamfer_minus_center = x_minus_end + chamfer_length/2;

    // Gasket groove center (measured from socket end at +X)
    x_groove_center = x_plus_end - gasket_groove_offset_from_end - gasket_groove_width/2;

    difference() {
        // OUTER SOLID (one connected piece)
        union() {
            // Main outer body
            cylx(pipe_length, R, center=true);

            // Socket outer enlargement at +X end, overlapping into body
            translate([x_socket_center + overlap/2, 0, 0])
                cylx(socket_length + overlap, Rs, center=true);

            // Outer chamfer at socket end (+X): taper down to main OD
            translate([x_chamfer_plus_center, 0, 0])
                cylx_taper(chamfer_length + overlap, Rs, R, center=true);

            // Outer chamfer at spigot end (-X): taper up to main OD
            translate([x_chamfer_minus_center, 0, 0])
                cylx_taper(chamfer_length + overlap, max(0.01, R - chamfer_radial), R, center=true);
        }

        // INNER BORE (through)
        cylx(pipe_length + 2*overlap, Ri, center=true);

        // Socket internal relief (slightly larger bore inside socket region)
        // Ensures a visible socket/bell feature in section and renders.
        translate([x_socket_center + overlap/2, 0, 0])
            cylx(socket_length + overlap, Ri + socket_wall_extra, center=true);

        // Gasket groove (cut into bore near socket end)
        translate([x_groove_center, 0, 0])
            cylx(gasket_groove_width, Ri + socket_wall_extra + gasket_groove_depth, center=true);

        // Inner chamfer at socket end (+X) to open the bore
        translate([x_chamfer_plus_center, 0, 0])
            cylx_taper(chamfer_length + 2*overlap, Ri + socket_wall_extra, Ri + socket_wall_extra + chamfer_radial, center=true);

        // Inner chamfer at spigot end (-X) to open the bore
        translate([x_chamfer_minus_center, 0, 0])
            cylx_taper(chamfer_length + 2*overlap, Ri + chamfer_radial, Ri, center=true);
    }
}

color([0.85, 0.85, 0.8]) ht_pipe();