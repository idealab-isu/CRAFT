// Screw parameters (mm)
shaft_diameter_mm = 3.5; //[1.75:7:0.05]
length_mm = 10;          //[5:20:0.5]          // overall length (tip to head top)
head_diameter_mm = 7.0;  //[3.5:14:0.1]
head_height_mm = 2.5;    //[1.25:5:0.1]

// Thread + tip + drive parameters
thread_pitch_mm = 0.8;          //[0.4:1.6:0.05]
thread_depth_mm = 0.35;         //[0.15:0.7:0.05]   // radial depth
tip_length_mm = 1.2;            //[0.5:3:0.1]
drive_slot_width_mm = 1.2;      //[0.6:2.5:0.05]
drive_slot_depth_mm = 0.9;      //[0.3:2:0.05]
drive_slot_length_mm = 5.2;     //[2:7:0.1]

// Quality
$fn = 96;

// Small overlap to ensure watertight unions/differences
eps = 0.05;

// Derived
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;

shank_len = max(0, length_mm - head_height_mm);          // under-head to tip
thread_len = max(0, shank_len - tip_length_mm);          // threaded portion length

// Helical thread using linear_extrude(twist=...)
module helical_thread(major_r, depth, pitch, len) {
    turns = (pitch > 0) ? (len / pitch) : 0;
    // Triangular thread profile (approx) placed at major radius
    linear_extrude(height=len, twist=turns*360, slices=max(12, ceil(turns*48)), convexity=10)
        translate([major_r - depth, 0, 0])
            polygon(points=[
                [0, -pitch*0.22],
                [depth, 0],
                [0,  pitch*0.22]
            ]);
}

// Simple pan head with a slotted drive
module screw() {
    union() {
        // Main solid (head + shank core + tip + thread ridge)
        difference() {
            union() {
                // Shank core (minor diameter)
                translate([0,0, head_height_mm])
                    cylinder(h=shank_len, r=max(0.01, shaft_r - thread_depth_mm), $fn=$fn);

                // Pointed/tapered tip (cone) connected to shank
                translate([0,0, head_height_mm + shank_len - tip_length_mm])
                    cylinder(h=tip_length_mm, r1=max(0.01, shaft_r - thread_depth_mm), r2=0.01, $fn=$fn);

                // Thread ridge (major diameter) over threaded length
                if (thread_len > 0)
                    translate([0,0, head_height_mm])
                        helical_thread(major_r=shaft_r, depth=thread_depth_mm, pitch=thread_pitch_mm, len=thread_len);

                // Head (pan/cylindrical)
                cylinder(h=head_height_mm, r=head_r, $fn=$fn);
            }

            // Drive feature: slotted head (subtractive), centered on head top
            translate([0,0, head_height_mm - drive_slot_depth_mm + eps])
                cube([drive_slot_length_mm, drive_slot_width_mm, drive_slot_depth_mm + 2*eps], center=false);
        }
    }
}

color("DimGray") screw();