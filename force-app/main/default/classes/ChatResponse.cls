/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Responses received from OpenAI Chat API
*/

public with sharing class ChatResponse {

    public String id;
    public String object_x;
    public Integer created;
    public String model;
    public ChatResponseUsage usage;
    public ChatResponseChoice[] choices;

    public ChatResponse(ChatRequest.ChatMessage message){
        ChatResponseChoice choice = new ChatResponseChoice();
        choice.message = message;
        this.choices = new ChatResponseChoice[]{choice};
    }

    //Contains information on tokens used in this request
    public class ChatResponseUsage{
        public Integer prompt_tokens;
        public Integer completion_tokens;
        public Integer total_tokens;
    }

    //Contains response from assistant
    public class ChatResponseChoice{
        public ChatRequest.ChatMessage message;
        public String finish_reason;
        public Integer index;
    }

}