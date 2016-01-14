/**
 * @description helper class to create risk assessments. 
 */
public with sharing class RiskAssessmentCreatorHelper {
	
	private static Map<Id, Map<String, List<Risk__Score_Band_Entry__c>>> scoringSchemeMap = new Map<Id, Map<String, List<Risk__Score_Band_Entry__c>>>();
	private static Savepoint sp;
	
	/**
	 * @description creates and inserts a risk assessment and the risk assessment ratings. Database save point is used here to prevent risk assessment records
	 *              existing while the ratings fail. 
	 * @param  Parameter map. If this is missing, it will throw a BadParameter exception. If this is poorly formatted
	 *         if will throw a bad parameter exception. Creates assessments for every risk in the org (Gary Burgin)
	 */
	public static void createRiskAssessment(Map<String, List<String>> parameters) {
		if(parameters==null || parameters.keySet().size()==0) {
			throw new BadParameterException('No parameters passed');
		}
		
		// my vars.
		List<Risk__Risk_Assessment__c> assessmentList = new List<Risk__Risk_Assessment__c>();
		Set<Id> scoringSchemeIds = new Set<Id>();
		Map<String, Risk__Impact_Category__c> impactCategoryMap = new Map<String, Risk__Impact_Category__c>();
		List<Risk__Risk_Assessment_Rating__c> assessmentEntryList = new List<Risk__Risk_Assessment_Rating__c>();
		
		//Doing these assessments for every risk in the system - questionable if this is good or bad, but no requirement for existing data to exist
		for(grc__Risk__c risk : [Select Id, Name, grc__Business_Unit__r.Risk__Scoring_Scheme__c from grc__Risk__c]) {
			Risk__Risk_Assessment__c assessment = new Risk__Risk_Assessment__c();
			assessment.Risk__Risk__c = risk.Id;
			assessment.putSObject('Risk__Risk__r', risk);
			assessmentList.add(assessment);
			
			if(!scoringSchemeMap.containsKey(risk.grc__Business_Unit__r.Risk__Scoring_Scheme__c)) {
				scoringSchemeIds.add(risk.grc__Business_Unit__r.Risk__Scoring_Scheme__c);
			}
			
		}
		
		//Woohoo, lots of big if statesments. next step: remove all white space and put them all on one line. 
		for(Risk__Score_Band_Entry__c sbe : [Select Id, Name, Risk__Impact_Name__c, Risk__Score_Band__r.Risk__Scoring_Scheme__c, Risk__To_Value__c, Risk__From_Value__c from Risk__Score_Band_Entry__c where Risk__Score_Band__r.Risk__Scoring_Scheme__c in :scoringSchemeIds order by Risk__Score_Band__r.Risk__Rating__c ASC]) {
			if(scoringSchemeMap.containsKey(sbe.Risk__Score_Band__r.Risk__Scoring_Scheme__c)) {
				if(scoringSchemeMap.get(sbe.Risk__Score_Band__r.Risk__Scoring_Scheme__c).containsKey(sbe.Risk__Impact_Name__c)) {
					scoringSchemeMap.get(sbe.Risk__Score_Band__r.Risk__Scoring_Scheme__c).get(sbe.Risk__Impact_Name__c).add(sbe);
				} else {
					scoringSchemeMap.get(sbe.Risk__Score_Band__r.Risk__Scoring_Scheme__c).put(sbe.Risk__Impact_Name__c, new List<Risk__Score_Band_Entry__c> { sbe });
				}
			} else {
				scoringSchemeMap.put(sbe.Risk__Score_Band__r.Risk__Scoring_Scheme__c, new Map<String, List<Risk__Score_Band_Entry__c>> { sbe.Risk__Impact_Name__c => new List<Risk__Score_Band_Entry__c> { sbe } });
			}
		}
		
		//build impact category map so we can reference it down below. Need each IC for each ScoringScheme we're going to use. 
		for(Risk__Impact_Category__c impactCategory : [Select Id, Name from Risk__Impact_Category__c where Risk__Scoring_Scheme__c in :scoringSchemeMap.keySet()]) {
			impactCategoryMap.put(impactCategory.Name.toLowerCase(), impactCategory);
		}
		
		//Mark a save point in the database.
		sp = Database.setSavepoint();
		insert assessmentList;
		
		for(Risk__Risk_Assessment__c assessment : assessmentList) {
			
			//key is mitigation, followed by impact category split by colon then integer value
			for(String mitigation : parameters.keySet()) {
				//iterate over all the impact categories we're scoring for, for that specific mitigation. 
				for(String impactCategoryValue : parameters.get(mitigation)) {
					List<String> pair = impactCategoryValue.split(':');
					if(pair.size() != 2) {
						Database.rollback(sp);
						throw new BadParameterException('Parameters should appear in the following format: residual => likelihood:2');
					}
					String category = pair.get(0);
					
					integer sbeValue;
					try {
						sbeValue = integer.valueOf(pair.get(1));
					} catch(Exception e) {
						if(!(pair.get(1)==null)) {
							Database.rollback(sp);
							throw new BadParameterException('Score Band Entry value is not an integer');
						}
					}
					//create assessment. 
					Id scoringSchemeId = assessment.Risk__Risk__r.grc__Business_Unit__r.Risk__Scoring_Scheme__c;
					assessmentEntryList.add(createAssessmentRating(scoringSchemeId, assessment.Id, impactCategoryMap.get(category.toLowerCase()), mitigation, sbeValue));					
				}
			}
		}
		try {
			insert assessmentEntryList;
		} catch(Exception e) {
			Database.rollBack(sp);
			throw new AppException(e);
		}
		
	}
	
	/**
	 * @description method to create a single risk assessment rating. Will throw errors if bad parameters are present.
	 * @param  Id of the scoring scheme to use. Helps us find the correct score band entry. 
	 * @param  Id of the risk assessment, this is required and will throw an exception if missing. 
	 * @param  Risk impact category - this is optional. If blank, it will presume this rating is a likelihood one.
	 * @param  mitigation - this is required. Will throw an exception if missing  or wrong (Mitigation is Residual/Inherent/Target)
	 * @param  integer value representing which score band the values should fall in. Throws an exception if missing or incorrect value for specified scoring scheme. 
	 *         sbeValue must be above 0, 1 is lowest value.
	 * @return returns the created risk assessment rating. 
	 */
	public static Risk__Risk_Assessment_Rating__c createAssessmentRating(Id scoringSchemeId, Id riskAssessmentId, Risk__Impact_Category__c impactCategory, String mitigation, integer sbeValue) {
		if(riskAssessmentId == null || mitigation == null || mitigation == '' || sbeValue == null || sbeValue == 0 ||
		(!mitigation.equalsIgnoreCase('residual') && !mitigation.equalsIgnoreCase('inherent') &&  !mitigation.equalsIgnoreCase('target'))) {
			Database.rollback(sp);
			throw new BadParameterException('Missing or incorrect parameters passed');
		}
		
		Risk__Risk_Assessment_Rating__c rating = new Risk__Risk_Assessment_Rating__c();
		rating.Risk__Risk_Assessment__c = riskAssessmentId;
		rating.Risk__Mitigation__c = mitigation;
		
		if(impactCategory != null) {
			if(scoringSchemeMap.get(scoringSchemeId).get(impactCategory.Name).size() <= (sbeValue-1)) {
				Database.rollback(sp);
				throw new BadParameterException('The Score Band Entry value is larger than the scoring scheme size');
			}			
		} else {
			//null is a valid key it represents likelihood, which has no IC record.
			if(scoringSchemeMap.get(scoringSchemeId).get(null).size() <= (sbeValue-1)) {
				Database.rollback(sp);
				throw new BadParameterException('The Score Band Entry value is larger than the scoring scheme size');
			}
		}

		Risk__Score_Band_Entry__c sbe;
		if(impactCategory != null) {
			sbe = scoringSchemeMap.get(scoringSchemeId).get(impactCategory.Name).get(sbeValue-1);
		} else {
			sbe = scoringSchemeMap.get(scoringSchemeId).get(null).get(sbeValue-1);
		}
		
		
		//Maths. 
		rating.Risk__Value__c = ((sbe.Risk__To_Value__c - sbe.Risk__From_Value__c) / 2) + sbe.Risk__From_Value__c;
		
		//Assumption is that the lowest end of the score band is best case, for threat risks. highest is worst. Other way round if opportunity, but no 
		//requirment to support opportunity for now. 
		rating.Risk__Worst_Case__c = sbe.Risk__To_Value__c;
		rating.Risk__Best_Case__c = sbe.Risk__From_Value__c;
		
		if(impactCategory != null) {
			rating.Risk__Impact_Category__c = impactCategory.Id;
			rating.Risk__Category__c = impactCategory.Name;
		} else {
			rating.Risk__Category__c = 'Likelihood';
		}
		
		return rating;
	}
}
