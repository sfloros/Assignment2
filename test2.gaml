/**
* Name: test2
* Author: George
* Description: 
* Tags: Tag1, Tag2, TagN
*/

model test2

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
	
	list<participant> agreedBuyers;
	
	reflex auction_starts when:(time = 10) {
		write "Auction is starting now";
	}
	
	//The auction starts with the initiator informing about the product
	reflex send_inform when: (time = 10) {
		do start_conversation (to :: list(participant), protocol :: 'fipa-inform', performative :: 'inform', contents :: ['T-Shirt']);
	}
	

	
	reflex add_to_list when: (!empty(cfps)) {
		message accepted_cfps <- (cfps at 0);
		string decision <- string(accepted_cfps.contents[0]);
		if (string(decision) = "Interested") {
			write (string(accepted_cfps.sender) + " is interested.");
			agreedBuyers <- agreedBuyers + accepted_cfps.sender;
		}
	}
	
	reflex send_price when:(!empty(agreedBuyers)) {
		do start_conversation(to :: list(agreedBuyers), protocol :: 'fipa-propose', performative :: 'propose', contents :: [750]);
	}
	
	reflex read_reject when:(!empty(reject_proposals)) {
		loop r over:reject_proposals {
			write r.contents;
		}
	}
	
	reflex read_accept when:(!empty(accept_proposals)) {
		loop a over:accept_proposals {
			write a.contents;
		}
	}
	
	aspect base {
		draw square(5) at:{50,50} color: #red;
	}
}



species participant skills:[fipa] {
	
	int balance <- rnd(500, 1000);
	
	bool interested <- flip(0.8);
	
	reflex read_informs when:(!empty(informs)) {
		loop i over: informs {
			write "Selling: " + string(i.contents[0]);
		}
		if interested {
			do start_conversation (to :: list(initiator), protocol :: 'fipa-contract-net', performative :: 'cfp', contents :: ["Interested"]);
		}
	}
	

	
	reflex do_i_buy when: (!empty(proposes) and time = 20) {
		message message_price <- (proposes at 0);
		int initial_price <- int(message_price.contents[0]);
		if(balance < initial_price) {
			do reject_proposal (message: message_price, contents: ["Too high, lower it"]);
		}
		else if(balance >= initial_price) {
			do accept_proposal (message: message_price, contents: ["I accept your offer"]);
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
