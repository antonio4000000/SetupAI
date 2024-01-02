/*
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-04-17
 * Description: Ensures queries written by AI don't break or return unexpected results
 */

public with sharing class SOQLModifier {

    //Fields to add to query for profile permission sets
    public static String[] profileFields = new String[]{'IsOwnedByProfile','ProfileId'};
    
    //Call this method to modify queries and ensure standardization and clean information
    public static String modify(String query){
        if(query.contains('FROM PermissionSet') || query.contains('FROM PermissionSetAssignment')) query = addProfileFields(query);
        if(!query.contains('LIMIT')) query = limitQuery(query);
        return query;
    }

    //Limit results returned so token limit isn't hit
    public static String limitQuery(String query){
        return query + ' LIMIT 50';
    }

    //Add profile fields to query to execute so AI is aware of profile permission sets
    public static String addProfileFields(String query){
        if(query.contains('FROM PermissionSet ') && !query.contains('IsOwnedByProfile')){
            String newFields = '';
            for(String field : profileFields){
                if(!query.contains(field)){
                    newFields = newFields + ', ' + field;
                }
            }
            String[] queryParts = query.split(' FROM PermissionSet ');
            query = queryParts[0] + newFields + ' FROM PermissionSet ' + (queryParts[1] != null ? queryParts[1] : '');
        }
        if(query.contains('FROM PermissionSetAssignment') && !query.contains('IsOwnedByProfile')){
            String newFields = '';
            for(String field : profileFields){
                if(!query.contains(field)){
                    newFields = newFields + ', PermissionSet.' + field;
                }
            }
            String[] queryParts = query.split(' FROM PermissionSetAssignment');
            query = queryParts[0] + newFields + ' FROM PermissionSetAssignment' + (queryParts[1] != null ? queryParts[1] : '');
        }
        return query;
    }

}