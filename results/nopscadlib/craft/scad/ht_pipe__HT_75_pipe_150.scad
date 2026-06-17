$fn = 128;

// Parameters
length_mm = 150; //[75:300:1]
include_end_fitting = 1; //[0:1:1]
ht75_outer_diameter_mm = 75; //[60:90:0.5]
ht75_wall_thickness_mm = 2.7; //[1.5:5.4:0.1]
fitting_length_mm = 25; //[0:60:1]
fitting_od_increase_mm = 6; //[2:15:0.5]
fitting_wall_extra_mm = 1.3; //[0.2:4:0.1]
socket_depth_mm = 18; //[8:40:1]
socket_clearance_mm = 0.6; //[0.2:1.5:0.1]
connection_overlap_mm = 1; //[0.5:2:0.1]

// Robustness
eps = 0.02;

// Derived radii
outer_r = ht75_outer_diameter_mm/2;
inner_r = max(eps, outer_r - ht75_wall_thickness_mm);

fitting_outer_r = outer_r + fitting_od_increase_mm/2;
fitting_inner_r = max(eps, outer_r - (ht75_wall_thickness_mm + fitting_wall_extra_mm));

// Socket (female) bore radius inside fitting
socket_r = max(eps, inner_r + socket_clearance_mm);

// Clamp lengths to avoid invalid geometry
fit_len = max(0, fitting_length_mm);
sock_depth = min(max(0, socket_depth_mm), fit_len);
overlap = max(0, connection_overlap_mm);

// Main pipe (hollow)
module ht_pipe_segment_hollow() {
    difference() {
        cylinder(h=length_mm, r=outer_r, center=false);
        translate([0, 0, -eps])
            cylinder(h=length_mm + 2*eps, r=inner_r, center=false);
    }
}

// End fitting as an added sleeve (solid ring) that overlaps into the pipe
module end_fitting_sleeve() {
    if (include_end_fitting && fit_len > 0) {
        // Place sleeve so it is connected: it starts overlap mm before the pipe end
        z_start = length_mm - fit_len - overlap;
        sleeve_h = fit_len + overlap;

        difference() {
            // Outer sleeve
            translate([0, 0, z_start])
                cylinder(h=sleeve_h, r=fitting_outer_r, center=false);

            // Inner bore of sleeve (thicker wall than pipe)
            translate([0, 0, z_start - eps])
                cylinder(h=sleeve_h + 2*eps, r=fitting_inner_r, center=false);

            // Socket relief at the very end (female opening)
            if (sock_depth > 0)
                translate([0, 0, length_mm - sock_depth])
                    cylinder(h=sock_depth + eps, r=socket_r, center=false);
        }
    }
}

// Complete HT pipe (one connected solid)
module ht_pipe() {
    color([0.85, 0.85, 0.8])
    union() {
        ht_pipe_segment_hollow();
        end_fitting_sleeve();
    }
}

ht_pipe();