/**
 * @description helper class to create controls and associate them with risks as specified by the risk name. 
 */
public with sharing class ControlCreatorHelper {

	/**
	 * @description method to create the controls and the junctions between controls and risks. 
	 * @param  Parameter map with a relationship key. value pairs are control name to risk name. Risks must already exist
	 * @param business unit id. Controls must have a business unit. 
	 */
	public static void createControls(Map<String, String> parameters) {
		//Business unit name => control:risk name,control:risk name
		if(parameters == null || parameters.keySet().size()==0) {
			throw new BadParameterException('Incorrect parameters passed');
		}
			
		Map<String, grc__Control__c> controlsToInsert = new Map<String, grc__Control__c>();
		List<Risk__Risk_Control_Lookup__c> controlJunctions = new List<Risk__Risk_Control_Lookup__c>();
		Map<String, String> controlsToRisks = new Map<String, String>();
		Set<String> riskNames = new Set<String>();
		Map<String, grc__Risk__c> riskMap = new Map<String, grc__Risk__c>();
		Map<String, grc__Business_Unit__c> businessUnitMap = new Map<String, grc__Business_Unit__c>();
		
		for(grc__Business_Unit__c businessUnit : [Select Id, Name from grc__Business_Unit__c where Name in :parameters.keySet()]) {
			businessUnitMap.put(businessUnit.Name, businessUnit);
		}
		
		//business units must exist, otherwise exception is thrown as controls can't exist
		//without business units.
		if(businessUnitMap.keySet().size() == 0) {
			throw new BadParameterException('No business units found');
		}
		
		for(String businessUnitName : parameters.keySet()) {
			for(String commaString : parameters.get(businessUnitName).split(',')) {
				List<String> pair = commaString.split(':');
				if(pair.size() == 2) {
					grc__Control__c control = new grc__Control__c();
					control.Name = pair.get(0);
					
					if(!businessUnitMap.containsKey(businessUnitName)) {
						throw new BadParameterException('Business unit does not exist: ' + businessUnitName);
					}
					
					control.grc__Business_Unit__c = businessUnitMap.get(businessUnitName).Id;
					controlsToInsert.put(control.Name, control);
					controlsToRisks.put(control.Name, pair.get(1));
					riskNames.add(pair.get(1));
					
				} else {
					throw new BadParameterException('Incorrect parameter format');
				}
			}			
		}
		Savepoint sp = Database.setSavePoint();
		insert controlsToInsert.values();
		
		//If we use Id's, we'd avoid this step. 
		for(grc__Risk__c risk : [Select Id, Name from grc__Risk__c where Name in :riskNames]) {
			riskMap.put(risk.Name, risk);
		}
		
		if(riskMap.keySet().size() == 0) {
			Database.rollBack(sp);
			throw new BadParameterException('No risks found');
		}
		
		for(grc__Control__c control : controlsToInsert.values()) {
			Risk__Risk_Control_Lookup__c lookup = new Risk__Risk_Control_Lookup__c();
			if(controlsToRisks.containsKey(control.Name) && riskMap.containsKey(controlsToRisks.get(control.Name))) {
				lookup.Risk__Risk__c = riskMap.get(controlsToRisks.get(control.Name)).Id;
				lookup.Risk__Control__c = control.Id;
				
				controlJunctions.add(lookup);
			} else {
				Database.rollBack(sp);
				throw new BadParameterException('Junction object cannot be created, risks or controls don\'t exist');
			}
			
		}
		
		try {
			insert controlJunctions;
		} catch(Exception e) {
			Database.rollBack(sp);
			throw e;
		}
		
	}

}
