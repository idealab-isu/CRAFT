// Threaded heat-set insert
// Spec: 25.0mm OD, 18.5mm length, internal thread for 10.0mm screw (M10x1.5 nominal)
// One connected solid, all placements derived from dimensions.

$fn = 180;

// -------------------- Parameters --------------------
outer_diameter = 25.0;          // mm
length         = 18.5;          // mm

// Internal thread (approx. M10x1.5)
thread_major_diameter = 10.0;   // mm
thread_pitch          = 1.5;    // mm
thread_depth_radial   = 0.65;   // mm (approx ISO)
thread_clearance      = 0.20;   // mm (print clearance)

// Derived
thread_minor_diameter = thread_major_diameter - 2*thread_depth_radial;

// End features
outer_chamfer_len = 0.9;        // mm
inner_leadin_len  = 1.4;        // mm

// Heat-set style external knurl/rings
ring_pitch        = 1.15;       // mm
ring_width        = 0.55;       // mm
ring_depth        = 0.55;       // mm (radial protrusion)
ring_start_margin = 1.2;        // mm

// Robustness
eps     = 0.02;
overlap = 0.6;

// -------------------- Helpers --------------------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

// -------------------- Outer body --------------------
module outer_body_with_rings() {
    r0 = outer_diameter/2;

    union() {
        // Base cylinder
        cylinder(h=length, r=r0, center=true);

        // External rings (connected by overlap into base)
        usable_len = length - 2*ring_start_margin;
        n = max(0, floor((usable_len - ring_width) / ring_pitch) + 1);

        for (i = [0 : n-1]) {
            z = -length/2 + ring_start_margin + ring_width/2 + i*ring_pitch;
            translate([0,0,z])
                cylinder(h=ring_width + overlap, r=r0 + ring_depth, center=true);
        }
    }
}

module outer_end_chamfers_cutter() {
    r0 = outer_diameter/2;

    // Top chamfer cutter
    translate([0,0, length/2 - (outer_chamfer_len + overlap)/2])
        cylinder(h=outer_chamfer_len + overlap, r1=r0 + eps, r2=max(0.01, r0 - outer_chamfer_len), center=true);

    // Bottom chamfer cutter
    translate([0,0,-length/2 + (outer_chamfer_len + overlap)/2])
        cylinder(h=outer_chamfer_len + overlap, r1=max(0.01, r0 - outer_chamfer_len), r2=r0 + eps, center=true);
}

// -------------------- Internal thread + bore --------------------
module internal_bore_and_leadins_cutter() {
    r_minor = thread_minor_diameter/2 + thread_clearance;
    r_lead  = thread_major_diameter/2 + thread_clearance;

    // Through bore at minor diameter (extended for clean boolean)
    cylinder(h=length + 2*(overlap + eps), r=r_minor, center=true);

    // Lead-in cones at both ends
    translate([0,0, length/2 - inner_leadin_len/2])
        cylinder(h=inner_leadin_len + overlap, r1=r_lead, r2=r_minor, center=true);

    translate([0,0,-length/2 + inner_leadin_len/2])
        cylinder(h=inner_leadin_len + overlap, r1=r_minor, r2=r_lead, center=true);
}

module internal_thread_cutter() {
    // Helical cutter to subtract, leaving internal threads.
    // Use a 2D profile in (radius, z-within-pitch) and twist along Z.
    r_minor = thread_minor_diameter/2 + thread_clearance;
    r_major = thread_major_diameter/2 + thread_clearance;

    thread_len = max(0, length - 2*inner_leadin_len);
    turns = thread_len / thread_pitch;
    twist_deg = -turns * 360; // right-hand internal thread

    // Keep within pitch to avoid self-intersection
    tooth_z = clamp(thread_pitch*0.60, 0.45, thread_pitch*0.90);

    // Make the cutter a little "wider" radially so it clearly forms threads
    // (still bounded by r_major).
    r_mid = (r_minor + r_major) / 2;

    // Position threaded region centered in the part
    translate([0,0,-thread_len/2])
        linear_extrude(
            height=thread_len,
            twist=twist_deg,
            slices=max(ceil(turns*70), 140),
            center=false,
            convexity=12
        )
        // 2D polygon in XY where:
        // X = radius, Y = axial phase within one pitch (mapped to +/- tooth_z/2)
        // This creates a helical "tap" ridge when twisted.
        polygon(points=[
            [r_minor, -tooth_z/2],
            [r_major,  0],
            [r_minor,  tooth_z/2],
            [r_mid,    0]          // adds thickness to ensure robust cutting
        ]);
}

// -------------------- Final Model --------------------
difference() {
    // Outer solid with OD chamfers
    difference() {
        outer_body_with_rings();
        outer_end_chamfers_cutter();
    }

    // Subtract internal bore + lead-ins + thread cutter
    union() {
        internal_bore_and_leadins_cutter();
        internal_thread_cutter();
    }
}