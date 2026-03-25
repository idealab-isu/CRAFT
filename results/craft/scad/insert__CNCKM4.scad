// Threaded heat-set insert (parametric)
// Target: 4.0mm OD, 6.3mm length, for M4 screw

$fn = 120;

// Parameters
screw_nominal_diameter_mm = 4.0; //[2.0:8.0:0.1]
internal_thread_pitch_mm = 0.7;  //[0.35:1.4:0.05]

outer_diameter_mm = 4.0;         //[2.0:8.0:0.1]
length_mm = 6.3;                //[3.15:12.6:0.1]

end_chamfer_mm = 0.3;           //[0.15:0.8:0.05]
lead_in_chamfer_mm = 0.3;       //[0.15:0.8:0.05]

rib_count = 12;                 //[6:24:1]
rib_radial_height_mm = 0.25;    //[0.1:0.6:0.05]
rib_tangential_width_mm = 0.6;  //[0.3:1.2:0.05]
rib_length_mm = 5.2;            //[2.6:10.4:0.1]
rib_end_clearance_mm = 0.4;     //[0.2:1.0:0.05]

overlap_mm = 0.8;               //[0.5:2.0:0.1]

// Core barrel diameter (under knurls)
barrel_diameter_mm = 3.5;       //[2.5:7.0:0.1]

// Internal thread approximation (helical cut)
internal_thread_minor_diameter_mm = 3.3; //[2.5:6.5:0.05]

// --- Helpers ---
function clamp(x, a, b) = min(max(x, a), b);

module helical_thread_cut(minor_d, major_d, pitch, h, starts=1) {
    // Simple internal-thread approximation: subtract a helical "tooth" volume.
    // This produces visible helical threading while keeping the model printable.
    minor_r = minor_d/2;
    major_r = major_d/2;

    // Tooth radial depth and tangential thickness (approx)
    tooth_depth = max(0.01, major_r - minor_r);
    tooth_thk   = clamp(pitch*0.45, 0.15, pitch*0.7);

    // Place tooth centered at the pitch radius
    tooth_r = minor_r + tooth_depth/2;

    // Number of turns over height
    turns = h / pitch;

    for (s = [0:starts-1]) {
        rotate([0,0, s*360/starts])
            linear_extrude(height=h, center=true, twist=turns*360, slices=max(ceil(turns*40), 60), convexity=10)
                translate([tooth_r, 0, 0])
                    square([tooth_depth, tooth_thk], center=true);
    }
}

module threaded_insert() {
    // Derived dimensions
    outer_r  = outer_diameter_mm/2;
    barrel_r = barrel_diameter_mm/2;

    // Ensure ribs do not exceed specified outer diameter
    rib_outer_r = min(outer_r, barrel_r + rib_radial_height_mm);
    rib_radial_effective = max(0, rib_outer_r - barrel_r);

    // Rib Z placement so ribs stay within length with end clearances
    rib_h = max(0.01, length_mm - 2*rib_end_clearance_mm);
    rib_z = 0; // centered

    // Internal thread major diameter (approx for M4)
    // Keep it <= barrel diameter to avoid breaking through the wall.
    thread_major_d = min(screw_nominal_diameter_mm, barrel_diameter_mm - 0.2);
    thread_major_d = max(thread_major_d, internal_thread_minor_diameter_mm + 0.2);

    color("Gold")
    difference() {
        union() {
            // Main barrel (core)
            cylinder(r=barrel_r, h=length_mm, center=true);

            // Outer knurls/ribs (connected, protruding outward)
            for (i = [0:rib_count-1]) {
                rotate([0, 0, i*360/rib_count])
                    translate([barrel_r + rib_radial_effective/2 - 0.05, 0, rib_z])
                        cube([rib_radial_effective + 0.10, rib_tangential_width_mm, rib_h], center=true);
            }

            // End chamfers to reach specified outer diameter at ends (typical heat-set profile)
            translate([0, 0,  length_mm/2 - lead_in_chamfer_mm/2])
                cylinder(r1=outer_r, r2=barrel_r, h=lead_in_chamfer_mm, center=true);

            translate([0, 0, -length_mm/2 + end_chamfer_mm/2])
                cylinder(r1=outer_r, r2=barrel_r, h=end_chamfer_mm, center=true);
        }

        // Cylindrical pilot/minor hole (ensures cylindrical bore, not hex-like)
        cylinder(r=internal_thread_minor_diameter_mm/2, h=length_mm + 2*overlap_mm, center=true);

        // Helical internal thread cut (visible threading)
        helical_thread_cut(
            minor_d = internal_thread_minor_diameter_mm,
            major_d = thread_major_d,
            pitch   = internal_thread_pitch_mm,
            h       = length_mm + 2*overlap_mm,
            starts  = 1
        );
    }
}

// Assembly
threaded_insert();