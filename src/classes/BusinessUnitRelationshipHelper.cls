/*
 * @description Business Unit relationship helper. (clearly a Relationship therapist)
 * Associates business units to each other before updating them in the database. 
 */
public with sharing class BusinessUnitRelationshipHelper {

	/**
	 * @description function to create the links between business units. Uses names in a comma seperate string
	 * to indicate relation. 
	 * @param  Parameter map. Must have a single parameter of key relationships that contains the pair values
	 * @return returns a list of business units to update, or an empty list if there's nothing to update. 
	 */
	public static List<grc__Business_Unit__c> updateRelationships(Map<String, String> parameters) {
		
		if(parameters == null || parameters.keySet().size() == 0) {
			throw new BadParameterException('No parameters passed');
		}
		
		Set<String> businessUnitNames = new Set<String>();
		Map<String, String> childToParentMap = new Map<String, String>();
		Map<String, grc__Business_Unit__c> businessUnitMap = new Map<String, grc__Business_Unit__c>();

		for(String childBuName : parameters.keySet()) {
			String parentBuName = parameters.get(childBuName);
			
			if(parentBuName == null || childBuName == null) {
				throw new BadParameterException('Incorrect parameters passed, child or parent is null');
			}
			//Build a list of business unit names to query for. 
			businessUnitNames.add(childBuName);
			businessUnitNames.add(parentBuName);
			
			//Store the relationship. 
			//0 is child, 1 is parent
			childToParentMap.put(childBuName, parentBuName);

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
			} else {
				throw new BadParameterException('Child or parent business unit don\'t exist');
			}
		}
		
		return businessUnitsToUpdate;
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
