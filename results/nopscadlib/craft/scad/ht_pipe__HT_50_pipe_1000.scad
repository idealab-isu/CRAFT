// HT 50 pipe, 1000 mm long (with one socket end)
// All dimensions in mm

$fn = 128;

// Parameters
nominal_diameter_mm = 50; //[25:100:1]
length_mm = 1000;         //[500:2000:10]
wall_thickness_mm = 1.8;  //[1:4:0.1]

// Base OD (HT50 approx)
od_mm = 50;               //[25:100:1]

// Socket / fitting
fitting_length_mm = 45;        //[20:90:1]
fitting_wall_extra_mm = 1.2;   //[0.5:3:0.1]
fitting_od_extra_mm = 4;       //[2:10:0.5]
socket_depth_mm = 35;          //[15:70:1]

// Robust boolean overlap
overlap_mm = 1; //[0.5:2:0.1]

module ht_pipe() {
    outer_r = od_mm/2;
    inner_r = outer_r - wall_thickness_mm;

    // Safety to avoid empty/invalid geometry
    inner_r = max(inner_r, 0.01);

    fitting_outer_r = outer_r + fitting_od_extra_mm/2;
    socket_inner_r  = inner_r + fitting_wall_extra_mm;

    // Keep socket bore within socket OD
    socket_inner_r = min(socket_inner_r, fitting_outer_r - 0.2);

    total_outer_len = length_mm + fitting_length_mm;

    // Place the whole part centered on Z so it is always visible in previews
    translate([0, 0, -total_outer_len/2])
    color([0.85, 0.85, 0.8])
    difference() {
        // Outer solid (one connected union)
        union() {
            // Main pipe outer
            cylinder(h=length_mm, r=outer_r, center=false);

            // Socket outer (connected with overlap)
            translate([0, 0, length_mm - overlap_mm])
                cylinder(h=fitting_length_mm + overlap_mm, r=fitting_outer_r, center=false);
        }

        // Inner void through the main pipe (open both ends)
        translate([0, 0, -overlap_mm])
            cylinder(h=length_mm + 2*overlap_mm, r=inner_r, center=false);

        // Socket bore (only within socket depth from the far end)
        translate([0, 0, total_outer_len - socket_depth_mm - overlap_mm])
            cylinder(h=socket_depth_mm + 2*overlap_mm, r=socket_inner_r, center=false);
    }
}

ht_pipe();