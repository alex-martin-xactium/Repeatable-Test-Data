/*
 * @description Business Unit relationship helper. (clearly a Relationship therapist)
 * Associates business units to each other before updating them in the database. 
 */
public with sharing class BusinessUnitRelationshipHelper {
	
	private static final String key = 'relationships';
	
	/**
	 * @description function to create the links between business units. Uses names in a comma seperate string
	 * to indicate relation. 
	 * @param  Parameter map. Must have a single parameter of key relationships that contains the pair values
	 * @return returns a list of business units to update, or an empty list if there's nothing to update. 
	 */
	public static List<grc__Business_Unit__c> updateRelationships(Map<String, String> relationships) {
		//We are only looking for 1 parameter, rest can be ignored. 
		if(relationships != null && relationships.containsKey('relationships')) {
			
			Set<String> businessUnitNames = new Set<String>();
			Map<String, String> childToParentMap = new Map<String, String>();
			Map<String, grc__Business_Unit__c> businessUnitMap = new Map<String, grc__Business_Unit__c>();
			
			List<String> pairs = relationships.get(key).split(',');
			
			for(String pair : pairs) {
				List<String> pairValue = pair.split(':');
				if(pairValue.size() == 2) {
					
					//Build a list of business unit names to query for. 
					businessUnitNames.add(pairValue.get(0));
					businessUnitNames.add(pairValue.get(1));
					
					//Store the relationship. 
					//0 is child, 1 is parent
					childToParentMap.put(pairValue.get(0), pairValue.get(1));
				}
			}
			
			List<grc__Business_Unit__c> businessUnits = getNamedBusinessUnits(businessUnitNames);
			List<grc__Business_Unit__c> businessUnitsToUpdate = new List<grc__Business_Unit__c>();
			
			//We could skip this step if the parameters being passed in are Id's and not names
			for(grc__Business_Unit__c bu : businessUnits) {
				businessUnitMap.put(bu.Name, bu);
			}
			
			for(String child : childToParentMap.keySet()) {
				String parent = childToParentMap.get(child);
				
				grc__Business_Unit__c buChild = businessUnitMap.get(child);
				grc__Business_Unit__c buParent = businessUnitMap.get(parent);
				
				if(buChild != null && buParent != null) { 
					buChild.grc__Parent_Business_Unit__c = buParent.Id;
					businessUnitsToUpdate.add(buChild);
				}
			}
			
			return businessUnitsToUpdate;
		}
		
		//return empty list to show nothing has happened. 
		return new List<grc__Business_Unit__c>();
	}
	
	/**
	 * @description simple method to query the business units based on their names
	 * @param  Set of names of the business units to query for. 
	 * @return returns the list of business units with matching names, or an empty list of none exist.
	 */
	private static List<grc__Business_Unit__c> getNamedBusinessUnits(Set<String> businessUnitNames) {
		return [Select Id, Name from grc__Business_Unit__c where Name in :businessUnitNames];
	}
}
