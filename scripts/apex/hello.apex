System.debug(JSON.serialize(
    Database.query('SELECT AccountNumber FROM Account WHERE Name = \'Test Account\'')
)
);