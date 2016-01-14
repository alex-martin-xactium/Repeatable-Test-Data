/**
 * class that implements the actionable interface to create the business unit relationships. 
 */
public with sharing class BusinessUnitRelationshipActionable implements iActionable {
	Map<String, String> parameterMap = new Map<String, String>();
	/**
	 * @description method to add parameters to be used in the creator.
	 * @param key for the parameter
	 * @param the value
	 */
	public void addParam(String key, Object value) {
		if(parameterMap.containsKey('relationships')) {
			String v = parameterMap.get('relationships');
			v += ',' + key + ':' + String.valueOf(value);
		} else {
			parameterMap.put('relationships', key+':'+String.valueOf(value));
		}
	}
	
	/**
	 * @description perform the action
	 * @param  execution context containing the Id for action record incase it's needed
	 */
	public void execute(ExecutionContext executionContext){
		BusinessUnitRelationshipHelper.updateRelationships(parameterMap);
	}
}
