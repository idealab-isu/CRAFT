$fn = 96;

// Target dimensions (mm)
thread_diameter_mm = 3.0;
length_mm          = 10.0;   // under-head length
head_diameter_mm   = 5.5;
head_height_mm     = 3.0;

// Socket (approx for M3)
socket_af_mm       = 2.5;    // across flats
socket_depth_mm    = 1.6;

// Small overlaps to ensure watertight unions/differences
eps = 0.02;
overlap_mm = 0.2;

// Derived
shank_r = thread_diameter_mm/2;
head_r  = head_diameter_mm/2;

// Hex socket radius (circumradius) from across-flats
hex_R = (socket_af_mm/2)/cos(30);

// One connected solid: socket head cap screw
module socket_head_cap_screw() {
    difference() {
        union() {
            // Shank (under head): z from 0 to length_mm
            cylinder(r=shank_r, h=length_mm, center=false);

            // Head: sits on top of shank, z from length_mm to length_mm+head_height_mm
            translate([0, 0, length_mm - overlap_mm])
                cylinder(r=head_r, h=head_height_mm + overlap_mm, center=false);

            // Tip chamfer (simple cone) at end of shank, connected
            tip_chamfer_h = min(0.8, length_mm/2);
            translate([0, 0, length_mm - tip_chamfer_h])
                cylinder(r1=shank_r, r2=0, h=tip_chamfer_h, center=false);
        }

        // Hex socket recess in head (cut from top)
        translate([0, 0, length_mm + head_height_mm - socket_depth_mm])
            cylinder(r=hex_R, h=socket_depth_mm + eps, center=false, $fn=6);
    }
}

socket_head_cap_screw();