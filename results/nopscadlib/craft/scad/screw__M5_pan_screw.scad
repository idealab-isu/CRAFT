// Pan head screw: 5.0mm shank diameter, 10.0mm head diameter, 3.95mm head height, 10.0mm length
// One connected solid. Simple connected helical thread approximation (not floating).

$fn = 128;

// Parameters (mm)
shaft_diameter_mm = 5.0;
head_diameter_mm  = 10.0;
head_height_mm    = 3.95;
length_mm         = 10.0;

// Thread (visual approximation)
thread_pitch_mm         = 0.8;
thread_depth_mm         = 0.35;   // radial height of ridge above shank core
thread_profile_width_mm = 0.55;   // tangential width of ridge
threaded_fraction       = 1.0;

// Head details (pan dome)
head_dome_height_mm     = 1.25;   // dome rise above cylindrical skirt (<= head_height_mm)
head_skirt_height_mm    = head_height_mm - head_dome_height_mm;

// Recess (simple cross)
socket_radius_factor    = 0.55;
socket_depth_factor     = 0.55;
socket_slot_width_mm    = 1.2;

overlap_mm = 0.08;

// Coordinate convention:
// z=0 at underside of head (top of shank). Shank extends to negative z.

module pan_head_screw() {
    shank_r = shaft_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    thread_len = max(0, length_mm * threaded_fraction);

    // Ensure the thread ridge is connected to the shank core:
    // core radius is slightly smaller than shank_r, ridge starts slightly inside core.
    core_r = max(shank_r - thread_depth_mm, 0.01);
    ridge_radial = thread_depth_mm + 0.02; // a touch extra to guarantee overlap
    ridge_center_r = core_r - overlap_mm + ridge_radial/2;

    union() {
        // Shank core (minor diameter)
        translate([0,0,-length_mm])
            cylinder(h=length_mm + overlap_mm, r=core_r, center=false);

        // Helical thread ridge (connected, not floating)
        if (thread_len > 0) {
            translate([0,0,-thread_len])
                linear_extrude(
                    height = thread_len + overlap_mm,
                    twist  = 360*(thread_len/thread_pitch_mm),
                    slices = max(ceil(thread_len*24), 120),
                    center = false
                )
                    translate([ridge_center_r, 0, 0])
                        square([ridge_radial, thread_profile_width_mm], center=true);
        }

        // Head (pan head: cylindrical skirt + domed top), connected at z=0
        difference() {
            union() {
                // Cylindrical skirt
                cylinder(h=head_skirt_height_mm, r=head_r, center=false);

                // Domed top via rotate_extrude profile (smooth pan)
                translate([0,0,head_skirt_height_mm])
                    rotate_extrude()
                        polygon(points=[
                            [0, 0],
                            [head_r, 0],
                            [head_r, 0.25*head_dome_height_mm],
                            [0.92*head_r, 0.70*head_dome_height_mm],
                            [0.70*head_r, 0.95*head_dome_height_mm],
                            [0.00, head_dome_height_mm]
                        ]);

                // Blend into shank (small under-head fillet-ish cone), ensures robust connection
                // Underside at z=0, taper down to shank radius over a short height into the head.
                cylinder(h=min(0.6, head_skirt_height_mm), r1=head_r*0.92, r2=shank_r, center=false);
            }

            // Cross recess cut into top
            recess_r = head_r * socket_radius_factor;
            recess_h = head_height_mm * socket_depth_factor;

            translate([0,0,head_height_mm - recess_h + overlap_mm])
                intersection() {
                    cylinder(r=recess_r, h=recess_h + 2*overlap_mm, center=false);
                    union() {
                        translate([0,0,(recess_h + 2*overlap_mm)/2])
                            cube([2*recess_r + 2*overlap_mm, socket_slot_width_mm, recess_h + 2*overlap_mm], center=true);
                        translate([0,0,(recess_h + 2*overlap_mm)/2])
                            cube([socket_slot_width_mm, 2*recess_r + 2*overlap_mm, recess_h + 2*overlap_mm], center=true);
                    }
                }
        }
    }
}

// Build: underside of head at z=0, shank extends to z=-length_mm
pan_head_screw();