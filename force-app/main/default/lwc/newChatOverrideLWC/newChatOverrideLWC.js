import { LightningElement, track, api } from 'lwc';
import { subscribe } from 'lightning/empApi';
import getMessages from '@salesforce/apex/Controller.getMessages';
import submitMessage from '@salesforce/apex/Controller.submitMessage';
import getChatSummary from '@salesforce/apex/Controller.getChatSummary';

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

    //Platform event handling to display new messages
    subscription = {};
    errorSubscription = {};
    @api channelName = '/event/Message_Notice__e';
    @api errorChannelName = '/event/Async_Error__e';

    //On component load, retrieve messages
    connectedCallback(){
        if(this.recordId){
            this.retrieveMessages();
            getChatSummary({chatId:this.recordId})
                .then(result => {
                    this.title = result != null ? result : this.title;
                })
                .catch(error => {
                    console.log(error.body.message);
                    this.displayError(error.body.message);
                })
        } 
        this.handleSubscribe();
    }

    //On component rendered
    renderedCallback() {
        setTimeout(() => {
            this.fadeAnimation = '';
        }, 400);
    
        this.template.querySelector('.chat-messages').scrollTop = this.template.querySelector('.chat-messages').scrollHeight;
    
        // Manually insert the processed HTML for each message
        const messageElems = this.template.querySelectorAll('.message-content');
        this.messages.forEach((message, index) => {
            if (message.msgClass.includes('inbound')) {
                messageElems[index].innerHTML = message.text;
            } else {
                messageElems[index].textContent = message.text; // This ensures other messages remain as-is
            }
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
                    console.log(error.body.message);
                    this.displayError(error.body.message);
                })
        }
    }

    //Retrieve messages from chat records
    retrieveMessages(){
        getMessages({chatId: this.recordId})
            .then((result) => {
                this.messages = result.map(message => {
                    // Convert markdown to HTML only for the inbound messages
                    if (message.msgClass.includes('inbound')) {
                        message.text = this.markdownToHTML(message.text);
                    }
                    return message;
                });
                //If last message is not user submitted, hide loading wheel
                this.isLoading = this.messages[this.messages.length-1].msgClass.includes('outbound');
            })
            .catch((error) => {
                console.log(error.body.message);
                this.displayError(error.body.message);
            });
    }

    // Handles subscribe button click
    handleSubscribe() {
        // Callback invoked whenever a new event message is received
        const messageCallback = (response) => {
            if(response.data.payload.SetupAI__Chat_Id__c == this.recordId){
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
            if(response.data.payload.SetupAI__Chat_Id__c == this.recordId){
                this.displayError(JSON.parse(JSON.stringify(response.data.payload.SetupAI__Error_Content__c)));
            }
        }
        subscribe(this.errorChannelName, -1, errorCallback).then(response => {
            console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.errorSubscription = response
        });
    }

    //Displays error message on screen
    displayError(message){
        this.messages.push({
            msgClass: 'slds-chat-message__text slds-chat-message__text_inbound',
            containerClass: 'slds-chat-listitem slds-chat-listitem_inbound',
            id: 0,
            text: message
        });
        this.isLoading = false;
    }

    //Handles key press when entering text
    handleKeyPress(event){
        if(event.keyCode === 13){
            this.submit();
        }
    }

    // Converts markdown link [label](url) to HTML anchor tags
    markdownToHTML(inputStr) {
        const regex = /\[([^\[]+)\]\(([^\)]+)\)/g;
        return inputStr.replace(regex, (match, label, url) => `<a href="${url}" target="_blank">${label}</a>`);
    }

}
