$fn = 64;

eps = 0.05;

// ===== Spec =====
// HDMI display 5" module
pcb_size   = [121, 76, 2.85];
pcb_offset = [0, 0, 1.9];                 // pcb offset from front reference (z=0 at front glass top)

// Aperture (window) in front layer
ap_min   = [-54, -30.225];
ap_max   = [ 54,  34.575];
ap_depth = 0.5;

// Touch screen glass extents
ts_min = [-58.7, -34];
ts_max = [ 58.7,  36.25];
ts_th  = 1.0;

// Touchscreen ribbon clearance (needs clearance below glass)
rib_min = [-2.5, -39];
rib_max = [10.5, -33];

// Thread length (standoff length below PCB)
thread_len = 2;
thread_d   = 3.0;

// Simple connector bumps (kept connected to PCB)
hdmi_body     = [14, 12, 6];  // [x,y,z]
hdmi_overhang = 2;            // protrude beyond PCB edge in -Y

fpc_body      = [12, 6, 2.2]; // small ribbon/FPC connector bump
fpc_overhang  = 1.5;          // protrude beyond PCB edge in +Y

// ===== Helpers =====
module rect_prism_xy(minxy, maxxy, z0, z1) {
    translate([(minxy[0]+maxxy[0])/2, (minxy[1]+maxxy[1])/2, (z0+z1)/2])
        cube([maxxy[0]-minxy[0], maxxy[1]-minxy[1], z1-z0], center=true);
}

module rounded_rect_prism_xy(minxy, maxxy, z0, z1, r=1.5) {
    // 2D rounded rectangle extruded between z0..z1
    w = maxxy[0]-minxy[0];
    h = maxxy[1]-minxy[1];
    cx = (minxy[0]+maxxy[0])/2;
    cy = (minxy[1]+maxxy[1])/2;
    translate([cx, cy, z0])
        linear_extrude(height = (z1-z0))
            offset(r=r)
                square([w-2*r, h-2*r], center=true);
}

// ===== Main model (ONE connected solid) =====
module hdmi_display_5in() {

    // Z layout (front reference plane at z=0 is top of touch glass)
    ts_z0 = -ts_th;
    ts_z1 = 0;

    pcb_cz = -(pcb_offset[2] + pcb_size[2]/2);
    pcb_z0 = pcb_cz - pcb_size[2]/2;
    pcb_z1 = pcb_cz + pcb_size[2]/2;

    // A thin bezel/frame thickness behind glass to make aperture meaningful
    bezel_th = 0.8;
    bezel_z0 = ts_z0 - bezel_th;
    bezel_z1 = ts_z0 + 0.15; // slight overlap into glass for robust union

    // Standoffs connect from PCB bottom down by thread_len, overlap into PCB
    st_z0 = pcb_z0 - thread_len;
    st_z1 = pcb_z0 + 0.6;

    // Mounting standoff positions (near corners, inset)
    inset_x = 6;
    inset_y = 6;
    st_pos = [
        [-pcb_size[0]/2 + inset_x, -pcb_size[1]/2 + inset_y],
        [ pcb_size[0]/2 - inset_x, -pcb_size[1]/2 + inset_y],
        [-pcb_size[0]/2 + inset_x,  pcb_size[1]/2 - inset_y],
        [ pcb_size[0]/2 - inset_x,  pcb_size[1]/2 - inset_y]
    ];

    // HDMI connector placement: on -Y edge, sitting on PCB top, overlapping into PCB
    hdmi_cx = 0;
    hdmi_cy = -pcb_size[1]/2 - hdmi_overhang + hdmi_body[1]/2;
    hdmi_cz = pcb_z1 + hdmi_body[2]/2 - 0.6;

    // FPC connector placement: on +Y edge, sitting on PCB top, overlapping into PCB
    fpc_cx = 0;
    fpc_cy = pcb_size[1]/2 + fpc_overhang - fpc_body[1]/2;
    fpc_cz = pcb_z1 + fpc_body[2]/2 - 0.6;

    // Bridge/web to ensure glass/bezel/pcb are one connected solid (under bezel area)
    // Connects from PCB top up into bezel region with overlap.
    web_th = 0.9;
    web_z0 = pcb_z1 - web_th;     // overlaps into PCB
    web_z1 = bezel_z0 + web_th;   // overlaps into bezel
    web_min = [ap_min[0] + 6, ap_min[1] + 6];
    web_max = [ap_max[0] - 6, ap_max[1] - 6];

    // Bezel outer follows touch glass extents; inner is aperture
    bezel_outer_min = ts_min;
    bezel_outer_max = ts_max;

    difference() {
        union() {
            // Touch glass (front layer)
            rounded_rect_prism_xy(ts_min, ts_max, ts_z0, ts_z1, r=1.2);

            // Bezel/frame layer behind glass (gives a real aperture cut)
            rounded_rect_prism_xy(bezel_outer_min, bezel_outer_max, bezel_z0, bezel_z1, r=1.2);

            // PCB (behind glass)
            translate([pcb_offset[0], pcb_offset[1], pcb_cz])
                cube(pcb_size, center=true);

            // Mounting standoffs (solid cylinders) connected to PCB
            for (p = st_pos)
                translate([p[0], p[1], (st_z0+st_z1)/2])
                    cylinder(h = (st_z1-st_z0), d = thread_d, center=true);

            // HDMI connector bump (solid) connected to PCB
            translate([hdmi_cx, hdmi_cy, hdmi_cz])
                cube(hdmi_body, center=true);

            // FPC/ribbon connector bump (solid) connected to PCB
            translate([fpc_cx, fpc_cy, fpc_cz])
                cube(fpc_body, center=true);

            // Web/bridge to guarantee single connected solid (glass/bezel <-> PCB)
            rect_prism_xy(web_min, web_max, web_z0, web_z1);
        }

        // Aperture cut (window) through glass + bezel depth from front
        // Cut from z=-ap_depth to slightly above front to ensure clean opening.
        rect_prism_xy(ap_min, ap_max, -ap_depth, eps);

        // Touchscreen ribbon clearance cut (through glass+bezel region)
        // Provide clearance down to PCB top (but not through PCB).
        rib_z0 = bezel_z0 - eps;
        rib_z1 = pcb_z1 + 0.2; // stop near PCB top; still clears glass/bezel volume
        rect_prism_xy(rib_min, rib_max, rib_z0, rib_z1);
    }
}

hdmi_display_5in();