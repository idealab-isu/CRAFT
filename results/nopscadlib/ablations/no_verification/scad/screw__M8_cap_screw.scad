// Socket Head Cap Screw (single connected solid)
// Target: 8.0mm thread diameter, 13.0mm head diameter, head height 8.0mm, 10mm long (under head)

// Parameters
thread_diameter_mm = 8.0;      //[4.0:16.0:0.1]
length_under_head_mm = 10.0;   //[5.0:40.0:0.1]
head_diameter_mm = 13.0;       //[6.5:26.0:0.1]
head_height_mm = 8.0;          //[4.0:20.0:0.1]
socket_af_mm = 6.0;            //[3.0:12.0:0.1]
socket_depth_mm = 5.0;         //[2.5:12.0:0.1]
overlap_mm = 0.2;              //[0.05:1.0:0.05]

// Simple cosmetic thread parameters (kept subtle so it still reads as M8)
thread_pitch_mm = 1.25;
thread_depth_mm = 0.35;        // radial depth of thread ridges (visual only)
thread_fn = 96;

$fn = 96;

module threaded_shank(d_major, len, pitch, depth) {
    // Base cylinder + helical ridge (visual thread)
    union() {
        cylinder(d=d_major - 2*depth, h=len, center=false, $fn=thread_fn);

        // Helical ridge approximating external thread
        linear_extrude(height=len, twist=360*len/pitch, slices=max(ceil(len*8), 40), center=false, convexity=10)
            translate([d_major/2 - depth, 0, 0])
                circle(r=depth, $fn=24);
    }
}

module socket_head_cap_screw() {
    // Place head on top, shank extends downward; top of head at z=0
    // Overall: head height + length_under_head
    difference() {
        union() {
            // Head (slight under-head fillet via hull with a tiny step)
            hull() {
                translate([0, 0, -head_height_mm])
                    cylinder(d=head_diameter_mm, h=overlap_mm, center=false, $fn=96);
                translate([0, 0, -overlap_mm])
                    cylinder(d=head_diameter_mm, h=overlap_mm, center=false, $fn=96);
            }

            // Shank (connected to underside of head with overlap)
            translate([0, 0, -head_height_mm - length_under_head_mm + overlap_mm])
                threaded_shank(thread_diameter_mm, length_under_head_mm, thread_pitch_mm, thread_depth_mm);
        }

        // Hex socket cut from top face downwards
        // Hex cylinder uses circumscribed radius = AF/(2*cos(30))
        socket_r = socket_af_mm/(2*cos(30));
        translate([0, 0, -socket_depth_mm])
            cylinder(r=socket_r, h=socket_depth_mm + overlap_mm, center=false, $fn=6);

        // Small lead-in chamfer for socket (conical)
        translate([0, 0, -overlap_mm])
            cylinder(r1=socket_r*1.05, r2=socket_r, h=overlap_mm, center=false, $fn=6);
    }
}

socket_head_cap_screw();