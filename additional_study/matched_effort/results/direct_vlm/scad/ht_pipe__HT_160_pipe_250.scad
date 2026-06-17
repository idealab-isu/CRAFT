$fn = 180;

// HT 160 pipe, length 250 mm (approximate HT socket/bell + sealing groove)
outer_d = 160;      // spigot OD (mm)
length  = 250;      // total length (mm)
wall    = 4.9;      // wall thickness (mm)

inner_d = outer_d - 2*wall;

// Socket/bell parameters (approximation)
socket_len      = 60;                 // length of socket section (mm)
socket_od       = outer_d + 12;       // socket OD (mm)
socket_id       = inner_d + 8;        // socket bore ID (mm) (clearance for spigot)
stop_ring_len   = 6;                  // internal stop ring length (mm)
stop_ring_id    = inner_d + 2;        // smaller ID to form a stop (mm)

// Sealing groove (internal) parameters (approximation)
groove_z_from_end = 18;              // from socket mouth (mm)
groove_w          = 7;               // groove width (mm)
groove_depth      = 2.2;             // radial depth into socket bore (mm)

// Chamfers
mouth_chamfer_h   = 2.0;             // socket mouth chamfer height (mm)
mouth_chamfer_in  = 2.0;             // socket mouth chamfer radial inwards (mm)
spigot_chamfer_h  = 2.0;             // spigot end chamfer height (mm)
spigot_chamfer_in = 1.5;             // spigot end chamfer radial inwards (mm)

eps = 0.05;

module ht_pipe_ht160(L=length, od=outer_d, id=inner_d) {
    // Derived
    spigot_len = L - socket_len;

    difference() {
        // OUTER SOLID (connected): spigot + socket
        union() {
            // Spigot outer
            cylinder(d=od, h=spigot_len, center=false);

            // Socket outer (connected to spigot with slight overlap)
            translate([0,0,spigot_len - 0.5])
                cylinder(d=socket_od, h=socket_len + 0.5, center=false);
        }

        // INNER VOID (connected): spigot bore + socket bore + stop ring + chamfers + groove
        union() {
            // Spigot bore
            translate([0,0,-eps])
                cylinder(d=id, h=spigot_len + eps, center=false);

            // Socket bore (larger)
            translate([0,0,spigot_len - eps])
                cylinder(d=socket_id, h=socket_len + 2*eps, center=false);

            // Internal stop ring: reduce bore near socket base
            translate([0,0,spigot_len + socket_len - stop_ring_len - eps])
                cylinder(d=stop_ring_id, h=stop_ring_len + 2*eps, center=false);

            // Socket mouth internal chamfer (funnel)
            translate([0,0,spigot_len - eps])
                cylinder(d1=socket_id + 2*mouth_chamfer_in, d2=socket_id, h=mouth_chamfer_h + eps, center=false);

            // Spigot end internal chamfer (slight)
            translate([0,0,-eps])
                cylinder(d1=id + 2*spigot_chamfer_in, d2=id, h=spigot_chamfer_h + eps, center=false);

            // Sealing groove (internal): annular recess in socket bore
            translate([0,0,spigot_len + groove_z_from_end])
                cylinder(d=socket_id + 2*groove_depth, h=groove_w, center=false);
        }
    }
}

ht_pipe_ht160();