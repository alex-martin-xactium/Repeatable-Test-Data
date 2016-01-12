/**
 * @description helper class to aid in creating risks. Associates them with business units.
 */
public with sharing class RiskCreatorHelper {
	
	private static final String key = 'relationships';
	
	/**
	 * @description method to create the risks, associate them with a business unit and insert
	 * @param  parameter map, with a relationship parameter that points to a comma seperate string. Business unit is required
	 * if business unit name passed is not valid, that one risk won't be entered.
	 */
	public static void createRisks(Map<String, String> parameters) {
		if(parameters != null && parameters.containsKey(key)) {
			
			Map<String, grc__Risk__c> businessUnitNamesToRisksMap = new Map<String, grc__Risk__c>();
			
			for(String value : parameters.get(key).split(',')) {
				List<String> pair = value.split(':');
				
				if(pair.size() == 2) {
					grc__Risk__c risk = new grc__Risk__c();
					risk.Name = pair.get(0);
					risk.Risk__Type__c = 'Threat';
					risk.grc__Status__c = 'Active';
					businessUnitNamesToRisksMap.put(pair.get(1), risk);
				}
			}
			
			List<grc__Risk__c> risksToInsert = new List<grc__Risk__c>();
			
			for(grc__Business_Unit__c bu : [Select Id, Name from grc__Business_Unit__c where Name in :businessUnitNamesToRisksMap.keySet()]) {
				if(businessUnitNamesToRisksMap.containsKey(bu.Name)) {
					businessUnitNamesToRisksMap.get(bu.Name).grc__Business_Unit__c = bu.Id;
					risksToInsert.add(businessUnitNamesToRisksMap.get(bu.Name));
				}
			}
			
			insert risksToInsert;
		}
	}
}
