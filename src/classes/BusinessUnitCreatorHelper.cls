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
	public static List<grc__Business_Unit__c> createBusinessUnits(Map<String, List<String>> parameters) {
		
		if(parameters == null || parameters.keySet().size() == 0) {
			throw new BadParameterException('Incorrect parameters passed');
		}
		
		List<grc__Business_Unit__c> businessUnitList = new List<grc__Business_Unit__c>();
		Map<String, Risk__Scoring_Scheme__c> scoringSchemeMap = new Map<String, Risk__Scoring_Scheme__c>();
		
		for(Risk__Scoring_Scheme__c scoringScheme : [Select Id, Name from Risk__Scoring_Scheme__c where Risk__Is_Heatmap_Configured__c = true]) {
			scoringSchemeMap.put(scoringScheme.Name, scoringScheme);
		}

		for(String scoringSchemeName : parameters.keySet()) {
			for(String name : parameters.get(scoringSchemeName)) {
				grc__Business_Unit__c businessUnit = new grc__Business_Unit__c();
				businessUnit.Name = name; 
				businessUnit.Risk__Sharing_Group_Name__c = name;
				
				if(scoringSchemeName != null && !scoringSchemeMap.containsKey(scoringSchemeName)) {
					throw new BadParameterException('Scoring scheme not found');
				}
				
				//If the scoring scheme name is null, we can still create the business units. Just no scoring scheme is associated with it. 
				if(scoringSchemeName != null) {
					businessUnit.Risk__Scoring_Scheme__c = scoringSchemeMap.get(scoringSchemeName).Id;
				}
				
				
				businessUnitList.add(businessUnit);				
			}
		}
		
		insert businessUnitList;
		return businessUnitList;
	}
}
