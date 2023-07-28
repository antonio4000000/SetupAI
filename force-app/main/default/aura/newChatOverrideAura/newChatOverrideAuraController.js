({
    recordCreated : function (component, event, helper) {
        console.log('received reload event');
        var newId = event.getParam('result');
        console.log(newId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": newId
        });
        navEvt.fire();
    }
})
