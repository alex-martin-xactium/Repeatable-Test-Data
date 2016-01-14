/*
 * @description helper class to create a list of business units
 */
public with sharing class BusinessUnitCreatorHelper {
	
	/**
	 * @description function to create business units, based on a list of names associated to one scoring scheme. 
	 * @param  List of names of business units to create. 
	 * @param  The scoring scheme ID. Can be null, then no scoring scheme is associated.
	 * @return List of created business units, returned to be colated into one list and inserted in one go. Returns a blank list 
	 * if namelist is empty or null. 
	 */
	public static List<grc__Business_Unit__c> createBusinessUnits(Map<Id, List<String>> parametersMap) {
		
		if(parametersMap == null || parametersMap.keySet().size() == 0) {
			throw new BadParameterException('Incorrect parameters passed');
		}
		
		List<grc__Business_Unit__c> businessUnitList = new List<grc__Business_Unit__c>();

		for(Id scoringSchemeId : parametersMap.keySet()) {
			for(String name : parametersMap.get(scoringSchemeId)) {
				grc__Business_Unit__c businessUnit = new grc__Business_Unit__c();
				businessUnit.Name = name; 
				businessUnit.Risk__Sharing_Group_Name__c = name;
				businessUnit.Risk__Scoring_Scheme__c = scoringSchemeId;
				
				businessUnitList.add(businessUnit);				
			}
		}
		
		insert businessUnitList;
		return businessUnitList;
	}
}
