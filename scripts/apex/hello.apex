ChatRequest req = new ChatRequest();
req.model = 'gpt-3.5-turbo-0613';
req.temperature = 0;
req.messages = new ChatRequest.ChatMessage[]{
    new ChatRequest.ChatMessage(
        'user',
        'Wahoo!'
    )
};
System.debug(OpenAI.Chat(req));