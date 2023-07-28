({
    recordCreated : function (component, event, helper) {
        var newId = event.getParam('newId');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": newId,
          "slideDevName": "conversation"
        });
        navEvt.fire();
    }
})
