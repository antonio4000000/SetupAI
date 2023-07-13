/*
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-04-17
 * Description: Ensures queries written by AI don't break or return unexpected results
 */

public with sharing class SOQLModifier {
    
    //Call this method to modify queries and ensure standardization and clean information
    public static String modify(String query){
        if(!query.contains('LIMIT')) query = limitQuery(query);
        if(query.contains('FROM PermissionSet') || query.contains('FROM PermissionSetAssignment')) query = removeProfilePermSets(query);
        return query;
    }

    //Limit results returned so token limit isn't hit
    public static String limitQuery(String query){
        return query + ' LIMIT 50';
    }

    //Appends IsOwnedByProfile=false to PermissionSet queries
    public static String removeProfilePermSets(String query){
        if(query.contains('FROM PermissionSet') && !query.contains('IsOwnedByProfile')){
            query = query + (query.contains('WHERE') ? ' AND ' : ' WHERE ') + 'IsOwnedByProfile = false';
        }
        if(query.contains('FROM PermissionSetAssignment') && !query.contains('IsOwnedByProfile')){
            query = query + (query.contains('WHERE') ? ' AND ' : ' WHERE ') + 'PermissionSet.IsOwnedByProfile = false';
        }
        return query;
    }

}