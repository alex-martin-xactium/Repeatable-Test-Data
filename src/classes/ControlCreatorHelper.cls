/**
 * @description helper class to create controls and associate them with risks as specified by the risk name. 
 */
public with sharing class ControlCreatorHelper {
	
	private static final String key = 'relationships';
	
	/**
	 * @description method to create the controls and the junctions between controls and risks. 
	 * @param  Parameter map with a relationship key. value pairs are control name to risk name. Risks must already exist
	 * @param business unit id. Controls must have a business unit. 
	 */
	public static void createControls(Map<String, String> parameters, Id businessUnitId) {
		
		if(businessUnitId != null && parameters != null && parameters.containsKey(key)) {
			
			Map<String, grc__Control__c> controlsToInsert = new Map<String, grc__Control__c>();
			List<Risk__Risk_Control_Lookup__c> controlJunctions = new List<Risk__Risk_Control_Lookup__c>();
			Map<String, String> controlsToRisks = new Map<String, String>();
			Set<String> riskNames = new Set<String>();
			Map<String, grc__Risk__c> riskMap = new Map<String, grc__Risk__c>();
			
			String values = parameters.get(key);
			for(String pair : values.split(',')) {
				List<String> v = pair.split(':');
				if(v.size() == 2) {
					grc__Control__c control = new grc__Control__c();
					control.Name = v.get(0);
					control.grc__Business_Unit__c = businessUnitId;
					controlsToInsert.put(control.Name, control);
					controlsToRisks.put(control.Name, v.get(1));
					riskNames.add(v.get(1));
				}
			}
			
			insert controlsToInsert.values();
			
			//If we use Id's, we'd avoid this step. 
			for(grc__Risk__c risk : [Select Id, Name from grc__Risk__c where Name in :riskNames]) {
				riskMap.put(risk.Name, risk);
			}
			
			for(grc__Control__c control : controlsToInsert.values()) {
				Risk__Risk_Control_Lookup__c lookup = new Risk__Risk_Control_Lookup__c();
				if(controlsToRisks.containsKey(control.Name) && riskMap.containsKey(controlsToRisks.get(control.Name))) {
					lookup.Risk__Risk__c = riskMap.get(controlsToRisks.get(control.Name)).Id;
					lookup.Risk__Control__c = control.Id;
					
					controlJunctions.add(lookup);
				}
				
			}
			
			insert controlJunctions;
		}
	}

}
