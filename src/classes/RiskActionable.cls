/**
 * @description implementation of the iActionable interface for creating risks.
 */
public with sharing class RiskActionable implements iActionable {
	
	private Map<String, String> parameterMap = new Map<String, String>();
	
	/**
	 * @description method to add parameters to be used in the creator. 
	 *              This one is for risks, and the relationships to the business units. 
	 * @param key for the parameter
	 * @param the value
	 */
	public void addParam(String key, Object value) {
		/*
		
		*/
		if(parameterMap.containsKey('relationships')) {
			String v = parameterMap.get('relationships');
			v += ',' + key + ':' + String.valueOf(value);
			parameterMap.put('relationships', v);
		} else {
			parameterMap.put('relationships', key + ':' + String.valueOf(value));
		}
	}
	
	/**
	 * @description perform the action
	 * @param  execution context containing the Id for action record incase it's needed
	 */
	public void execute(ExecutionContext executionContext){
		RiskCreatorHelper.createRisks(parameterMap);
	}
}
