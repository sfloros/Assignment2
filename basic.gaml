/**
* Name: basic
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model basic

/*
 *  ******************** GLOBAL STARTS HERE ***********************
 */
global {
	point sceneloc <- {50, 0};
	int guest_num <- 20;
	
	init{
		
		create guest number: guest_num; 
		
		create auction_scene number: 2 {
			location <- sceneloc;
		}
		
		create auctioneer number: 1 {
			location <- sceneloc;
		}
	}
	
}
/*
 *  ******************** GLOBAL ENDS HERE ****************************
 */

/*
 *  ******************** SPECIES START HERE *************************
 */

species guest skills:[moving, fipa] {
	point target_point <- nil;
	
	reflex do_wander when: (target_point = nil) {
		do wander;
	}
	
	reflex reply_message when: (!empty(requests)) {
		message requestFromAuctioneer <- (requests at 0);
		do agree with: (message: requestFromAuctioneer, contents:[name + ' I will']);
		
		//If statement here to disagree with the auctioneer.
		
		do failure with: (message: requestFromAuctioneer, contents: [name + ' I reject, sorry not sorry']);
	}
	
	aspect base {
		draw triangle(3) color: #darkred;
	}
}


species auctioneer skills:[fipa]{
	
	rgb color <- #red;
	
	reflex send_request when: (time = 1) {
		guest g <- guest at 0;
		write(name + " sends message");
		do start_conversation (to :: [g], protocol :: 'fipa-request', performative :: 'request', contents :: ['go sleeping'] );
	}
	
	reflex read_agree_message when: !(empty(agrees)) {
		loop a over: agrees {
			write(" agrees message with content: " + string(a.contents));
		}
	}
	
	reflex read_failure_message when: !(empty(failures)) {
		loop f over: failures {
			write(" rejects message with content: " + (string(f.contents)));
		}
	}
	
	aspect base {
		draw sphere(3) color: color;
	}
}

species auction_scene {
	
	rgb color <- #green;
	
	aspect base {
		draw circle(6) color: color;
	}
	
}

/*
 *  *************************** SPECIES END HERE **************************
 */

experiment main {
	
	output {
		
		display map type: opengl {
			species guest aspect: base;
			species auctioneer aspect: base;
			species auction_scene aspect: base;
		}
	}
}
