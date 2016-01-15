/**
 * @description helper class to aid in creating risks. Associates them with business units.
 */
public with sharing class RiskCreatorHelper {
	
	/**
	 * @description method to create the risks, associate them with a business unit and insert
	 * @param  parameter map, with a relationship parameter that points to a comma seperate string. Business unit is required
	 * if business unit name passed is not valid, that one risk won't be entered.
	 */
	public static void createRisks(Map<String, String> parameters) {
		if(parameters == null || parameters.keySet().size() == 0) {
			throw new BadParameterException('No parameters passed');
		}
			
		Map<String, List<grc__Risk__c>> businessUnitNamesToRisksMap = new Map<String, List<grc__Risk__c>>();
		integer riskCount = 0;
		
		for(String riskName : parameters.keySet()) {
			String businessUnitName = parameters.get(riskName);
			if(riskName == null || businessUnitName == null) {
				throw new BadParameterException('Incorrect parameters passed. Either Risk Name is Business Unit name is null');
			}
			
			grc__Risk__c risk = new grc__Risk__c();
			risk.Name = riskName;
			risk.Risk__Type__c = 'Threat';
			risk.grc__Status__c = 'Active';
			if(businessUnitNamesToRisksMap.containsKey(businessUnitName)) {
				businessUnitNamesToRisksMap.get(businessUnitName).add(risk);
			} else {
				businessUnitNamesToRisksMap.put(businessUnitName, new List<grc__Risk__c> { risk });
			}
			
			//keep track of how many risks we're creating here
			riskCount++;

		}
		
		List<grc__Risk__c> risksToInsert = new List<grc__Risk__c>();
		
		for(grc__Business_Unit__c bu : [Select Id, Name from grc__Business_Unit__c where Name in :businessUnitNamesToRisksMap.keySet()]) {
			if(businessUnitNamesToRisksMap.containsKey(bu.Name)) {
				for(grc__Risk__c risk : businessUnitNamesToRisksMap.get(bu.Name)) {
					risk.grc__Business_Unit__c = bu.Id;
					risksToInsert.add(risk);
				}
			}
		}
		
		if(risksToInsert.size() != riskCount) {
			throw new BadParameterException('Incorrect parameters passed. Created risks does not match risks to insert');
		}
		
		insert risksToInsert;
	}
}
