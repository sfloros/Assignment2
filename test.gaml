/**
* Name: test
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model test

/* Insert your model definition here */

global {

	
	int x <- 0;
	
	init {
		create participant number:3 {
			location <- {40 + x, 40};
			x <- x + 10;
		}
		
		create initiator number:1;
	}
}

species initiator skills: [fipa] {
	
	int num1 <- 800;
	int num2 <- 1000;
	int preferredPrice <- rnd(num1, num2);	
	int preferredPrice2 <- rnd(400, 500);
	int minPrice <- 250; 
	
	reflex send_inform when: (time = 10) {
		participant p;
		do start_conversation ( to:: list(participant), protocol :: 'fipa-propose', performative :: 'inform', contents :: ['Auction starting']);
	}
	
	reflex send_cfp when: (time = 15) {
		do start_conversation (to :: list(participant), protocol :: 'fipa-propose', performative :: 'cfp', contents :: ['T-Shirt', preferredPrice]);
	}

	
	reflex accept_proposes when: (!empty(proposes)) {
		message proposeFromInit <- (proposes at 0);
		string proposal <- string(proposeFromInit.contents[1]);
		if( proposal = "Reconsider" ) {
			do accept_proposal with: (message :: proposeFromInit, contents :: ['I accept', preferredPrice2]);
		} 
	}
	
	reflex reject_proposes when: (!empty(proposes)) {
		message proposeFromInit <- (proposes at 0);
		string proposal <- string(proposeFromInit.contents[1]);
		if( proposal != "Reconsider" and (preferredPrice2 < minPrice)) {
			do reject_proposal with: (message :: proposeFromInit, contents :: ['I reject']);
		}
	}
	
	
	aspect base {
		draw square(5) at:{50,50} color: #red;
	}
}

species participant skills: [fipa] {
		
	int minBid <- 100;
	int maxBid <- 500;
	int proposePrice <- rnd(minBid, maxBid);

	bool interested <- true;
	string participate <- "";
	
	
	reflex read_inform when: (!empty(informs)) {
		loop i over: informs {
			write string(i.contents);
		}
	}
	
	reflex read_cfp1 when: (!empty(cfps)) {
		loop c over: cfps {
			write "Product: " + string(c.contents[0]) + ", Price: " + int(c.contents[1]);
		}
	}
	
	reflex participate when:(!empty(cfps)) {
		participate <- "Reconsider";
	}
	
	
	reflex send_propose when: (time = 30) {
		do start_conversation ( to :: list(initiator), protocol :: 'fipa-propose', performative :: 'propose', contents :: ["",participate]);
	}
	
	reflex read_accept when: (!empty(accept_proposals)) {
		loop a over: accept_proposals {
			write string(a.contents);
		}
	} 
	
	reflex read_reject when: (!empty(reject_proposals)) {
		loop r over: reject_proposals {
			write string(r.contents);
		}
	}
	
	aspect base {
		draw triangle(5) color: #green;
	}
}

experiment main {
	output {
		display my_display type: opengl {
			species initiator aspect:base;
			species participant aspect:base;
		}
	}
}
