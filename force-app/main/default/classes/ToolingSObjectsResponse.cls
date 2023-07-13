/* 
 * Author:      Anthony Wheeler(wheeler.anthony96@gmail.com)
 * Created:     2023-07-13
 * Description: Response from Tooling AI request for all SObject definitions
*/

public class ToolingSObjectsResponse {
	public String encoding;	//UTF-8
	public Integer maxBatchSize;	//200
	public cls_sobjects[] sobjects;
	public class cls_sobjects {
		public boolean activateable;
		public cls_associateEntityType associateEntityType;
		public cls_associateParentEntity associateParentEntity;
		public boolean createable;
		public boolean custom;
		public boolean customSetting;
		public boolean deepCloneable;
		public boolean deletable;
		public boolean deprecatedAndHidden;
		public boolean feedEnabled;
		public boolean hasSubtypes;
		public boolean isInterface;
		public boolean isSubtype;
		public String keyPrefix;	//0Pp
		public String label;	//AI Application
		public String labelPlural;	//AI Applications
		public boolean layoutable;
		public boolean mergeable;
		public boolean mruEnabled;
		public String name;	//AIApplication
		public boolean queryable;
		public boolean replicateable;
		public boolean retrieveable;
		public boolean searchable;
		public boolean triggerable;
		public boolean undeletable;
		public boolean updateable;
		public cls_urls urls;
	}
	public class cls_associateEntityType {
	}
	public class cls_associateParentEntity {
	}
	public class cls_urls {
		public String rowTemplate;	///services/data/v56.0/tooling/sobjects/AIApplication/{ID}
		public String describe;	///services/data/v56.0/tooling/sobjects/AIApplication/describe
		public String sobject_x;	///services/data/v56.0/tooling/sobjects/AIApplication
	}
	public static ToolingSObjectsResponse parse(String json){
        json = json.replace('"sobject"', '"sobject_x"');
		return (ToolingSObjectsResponse) System.JSON.deserialize(json, ToolingSObjectsResponse.class);
	}
	public String[] getSObjectNames(){
		String[] names = new String[]{};
		for(cls_sobjects sobj : this.sobjects){
			names.add(sobj.name);
		}
		return names;
	}

}