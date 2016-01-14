/**
 * Class that implements actionable to create business units. Does not create the relationships.
 */
public with sharing class BusinessUnitActionable implements iActionable {
	
	Map<Id, List<String>> parametersMap = new Map<Id, List<String>>();
	/**
	 * @description method to add parameters to be used in the creator.
	 * @param key for the parameter
	 * @param the value
	 */
	public void addParam(String key, Object value) {
		//key is scoring scheme Id
		if(parametersMap.containsKey((Id)key)) {
			parametersMap.get((Id)key).add(String.valueOf(value));
		} else {
			parametersMap.put((Id)key, new List<String> { String.valueOf(value) });
		}
	}
	
	/**
	 * @description perform the action
	 * @param  execution context containing the Id for action record incase it's needed
	 */
	public void execute(ExecutionContext executionContext){
		BusinessUnitCreationHelper.createBusinessUnits(parametersMap);
	}
}
