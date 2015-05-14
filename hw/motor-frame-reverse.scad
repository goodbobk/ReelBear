motor_d = 35.6;
motor_h = 26;
wall_t = 2;
wall_h = 25;
base_h = 5;
base_d = 3 * motor_d;

wires_d = 8;

sucker_neck_d = 9;
sucker_slot_d = 8;
sucker_neck_h = 3.2;
sucker_head_d = 15;

sucker_pos = base_d/2 - 0.9*sucker_neck_d;

sucker_cup_h = 9;
sucker_cup_d = 42;

axle_l = 22;
axle_d = 5;
axle_overhang = 2;
motor_base = axle_l - axle_overhang;
mount_pos = 26/2;
mount_screw_d = 3.1;
mount_screw_head_d = 2 * mount_screw_d;
mount_screw_head_h = 0.6 * mount_screw_d;
mount_h = 6;

sprocket_h = 10;
sprocket_d = 23;
belt_a = 95;

segments = 18;
e = 0.002;

module oval_hole(z_off, h,d,s) {
    translate([0,0,z_off + h/2]) {
        hull() {
            cylinder(d=d, center=true, h=h);
            translate([ d, 0, 0]) {
                cylinder(d=d, center=true, h=2*h);
            }
        }               
    }
}
        
module sucker_hole() {
    // translate to sucker vertical axis
    translate([sucker_pos,0,0]) {
        union() {
            // space for the sucker head
            oval_hole(sucker_neck_h, base_h - sucker_neck_h, sucker_head_d, sucker_head_d);
            // sucker neck hole & slot
            // hole
            cylinder(d=sucker_neck_d, h=sucker_neck_h, center=false);
            // slot
            translate([0,-sucker_slot_d/2,0]) {
                cube(size=[100,sucker_slot_d,sucker_neck_h]);
            }
        }
    }
}

module sucker_cup() {
        cylinder(d1 = sucker_cup_d, d2=sucker_neck_d, h=sucker_cup_h);
}

module suckers() {
    for(a = [0,110,250]) {
        rotate(a=a) translate([sucker_pos,0,-sucker_cup_h]) color("lightcyan") sucker_cup();
    }
}

module base() {
    difference() {
        cylinder(d = base_d, h = base_h, $fn = 6);

        rotate (a=0) sucker_hole();
        rotate (a=110) sucker_hole();
        rotate (a=250) sucker_hole();            
    }
}

module wire_hole() {
    translate([motor_d/2 + wall_t/2,0,wall_h/2]) {
        cube(size = [wall_t, wires_d,wall_h], center = true);
    }
}

module screw_hole(cx, cy) {
    union() {
        mount_d = motor_d - 2 * mount_pos;
        cylinder(d = mount_screw_d, 
                 h = mount_h + e, 
                 $fn = segments);
        cylinder(d = mount_screw_head_d,
                 h = mount_screw_head_h,
                 $fn = segments);
    }
}

module motor_hole() {
    union() {
        translate([-motor_d/2,-motor_d/2,motor_base])
            cube(size=[motor_d, motor_d, wall_h]);
        
        screw_base = motor_base - mount_h;
        translate( [0,0,screw_base]) {
            translate([-mount_pos,-mount_pos, 0]) screw_hole();
            translate([-mount_pos,mount_pos, 0]) screw_hole();
            translate([mount_pos,-mount_pos, 0]) screw_hole();
            translate([mount_pos,mount_pos, 0]) screw_hole();
        }

        cylinder(h = motor_base, d = sprocket_d*1.2);
        translate([-motor_d/2,-motor_d/2,0])
            cube(size=[motor_d, motor_d, screw_base + e]);

        
    }        
}

module walls() {
    wall_size = motor_d + 2*wall_t;

    translate([0,0,wall_h/2]) {
            cube(center = true,  size=[wall_size, wall_size, wall_h]);
        }
}


module motor() {
    color("blue") translate([-motor_d/2, -motor_d/2, motor_base]) {
            cube(size=[motor_d, motor_d, motor_h]); 
    }
    color("lightblue") translate([0,0,-axle_overhang]) {
        cylinder(d=axle_d, h=axle_l);
    }

}

module belt_hole() {
    color("red") translate([0,0,-axle_overhang]) union() {
        cylinder(d=sprocket_d, h = sprocket_h, $fn = segments);
        linear_extrude(height = sprocket_h) {
            polygon(points = [[0, 1.1*sprocket_d/2], 
                              [-100,100*tan(belt_a/2)], 
                              [-100,-100*tan(belt_a/2)],
                              [0,-1.1*sprocket_d/2]]);
        }
    }

}
module hw() {
    suckers();
    motor();
}


union() {
    union() {
        difference() {
            union() {
                walls();
                base();
            }
            motor_hole();
            wire_hole();
            belt_hole();                
        }
    }
    
//    hw();
}
    

