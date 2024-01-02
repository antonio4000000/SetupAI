import { LightningElement, track, api } from 'lwc';
import { subscribe } from 'lightning/empApi';
import getMessages from '@salesforce/apex/Controller.getMessages';
import submitMessage from '@salesforce/apex/Controller.submitMessage';
import getChatSummary from '@salesforce/apex/Controller.getChatSummary';
import maxExceeded from '@salesforce/apex/Tokenizer.maxExceeded';
import maxExceededLabel from '@salesforce/label/c.Max_Tokens_Exceeded';

export default class NewChatOverrideLWC extends LightningElement {

    //Chat Id
    @api recordId;
    //Text user is currently entering
    @track userInput = '';
    //List of UI messages 
    @track messages = [];
    //Displays spinner when tru
    @track isLoading = false;
    //Fade in animation style
    @track fadeAnimation = 'fade-in'
    //Chat summary
    @track title = 'New Chat';
    //Determines if max tokens exceeded for this month
    @track isMaxExceeded = false;
    //Custom labels
    @track label = {
        maxExceededLabel
    }

    //Platform event handling to display new messages
    subscription = {};
    errorSubscription = {};
    @api channelName = '/event/SetupAI__Message_Notice__e';
    @api errorChannelName = '/event/SetupAI__Async_Error__e';

    //On component load, retrieve messages
    connectedCallback(){
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            this.fadeAnimation = '';
        }, 400);
        if(this.recordId){
            this.retrieveMessages();
            getChatSummary({chatId:this.recordId})
                .then(result => {
                    this.title = result != null ? result : this.title;
                })
                .catch(error => {
                    this.displayError(error);
                })
        } 
        this.handleSubscribe();
        this.checkTokenUsage();
    }
    
    checkTokenUsage() {
        maxExceeded()
            .then((result) => {
                this.isMaxExceeded = result;
            })
            .catch((error) => {
                this.displayError(error.body.message);
            });
    }

    //Handle user input updates
    handleInputChange(event) {
        this.userInput = event.target.value;
    }

    //Upon user submit button press, save to records
    submit() {
        if (this.userInput.trim() !== '') {
            this.isLoading = true;
            submitMessage({content: this.userInput, chatId: this.recordId})
                .then(result => {
                    //Returns new chat Id when new chat created so component can redirect
                    if(result){
                        const newRecordCreated = new CustomEvent('recordcreated', {
                            detail: { result },
                        });
                        // Fire the custom event
                        this.dispatchEvent(newRecordCreated);
                    }
                    this.userInput = '';
                    this.retrieveMessages();
                })
                .catch(error => {
                    this.displayError(error);
                })
        }
    }

    //Retrieve messages from chat records
    retrieveMessages(){
        getMessages({chatId: this.recordId})
            .then((result) => {
                this.messages = result;
                //If last message is not user submitted, hide loading wheel
                this.isLoading = this.messages[this.messages.length-1]?.msgClass?.includes('outbound');
                this.updateScrollPosition();
            })
            .catch((error) => {
                this.displayError(error);
            });
    }

    // Logic to adjust scroll position
    updateScrollPosition() {
        this.template.querySelector('.chat-messages').scrollTop = this.template.querySelector('.chat-messages').scrollHeight;
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            if(response.data.payload.SetupAI__Chat_Id__c === this.recordId){
                this.isLoading = true;
                this.retrieveMessages();
            }
        };
        // Invoke subscribe method of empApi. Pass reference to messageCallback
        subscribe(this.channelName, -1, messageCallback).then(response => {
            // Response contains the subscription information on subscribe call
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });

        //Handle error subscription
        const errorCallback = (response) => {
            if(response.data.payload.SetupAI__Chat_Id__c === this.recordId){
                this.displayError(JSON.parse(JSON.stringify(response.data.payload.SetupAI__Error_Content__c)));
            }
        }
        subscribe(this.errorChannelName, -1, errorCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.errorSubscription = response
        });
    }

    //Displays error message on screen
    displayError(errorMessage){
        this.messages.push({
            msgClass: 'slds-chat-message__text slds-chat-message__text_inbound',
            containerClass: 'slds-chat-listitem slds-chat-listitem_inbound',
            id: 0,
            text: errorMessage?.body?.message || errorMessage
        });
        this.isLoading = false;
    }

    //Handles key press when entering text
    handleKeyPress(event){
        if(event.keyCode === 13){
            this.submit();
        }
    }

}
