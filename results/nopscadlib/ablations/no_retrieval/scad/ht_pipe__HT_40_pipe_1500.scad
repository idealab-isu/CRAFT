// HT 40 pipe, 1500 mm long (single connected solid, no text)

// Parameters
pipe_length = 1500;              //[750:3000:1]
outer_diameter = 40;             //[20:80:1]
wall_thickness = 2;              //[1:4:0.1]
socket_length = 60;              //[30:120:1]
socket_outer_diameter = 46;      //[42:60:1]
chamfer_length = 2;              //[1:6:0.5]
overlap = 1;                     //[0.5:2:0.1]

// Quality
$fn = 128;

// Derived
outer_r = outer_diameter/2;
inner_r = outer_r - wall_thickness;
socket_r = socket_outer_diameter/2;

// Safety
inner_r_safe = (inner_r > 0.01) ? inner_r : 0.01;

// Main model (axis along X so FRONT/BACK/LEFT/RIGHT orthographic views show the length)
module ht_pipe_40_1500() {

    // Positions along X (pipe centered at origin)
    x_pipe_min = -pipe_length/2;
    x_pipe_max =  pipe_length/2;

    // Socket extends beyond +X end, but overlaps into the main pipe by "overlap"
    x_socket_min = x_pipe_max - overlap;
    x_socket_max = x_pipe_max + socket_length;

    // Chamfer occupies the last "chamfer_length" at the -X end, with slight overlap
    x_chamfer_min = x_pipe_min - overlap;
    x_chamfer_max = x_pipe_min + chamfer_length;

    difference() {
        // Outer solid (pipe + socket + chamfer), all connected
        union() {
            // Main outer cylinder (along X)
            rotate([0, 90, 0])
                cylinder(h=pipe_length, r=outer_r, center=true);

            // Socket on +X end (connected by overlap)
            translate([(x_socket_min + x_socket_max)/2, 0, 0])
                rotate([0, 90, 0])
                    cylinder(h=(x_socket_max - x_socket_min), r=socket_r, center=true);

            // External chamfer on -X end (frustum), connected by overlap
            translate([(x_chamfer_min + x_chamfer_max)/2, 0, 0])
                rotate([0, 90, 0])
                    cylinder(
                        h=(x_chamfer_max - x_chamfer_min),
                        r1=outer_r,
                        r2=max(outer_r - chamfer_length, 0.01),
                        center=true
                    );
        }

        // Inner bore (through entire part, including socket), extended for clean subtraction
        translate([(x_pipe_min + x_socket_max)/2, 0, 0])
            rotate([0, 90, 0])
                cylinder(
                    h=(x_socket_max - x_pipe_min) + 4*overlap,
                    r=inner_r_safe,
                    center=true
                );
    }
}

color([0.85, 0.85, 0.8])
ht_pipe_40_1500();