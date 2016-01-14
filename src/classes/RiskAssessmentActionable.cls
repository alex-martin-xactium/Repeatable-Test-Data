public with sharing class RiskAssessmentActionable implements iActionable {
	
	private Map<String, List<String>> parameterMap = new Map<String, List<String>>();
	/**
	 * @description method to add parameters to be used in the creator. value must be in the format
	 *              likelihood:2 - validation done in helper class and will throw an exception. 
	 * @param key for the parameter
	 * @param the value
	 */
	public void addParam(String key, Object value) {
		if(parameterMap.containsKey(key)) {
			parameterMap.get(key).add(String.valueOf(value));
		} else {
			parameterMap.put(key, new List<String> { String.valueOf(value) });
		}
	}
	
	/**
	 * @description perform the action
	 * @param  execution context containing the Id for action record incase it's needed
	 */
	public void execute(ExecutionContext executionContext){
		RiskAssessmentCreatorHelper.createRiskAssessment(parameterMap);
	}
}
