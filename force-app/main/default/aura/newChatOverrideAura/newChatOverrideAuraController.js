({
    recordCreated : function (component, event, helper) {
        //Get Record Id
        var newId = event.getParam('result');
        //Get workspace api methods
        var workspaceAPI = component.find("workspace");
        //Get current tab(New record page)
        workspaceAPI.getTabInfo().then(function(response) { 
            //Get Id of tab to close
            var closeTabId = response.tabId;
            //Open new record in new tab
            workspaceAPI.openTab({
                recordId: newId,
                focus: true
            }).then(function(openedTab){
                //Close "New Record" tab page
                workspaceAPI.closeTab({tabId: closeTabId});
            });
        })
        .catch(function(error) {
            console.log('action error: ', error.message);
        });
    }
})
