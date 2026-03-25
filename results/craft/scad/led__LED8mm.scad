// 8.0mm THT LED, 9.2mm body height (lens + cylindrical body above flange)
// One connected solid, no extra mounting plate/fasteners

// Parameters
led_diameter_mm = 8;            //[4:16:0.1]
body_height_mm = 9.2;           //[4.6:18.4:0.1]  // height above flange top
rim_thickness_mm = 1.2;         //[0.6:2.4:0.1]
rim_diameter_mm = 9.2;          //[8.2:18.4:0.1]
lead_pitch_mm = 2.54;           //[1.27:5.08:0.01]
lead_thickness_mm = 0.5;        //[0.25:1:0.01]
lead_length_mm = 12;            //[6:24:0.5]
eps_mm = 0.2;                   //[0.05:1:0.05]

$fn = 96;

// Derived
r_body = led_diameter_mm/2;
r_rim  = rim_diameter_mm/2;

// Split body height into cylindrical section + domed lens
lens_h_mm = min(r_body, body_height_mm*0.55);          // typical dome height, capped
cyl_h_mm  = max(0.01, body_height_mm - lens_h_mm);     // remaining straight body

// Connectivity overlap (1–2mm) to guarantee attachment between cylinder and dome
dome_overlap_mm = 1.2;

// Z references
z_rim_center = rim_thickness_mm/2;
z_rim_top    = rim_thickness_mm;
z_body_cyl_center = z_rim_top + cyl_h_mm/2;
z_lens_base  = z_rim_top + cyl_h_mm;

// Leads: ensure they touch/overlap into flange for a single connected solid
lead_overlap_into_rim_mm = max(eps_mm, rim_thickness_mm*0.35);
z_lead_top = z_rim_top - lead_overlap_into_rim_mm;
z_lead_center = z_lead_top - lead_length_mm/2;

// LED body (cyl + dome + flange)
module led_body() {
    union() {
        // Flange/base
        translate([0,0,z_rim_center])
            cylinder(r=r_rim, h=rim_thickness_mm, center=true);

        // Cylindrical body above flange
        translate([0,0,z_body_cyl_center])
            cylinder(r=r_body, h=cyl_h_mm, center=true);

        // Domed lens (spherical cap) ATTACHED to cylinder with overlap
        // Build a spherical cap whose base plane is slightly BELOW z_lens_base
        // so it intersects the cylinder by dome_overlap_mm.
        translate([0,0,z_lens_base - dome_overlap_mm])
            intersection() {
                // Sphere centered so that its bottom touches the (shifted) base plane
                translate([0,0,lens_h_mm])
                    sphere(r=r_body);

                // Keep only the part above the (shifted) base plane
                // (cube spans from z=0 upward in this local coordinate system)
                translate([0,0,(lens_h_mm + eps_mm)/2])
                    cube([2*r_body+2*eps_mm, 2*r_body+2*eps_mm, lens_h_mm+2*eps_mm], center=true);
            }
    }
}

// Leads (rectangular pins)
module leads() {
    for (sx = [-1, 1]) {
        translate([sx*lead_pitch_mm/2, 0, z_lead_center])
            cube([lead_thickness_mm, lead_thickness_mm, lead_length_mm], center=true);
    }
}

// Assembly: single connected solid (union)
union() {
    led_body();
    leads();
}