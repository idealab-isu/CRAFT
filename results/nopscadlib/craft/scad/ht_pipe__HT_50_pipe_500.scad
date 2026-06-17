// Parameters
pipe_standard = 0; //[0:1:1]
nominal_diameter_mm = 50; //[25:100:1]
length_mm = 500; //[250:1000:1]
pipe_od_mm = 50; //[25:100:0.5]
pipe_wall_mm = 2.2; //[1.1:4.4:0.1]
fitting_length_mm = 35; //[18:70:1]
fitting_wall_extra_mm = 1.8; //[0.9:3.6:0.1]
fitting_stop_thickness_mm = 3; //[1.5:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 128;

module ht_pipe() {
    od_r = pipe_od_mm/2;
    id_r = max(0.01, od_r - pipe_wall_mm);

    socket_od_r = od_r + fitting_wall_extra_mm;

    // Stop ring is an INTERNAL shoulder: it reduces the bore locally.
    // Choose a smaller bore radius in the stop region (must stay > 0).
    stop_bore_r = max(0.01, id_r - fitting_stop_thickness_mm);

    // Z extents (pipe centered at 0)
    pipe_zmin = -length_mm/2;
    pipe_zmax =  length_mm/2;

    // Socket on +Z end, overlapping into pipe by overlap_mm (connectivity)
    socket_zmin = pipe_zmax - overlap_mm;
    socket_zmax = pipe_zmax + fitting_length_mm - overlap_mm;

    // Stop shoulder located inside socket near its inner end (toward pipe)
    stop_zmin = socket_zmin;
    stop_zmax = socket_zmin + fitting_stop_thickness_mm;

    color([0.85, 0.85, 0.8])
    difference() {
        // OUTER: one connected solid (pipe + socket sleeve)
        union() {
            translate([0,0,(pipe_zmin+pipe_zmax)/2])
                cylinder(r=od_r, h=pipe_zmax-pipe_zmin, center=true);

            translate([0,0,(socket_zmin+socket_zmax)/2])
                cylinder(r=socket_od_r, h=socket_zmax-socket_zmin, center=true);
        }

        // INNER: one continuous cavity, with a reduced-bore segment to form the stop shoulder
        union() {
            // Main bore through pipe and into socket up to stop start
            translate([0,0,(pipe_zmin+stop_zmin)/2])
                cylinder(r=id_r, h=(stop_zmin-pipe_zmin) + 2*overlap_mm, center=true);

            // Reduced bore at stop region (creates internal shoulder)
            translate([0,0,(stop_zmin+stop_zmax)/2])
                cylinder(r=stop_bore_r, h=(stop_zmax-stop_zmin) + 2*overlap_mm, center=true);

            // Bore after stop through remainder of socket
            translate([0,0,(stop_zmax+socket_zmax)/2])
                cylinder(r=id_r, h=(socket_zmax-stop_zmax) + 2*overlap_mm, center=true);
        }
    }
}

ht_pipe();