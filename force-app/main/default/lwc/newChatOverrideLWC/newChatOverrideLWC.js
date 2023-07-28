import { LightningElement, track, api } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import getMessages from '@salesforce/apex/Controller.getMessages';
import submitMessage from '@salesforce/apex/Controller.submitMessage';

export default class NewChatOverrideLWC extends LightningElement {

    //Chat Id
    @api recordId;
    //Text user is currently entering
    @track userInput = '';
    //List of UI messages 
    @track messages = [];

    //Platform event handling to display new messages
    subscription = {};
    @api channelName = '/event/Message_Notice__e';

    //On component load, retrieve messages
    connectedCallback(){
        if(this.recordId){
            this.retrieveMessages();
        } 
        this.handleSubscribe();
    }

    //Handle user input updates
    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    //Upon user submit button press, save to records
    submit() {
        if (this.userInput.trim() !== '') {
            submitMessage({content: this.userInput, chatId: this.recordId})
                .then(() => {
                    this.userInput = '';
                })
                .catch(error => {
                    console.log(error.body.message);
                })
        }
    }

    //Retrieve messages from chat records
    retrieveMessages(){
        getMessages({chatId: this.recordId})
            .then((result) => {
                console.log(result.allMessages);
                this.messages = result.allMessages;
                
                if(!this.recordId){
                    const newRecordCreated = new CustomEvent('recordcreated', {
                        detail: { newId : result.chatId },
                    });
                    // Fire the custom event
                    this.dispatchEvent(newRecordCreated);
                }
            })
            .catch((error) => {
                console.log('ERROR');
                console.log(error.body.message);
            });
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            console.log(response);
            console.log('CALLBACK');
            this.retrieveMessages();
        };
 
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
    }

}
