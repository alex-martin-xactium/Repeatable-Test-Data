/**
 * @description Scoring scheme creator that implements the actionable class. Parses the parameters into the correct format.
 */
public with sharing class ScoringSchemeActionable implements iActionable {
	
	private List<String> scoreBandNames = new List<String>();
	private List<String> scoreBandColours = new List<String>();
	
	public final static String scoreBandNameKey = 'scoreBandNames';
	public final static String scoreBandColourKey = 'scoreBandColours';
	/**
	 * @description method to add parameters to be used in the creator.
	 * @param key for the parameter
	 * @param the value
	 */
	public void addParam(String key, Object value) {
		//List<List<String>> heatmap, List<String> scoreBandNames, List<String> scoreBandColours
		if(key.equalsIgnoreCase(scoreBandNameKey)) {
			if(value instanceof List<String> ) {
				scoreBandNames = (List<String>)value;
			} else if(value instanceof String) {
				scoreBandNames.add(String.valueOf(value));
			}
		} else if(key.equalsIgnoreCase(scoreBandColourKey)) {
			if(value instanceof List<String> ) {
				scoreBandNames = (List<String>)value;
			} else if(value instanceof String) {
				scoreBandNames.add(String.valueOf(value));
			}
		}
	}
	
	/**
	 * @description perform the action. First parameter is null. It's to define the heatmap colours, but is currently not needed; 
	 * @param  execution context containing the Id for action record incase it's needed
	 */
	public void execute(ExecutionContext executionContext){
		ScoringSchemeHelper.createScoringScheme(null, scoreBandNames, scoreBandColours);
	}
}
