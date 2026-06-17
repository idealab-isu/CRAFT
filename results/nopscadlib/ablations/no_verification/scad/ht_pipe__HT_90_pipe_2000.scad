// Parameters
nominal_diameter_mm = 90; //[45:180:1]
length_mm = 2000; //[1000:4000:10]
pipe_wall_mm = 3.2; //[1.6:6.4:0.1]
socket_length_mm = 60; //[30:120:1]
socket_wall_extra_mm = 2.0; //[0.5:6.0:0.1]
overlap_mm = 1.0; //[0.5:2.0:0.1]

$fn = 128;

// HT Pipe - one connected solid (hollow tube with one enlarged socket end)
module ht_pipe() {
    r_out = nominal_diameter_mm/2;
    r_in  = r_out - pipe_wall_mm;
    r_sock_out = r_out + socket_wall_extra_mm;

    // Ensure valid geometry
    r_in_safe = max(0.01, r_in);
    sock_len_safe = min(socket_length_mm, length_mm);

    // Socket starts slightly before the pipe end to guarantee overlap/connection
    z_sock0 = length_mm - sock_len_safe - overlap_mm;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER solid: pipe + socket (unioned and overlapping)
        union() {
            cylinder(h=length_mm, r=r_out, center=false);

            translate([0, 0, z_sock0])
                cylinder(h=sock_len_safe + overlap_mm, r=r_sock_out, center=false);
        }

        // INNER void: continuous bore through entire length (including socket)
        translate([0, 0, -overlap_mm])
            cylinder(h=length_mm + 2*overlap_mm, r=r_in_safe, center=false);
    }
}

ht_pipe();