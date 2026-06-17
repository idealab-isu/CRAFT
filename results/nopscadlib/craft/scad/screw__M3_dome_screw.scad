// Dome head screw (M3) - 3.0mm diameter, 5.7mm head diameter, 1.65mm head height, 10mm long
// Single connected solid, smooth dome head, simple thread representation (helical ridge)

$fn = 96;

// Parameters (kept for compatibility; only screw geometry is produced)
nominal_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 5.7; //[3:11.4:0.1]
head_height_mm = 1.65; //[0.8:3.3:0.05]

// Thread representation controls
thread_pitch_mm = 0.5;          // visual pitch
thread_depth_mm = 0.18;         // radial height of ridge
thread_width_mm = 0.35;         // thickness of ridge
thread_start_taper_mm = 0.8;    // taper at tip for nicer look
overlap_mm = 0.05;

module dome_head_screw(d=3, L=10, hd=5.7, hh=1.65) {
    shaft_r = d/2;
    head_r  = hd/2;

    // Place underside of head at z=0, shaft extends to z=-L, head extends to z=+hh
    union() {
        // Shaft core (minor diameter) so thread ridge is visible
        cylinder(h=L, r=max(shaft_r - thread_depth_mm, shaft_r*0.85), center=false);

        // Thread ridge (simple helical band)
        // Built as a helical extrusion of a small rectangle offset from axis.
        // Taper the last part near the tip by blending with a cone.
        intersection() {
            union() {
                linear_extrude(height=L, twist=-(360*L/thread_pitch_mm), slices=max(ceil(L*12), 60), convexity=10)
                    translate([shaft_r - thread_depth_mm/2, 0, 0])
                        square([thread_depth_mm, thread_width_mm], center=true);

                // Tip taper to avoid a blunt end and keep it connected
                translate([0,0,0])
                    cylinder(h=thread_start_taper_mm, r1=shaft_r*0.2, r2=shaft_r, center=false);
            }
            // Keep thread within a reasonable outer diameter
            cylinder(h=L, r=shaft_r + thread_depth_mm + 0.02, center=false);
        }

        // Dome head: spherical cap trimmed to exact head height and diameter
        // Sphere radius chosen so that cap base radius equals head_r at z=0 and cap height is hh.
        // R = (a^2 + h^2) / (2h)
        R = (head_r*head_r + hh*hh) / (2*hh);
        zc = hh - R; // sphere center z so that top is at z=hh

        difference() {
            // Cap volume
            intersection() {
                translate([0,0,zc]) sphere(r=R);
                // Limit to z in [0, hh]
                translate([0,0,hh/2]) cube([hd*2, hd*2, hh + overlap_mm], center=true);
            }

            // No socket/recess (smooth dome head)
        }

        // Small fillet-like blend at head/shaft junction (ensures clean connection)
        // Slight overlap into both parts
        translate([0,0,-overlap_mm])
            cylinder(h=overlap_mm + 0.25, r1=shaft_r, r2=head_r*0.98, center=false);
    }
}

dome_head_screw(nominal_diameter_mm, length_mm, head_diameter_mm, head_height_mm);