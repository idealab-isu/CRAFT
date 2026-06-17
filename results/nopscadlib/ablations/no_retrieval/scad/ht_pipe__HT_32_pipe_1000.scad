// HT pipe: HT 32, length 1000 mm
// One connected solid, no floating parts, no text/labels.

$fn = 128;

// Parameters
pipe_length       = 1000;   //[500:2000:1]
outer_diameter    = 32;     //[16:64:0.5]
wall_thickness    = 2;      //[1:4:0.1]
socket_length     = 50;     //[25:100:1]
socket_wall_extra = 1.5;    //[0.5:3:0.1]
chamfer_length    = 2;      //[0.5:6:0.1]
eps               = 0.05;   // small overlap to avoid coincident faces

// Derived
R  = outer_diameter/2;
Ri = R - wall_thickness;
Rs = R + socket_wall_extra;

// Safety clamps (avoid invalid/empty geometry)
Ri_safe = max(0.1, Ri);
ch_safe = min(chamfer_length, min(pipe_length/2 - eps, socket_length/2 - eps));

module ht_pipe_32_L1000() {

    // Build as a single connected solid: (outer union) - (inner union)
    difference() {

        // OUTER SOLID (pipe + socket)
        union() {
            // Main outer cylinder, centered
            cylinder(h=pipe_length, r=R, center=true);

            // Socket outer enlargement at +Z end, connected by formula
            translate([0, 0, pipe_length/2 - socket_length/2])
                cylinder(h=socket_length, r=Rs, center=true);
        }

        // INNER VOID (bore + socket bore + end chamfers)
        union() {
            // Main bore through full length (slightly longer for clean subtraction)
            cylinder(h=pipe_length + 2*eps, r=Ri_safe, center=true);

            // Socket bore (explicit, connected)
            translate([0, 0, pipe_length/2 - socket_length/2])
                cylinder(h=socket_length + 2*eps, r=Ri_safe, center=true);

            // Male-end inner chamfer (add to void) at -Z end
            translate([0, 0, -pipe_length/2 + ch_safe/2])
                cylinder(h=ch_safe + 2*eps, r1=Ri_safe, r2=0, center=true);

            // Socket-end inner chamfer (add to void) at +Z end
            translate([0, 0,  pipe_length/2 - ch_safe/2])
                cylinder(h=ch_safe + 2*eps, r1=Ri_safe, r2=0, center=true);
        }
    }
}

ht_pipe_32_L1000();