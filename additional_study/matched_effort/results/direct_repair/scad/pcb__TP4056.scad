$fn=64;

module battery_charger_module(length=26.2, width=17.5, thickness=1.0) {
    cube([length, width, thickness], center=false);
}

battery_charger_module();