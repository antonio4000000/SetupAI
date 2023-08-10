System.debug(
    JSON.serialize(
        ToolingAPI.query('SELECT Name, Body FROM ApexClass WHERE Name = \'MessageTriggerHandler\'')
    )
);